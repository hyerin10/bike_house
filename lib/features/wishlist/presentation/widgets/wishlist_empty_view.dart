import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 위시리스트가 비었을 때 안내
class WishlistEmptyView extends StatelessWidget {
  const WishlistEmptyView({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                size: 48,
                color: AppColors.wishlistRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '찜한 상품이 없습니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '마음에 드는 부품을 하트로 저장해보세요.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('상품 둘러보기'),
            ),
          ],
        ),
      ),
    );
  }
}
