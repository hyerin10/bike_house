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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(adminChatRoomsProvider);

    return roomsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          '채팅 목록을 불러오지 못했습니다.\n$e',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      data: (rooms) => _AdminChatRoomsBody(rooms: rooms),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        AdminChatStatusSummaryRow(
          waitingCount: waitingCount,
          activeCount: activeCount,
        ),
        const SizedBox(height: 12),
        if (rooms.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                '대기 중인 상담이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
            ),
          )
        else
          ...rooms.map(
            (room) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdminChatRoomCard(room: room),
            ),
          ),
      ],
    );
  }
}
