import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/features/chat/domain/chat_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class ChatRepository {
  ChatRepository(this._client);

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  // ── Customer: 기존 방 조회 또는 신규 생성 (원자적 RPC 사용) ─────────────────

  Future<String> getOrCreateRoom() async {
    if (_uid == null) throw Exception('로그인이 필요합니다.');

    final result = await _client.rpc('get_or_create_chat_room');
    return result as String;
  }

  // ── Customer: WAITING/ACTIVE 방 조회 (생성 없이) ────────────────────────────

  Future<String?> getExistingRoom() async {
    if (_uid == null) return null;
    try {
      final memberRows = await _client
          .from('chat_room_members')
          .select('room_id')
          .eq('user_id', _uid!)
          .eq('role', 'CUSTOMER');

      final roomIds = (memberRows as List)
          .map((r) => r['room_id'] as String)
          .toList();

      if (roomIds.isEmpty) return null;

      final room = await _client
          .from('chat_rooms')
          .select('id')
          .inFilter('id', roomIds)
          .neq('status', 'COMPLETED')
          .maybeSingle();

      return room?['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ── Customer: WAITING/ACTIVE 방 ID 실시간 스트림 (알림 배지용) ───────────────
  //   - 방이 없거나 COMPLETED 이면 null emit
  //   - 방 생성·상태 변경 시 자동 갱신

  Stream<String?> streamExistingRoomId() {
    final controller = StreamController<String?>();
    RealtimeChannel? memberChannel;
    RealtimeChannel? roomChannel;

    Future<void> subscribeToRoom(String roomId) async {
      await roomChannel?.unsubscribe();
      roomChannel = _client
          .channel('customer_room_status_$roomId')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'chat_rooms',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: roomId,
            ),
            callback: (_) async {
              final updated = await getExistingRoom();
              if (!controller.isClosed) controller.add(updated);
              if (updated != null) await subscribeToRoom(updated);
            },
          )
          .subscribe();
    }

    Future<void> fetchAndSetup() async {
      final roomId = await getExistingRoom();
      if (!controller.isClosed) controller.add(roomId);
      if (roomId != null) await subscribeToRoom(roomId);
    }

    controller.onListen = () async {
      await fetchAndSetup();

      // 새 방이 생성되어 멤버로 추가될 때 감지
      memberChannel = _client
          .channel('customer_member_watch_$_uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_room_members',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: _uid ?? '',
            ),
            callback: (_) => fetchAndSetup(),
          )
          .subscribe();
    };

    controller.onCancel = () async {
      await memberChannel?.unsubscribe();
      await roomChannel?.unsubscribe();
    };

    return controller.stream;
  }

  // ── Admin: WAITING/ACTIVE 방 목록 스트림 ────────────────────────────────────

  Stream<List<ChatRoom>> streamRooms() {
    final controller = StreamController<List<ChatRoom>>();
    RealtimeChannel? channel;

    Future<void> fetchAndEmit() async {
      try {
        final response = await _client.rpc('get_chat_rooms');
        final rooms = (response as List)
            .map((r) => ChatRoom.fromJson(r as Map<String, dynamic>))
            .toList();
        if (!controller.isClosed) controller.add(rooms);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    controller.onListen = () async {
      await fetchAndEmit();

      // 방 상태 변경 또는 새 메시지가 오면 목록 갱신
      channel = _client
          .channel('admin_rooms_feed')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'chat_rooms',
            callback: (_) => fetchAndEmit(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_messages',
            callback: (_) => fetchAndEmit(),
          )
          .subscribe();
    };

    controller.onCancel = () async {
      await channel?.unsubscribe();
    };

    return controller.stream;
  }

  // ── Shared: 특정 방의 메시지 스트림 ─────────────────────────────────────────

  Stream<List<ChatMessage>> streamMessages(String roomId) {
    final controller = StreamController<List<ChatMessage>>();
    RealtimeChannel? channel;
    final messages = <ChatMessage>[];

    controller.onListen = () async {
      try {
        // 기존 메시지 로드
        final rows = await _client
            .from('chat_messages')
            .select()
            .eq('room_id', roomId)
            .order('created_at');

        messages.addAll(
          (rows as List).map(
            (r) => ChatMessage.fromJson(r as Map<String, dynamic>),
          ),
        );
        if (!controller.isClosed) controller.add(List.unmodifiable(messages));

        // 신규 메시지 구독 (INSERT 이벤트만)
        channel = _client
            .channel('messages_$roomId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'chat_messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'room_id',
                value: roomId,
              ),
              callback: (payload) {
                messages.add(
                  ChatMessage.fromJson(payload.newRecord),
                );
                if (!controller.isClosed) {
                  controller.add(List.unmodifiable(messages));
                }
              },
            )
            .subscribe();
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    };

    controller.onCancel = () async {
      await channel?.unsubscribe();
    };

    return controller.stream;
  }

  // ── Shared: 메시지 전송 ──────────────────────────────────────────────────────

  Future<void> sendMessage(String roomId, String message, {String? imageUrl}) async {
    final userId = _uid;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    await _client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': userId,
      'message': message,
      if (imageUrl != null) 'image_url': imageUrl,
    });
  }

  // ── Shared: 이미지 업로드 후 메시지 전송 ─────────────────────────────────────

  /// [source]로 카메라/갤러리를 선택합니다.
  /// 이미지를 Supabase Storage에 업로드하고 chat_messages에 URL을 저장합니다.
  Future<void> sendImageMessage(String roomId, XFile imageFile) async {
    final userId = _uid;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    final ext = imageFile.path.split('.').last.toLowerCase();
    final mimeType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = '$roomId/$fileName';

    final bytes = await File(imageFile.path).readAsBytes();

    await _client.storage.from('chat_images').uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(
        contentType: mimeType,
        upsert: false,
      ),
    );

    final publicUrl =
        _client.storage.from('chat_images').getPublicUrl(storagePath);

    await sendMessage(roomId, '', imageUrl: publicUrl);
  }

  // ── Admin: 상담 수락 (WAITING → ACTIVE, 원자적 실행) ───────────────────────

  /// [roomId] 방을 수락합니다.
  /// 다른 관리자가 이미 수락한 경우 false 반환.
  Future<bool> acceptChat(String roomId) async {
    final userId = _uid;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    final result = await _client.rpc(
      'accept_chat',
      params: {'p_room_id': roomId, 'p_admin_id': userId},
    );
    return result as bool;
  }

  // ── Admin: 상담 종료 (ACTIVE → COMPLETED) ───────────────────────────────────

  Future<void> endChat(String roomId) async {
    await _client
        .from('chat_rooms')
        .update({'status': 'COMPLETED'})
        .eq('id', roomId);
  }

  // ── Customer: 내 방의 실시간 상태 스트림 ─────────────────────────────────────

  /// 고객이 자신의 방 상태(예: WAITING→ACTIVE)를 구독할 때 사용
  Stream<String> streamRoomStatus(String roomId) {
    final controller = StreamController<String>();
    RealtimeChannel? channel;

    controller.onListen = () async {
      final initial = await _client
          .from('chat_rooms')
          .select('status')
          .eq('id', roomId)
          .single();
      if (!controller.isClosed) {
        controller.add(initial['status'] as String);
      }

      channel = _client
          .channel('room_status_$roomId')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'chat_rooms',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: roomId,
            ),
            callback: (payload) {
              final newStatus =
                  payload.newRecord['status'] as String? ?? 'WAITING';
              if (!controller.isClosed) controller.add(newStatus);
            },
          )
          .subscribe();
    };

    controller.onCancel = () async {
      await channel?.unsubscribe();
    };

    return controller.stream;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Providers
// ─────────────────────────────────────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(Supabase.instance.client),
);

/// 관리자: WAITING/ACTIVE 방 목록 스트림
final adminChatRoomsProvider = StreamProvider.autoDispose<List<ChatRoom>>(
  (ref) => ref.watch(chatRepositoryProvider).streamRooms(),
);

/// 특정 방의 메시지 스트림 (관리자/고객 공용)
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).streamMessages(roomId);
});

/// 고객: 현재 세션의 채팅방 ID (없으면 자동 생성)
final customerRoomIdProvider = FutureProvider.autoDispose<String?>((ref) async {
  try {
    return await ref.read(chatRepositoryProvider).getOrCreateRoom();
  } catch (_) {
    return null;
  }
});

/// 고객이 채팅방을 마지막으로 열어본 시각 (알림 배지 초기화용)
final chatLastViewedAtProvider = StateProvider<DateTime?>((ref) => null);

/// 고객: WAITING/ACTIVE 채팅방 ID 실시간 스트림
///   - 방 없음 또는 COMPLETED → null
///   - 방 상태 변경·신규 생성 시 자동 갱신
final customerExistingRoomIdProvider =
    StreamProvider.autoDispose<String?>((ref) {
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null) return Stream.value(null);
  return ref.watch(chatRepositoryProvider).streamExistingRoomId();
});

/// 고객: 관리자가 보낸 읽지 않은 메시지 수
final unreadAdminCountProvider = Provider.autoDispose<int>((ref) {
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null) return 0;

  final roomId = ref.watch(customerExistingRoomIdProvider).valueOrNull;
  if (roomId == null) return 0;

  final messagesAsync = ref.watch(chatMessagesProvider(roomId));
  final messages = messagesAsync.valueOrNull ?? [];
  final lastViewed = ref.watch(chatLastViewedAtProvider);

  return messages.where((m) {
    if (m.senderId == currentUser.id) return false;
    if (lastViewed == null) return true;
    return m.createdAt.isAfter(lastViewed);
  }).length;
});
