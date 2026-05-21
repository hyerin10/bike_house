import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

class AdminProductEmptyView extends StatelessWidget {
  const AdminProductEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 14),
          Text(
            '등록된 상품이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '위의 \'상품 등록\' 버튼으로 상품을 추가해 보세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
