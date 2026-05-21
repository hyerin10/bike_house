import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/presentation/admin_chat_ui.dart';

/// 대기중 / 상담중 / 종료 건수 요약 한 줄
class AdminChatStatusSummaryRow extends StatelessWidget {
  const AdminChatStatusSummaryRow({
    super.key,
    required this.waitingCount,
    required this.activeCount,
    this.completedCount = 0,
  });

  final int waitingCount;
  final int activeCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AdminChatStatusCountCard(
            label: '대기중',
            count: waitingCount,
            dotColor: AdminChatUi.waitingDot,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AdminChatStatusCountCard(
            label: '상담중',
            count: activeCount,
            dotColor: AdminChatUi.activeAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AdminChatStatusCountCard(
            label: '상담종료',
            count: completedCount,
            dotColor: AdminChatUi.completedDot,
          ),
        ),
      ],
    );
  }
}

class AdminChatStatusCountCard extends StatelessWidget {
  const AdminChatStatusCountCard({
    super.key,
    required this.label,
    required this.count,
    required this.dotColor,
  });

  final String label;
  final int count;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
