import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bike_house/features/chat/domain/chat_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 종료된 상담 요약 모델 (로컬 캐시용)
// ─────────────────────────────────────────────────────────────────────────────

class InquiryCacheEntry {
  const InquiryCacheEntry({
    required this.id,
    required this.preview,
    required this.createdAt,
    this.lastMessageAt,
  });

  final String id;
  final String preview;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  factory InquiryCacheEntry.fromChatRoom(ChatRoom room) => InquiryCacheEntry(
        id: room.id,
        preview: room.lastMessage ?? '',
        createdAt: room.createdAt,
        lastMessageAt: room.lastMessageAt,
      );

  /// 로컬 캐시 항목을 ChatRoom 으로 복원 (status=completed)
  ChatRoom toChatRoom() => ChatRoom(
        id: id,
        status: ChatRoomStatus.completed,
        createdAt: createdAt,
        customerId: '',
        customerName: '나',
        lastMessage: preview.isEmpty ? null : preview,
        lastMessageAt: lastMessageAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'preview': preview,
        'created_at': createdAt.toIso8601String(),
        if (lastMessageAt != null)
          'last_message_at': lastMessageAt!.toIso8601String(),
      };

  factory InquiryCacheEntry.fromJson(Map<String, dynamic> json) =>
      InquiryCacheEntry(
        id: json['id'] as String,
        preview: json['preview'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        lastMessageAt: json['last_message_at'] != null
            ? DateTime.parse(json['last_message_at'] as String)
            : null,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SharedPreferences 기반 로컬 캐시
// ─────────────────────────────────────────────────────────────────────────────

class InquiryLocalCache {
  static String _prefKey(String userId) =>
      'inquiry_completed_cache_$userId';

  Future<List<InquiryCacheEntry>> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey(userId));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map(
            (e) => InquiryCacheEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(String userId, List<InquiryCacheEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefKey(userId), json);
  }

  /// 항목 추가 또는 갱신 (id 기준 중복 제거)
  Future<void> upsert(String userId, InquiryCacheEntry entry) async {
    final existing = await load(userId);
    final updated = [
      ...existing.where((e) => e.id != entry.id),
      entry,
    ];
    await _save(userId, updated);
  }
}
