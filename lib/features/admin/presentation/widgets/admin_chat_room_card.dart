import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/domain/chat_models.dart';
import 'package:bike_house/features/admin/presentation/admin_chat_actions.dart';
import 'package:bike_house/features/admin/presentation/admin_chat_ui.dart';

class AdminChatRoomCard extends ConsumerWidget {
  const AdminChatRoomCard({super.key, required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWaiting = room.status.isWaiting;
    final isActive = room.status.isActive;
    final isCompleted = room.status.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.background
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AdminChatUi.avatarPlaceholderBackground,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 22,
                    color: isCompleted
                        ? AppColors.textHint
                        : AppColors.textHint,
                  ),
                ),
              ),
              if (isActive)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AdminChatUi.activeAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      room.customerName.isNotEmpty
                          ? '${room.customerName} 고객'
                          : '고객',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isWaiting)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AdminChatUi.waitingBadgeBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '대기',
                          style: TextStyle(
                            color: AdminChatUi.waitingBadgeForeground,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AdminChatUi.completedBadgeBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '종료',
                          style: TextStyle(
                            color: AdminChatUi.completedBadgeForeground,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      room.timeAgoLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  room.lastMessage ?? '메시지가 없습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted
                        ? AppColors.textHint
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isWaiting) ...[
            const SizedBox(width: 10),
            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: () =>
                    acceptAdminChatAndOpenRoom(context, ref, room),
                style: AdminChatUi.compactElevatedButton(
                  AppColors.adminShieldBackground,
                ),
                child: const Text(
                  '상담하기',
                  style: AdminChatUi.compactElevatedLabel,
                ),
              ),
            ),
          ],
          if (isActive) ...[
            const SizedBox(width: 10),
            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: () => openAdminChatRoom(context, room),
                style: AdminChatUi.compactElevatedButton(
                  AdminChatUi.activeAccent,
                ),
                child: const Text(
                  '입장',
                  style: AdminChatUi.compactElevatedLabel,
                ),
              ),
            ),
          ],
          if (isCompleted) ...[
            const SizedBox(width: 10),
            SizedBox(
              height: 34,
              child: OutlinedButton(
                onPressed: () => openAdminChatRoom(context, room),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '보기',
                  style: AdminChatUi.compactElevatedLabel,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
