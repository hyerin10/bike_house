import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 검색 결과 로드 실패 시 표시
class SearchResultErrorView extends StatelessWidget {
  const SearchResultErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            '상품을 불러오지 못했습니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
