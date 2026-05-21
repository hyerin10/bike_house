import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

class CustomerInquiryStatusRow extends StatelessWidget {
  const CustomerInquiryStatusRow({
    super.key,
    required this.waitingCount,
    required this.completedCount,
  });

  final int waitingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomerInquiryStatusCard(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.inquiryPendingIcon,
            iconBgColor: AppColors.inquiryPendingBg,
            count: waitingCount,
            label: '답변대기',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomerInquiryStatusCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.inquiryCompletedIcon,
            iconBgColor: AppColors.inquiryCompletedBg,
            count: completedCount,
            label: '상담종료',
          ),
        ),
      ],
    );
  }
}

class CustomerInquiryStatusCard extends StatelessWidget {
  const CustomerInquiryStatusCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
