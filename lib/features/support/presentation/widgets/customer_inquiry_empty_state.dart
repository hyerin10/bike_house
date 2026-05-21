import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

class CustomerInquiryEmptyState extends StatelessWidget {
  const CustomerInquiryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: AppColors.textHint,
            ),
            SizedBox(height: 14),
            Text(
              '상담 내역이 없습니다.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '위 버튼을 눌러 새 상담을 시작해보세요.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
