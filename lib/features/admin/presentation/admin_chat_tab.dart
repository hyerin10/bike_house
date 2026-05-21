import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/chat/domain/chat_models.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_chat_room_card.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_chat_status_count_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 상담 관리 탭
// ─────────────────────────────────────────────────────────────────────────────

class AdminChatTab extends ConsumerWidget {
  const AdminChatTab({super.key});

  /// WAITING·ACTIVE → 최신 메시지 순(위), COMPLETED → 최신이 위·오래된 게 맨 아래
  static List<ChatRoom> _sortRooms(List<ChatRoom> rooms) {
    final active = rooms
        .where((r) => !r.status.isCompleted)
        .toList()
      ..sort(
        (a, b) => (b.lastMessageAt ?? b.createdAt)
            .compareTo(a.lastMessageAt ?? a.createdAt),
      );

    final completed = rooms
        .where((r) => r.status.isCompleted)
        .toList()
      ..sort(
        // 내림차순: 최신이 위, 오래된 게 맨 아래
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

    return [...active, ...completed];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(adminAllRoomsProvider);

    return roomsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          '채팅 목록을 불러오지 못했습니다.\n$e',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      data: (rooms) => _AdminChatRoomsBody(rooms: _sortRooms(rooms)),
    );
  }
}

class _AdminChatRoomsBody extends StatelessWidget {
  const _AdminChatRoomsBody({required this.rooms});

  final List<ChatRoom> rooms;

  @override
  Widget build(BuildContext context) {
    final waitingCount = rooms.where((r) => r.status.isWaiting).length;
    final activeCount = rooms.where((r) => r.status.isActive).length;
    final completedCount = rooms.where((r) => r.status.isCompleted).length;
    final activeRooms = rooms.where((r) => !r.status.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        AdminChatStatusSummaryRow(
          waitingCount: waitingCount,
          activeCount: activeCount,
          completedCount: completedCount,
        ),
        const SizedBox(height: 12),
        if (activeRooms.isEmpty && completedCount == 0)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                '상담 내역이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
            ),
          )
        else ...[
          if (activeRooms.isNotEmpty) ...[
            ...activeRooms.map(
              (room) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AdminChatRoomCard(room: room),
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Center(
                child: Text(
                  '대기 중인 상담이 없습니다.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
          if (completedCount > 0) ...[
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '종료된 상담',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
            ),
            ...rooms
                .where((r) => r.status.isCompleted)
                .map(
                  (room) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AdminChatRoomCard(room: room),
                  ),
                ),
          ],
        ],
      ],
    );
  }
}
