import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 위시리스트 로드 실패 시 표시
class WishlistErrorView extends StatelessWidget {
  const WishlistErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          Text(
            '위시리스트를 불러오지 못했습니다.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
