import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/popular_parts_controller.dart';
import 'package:bike_house/features/product/presentation/widgets/product_card.dart';

/// 인기 부품 목록 그리드 (필터·정렬이 적용된 `state` 기준)
class PopularPartsProductGrid extends StatelessWidget {
  const PopularPartsProductGrid({super.key, required this.state});

  final PopularPartsState state;

  @override
  Widget build(BuildContext context) {
    final products = state.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              '검색 결과가 없습니다.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: productCardGridAspectRatio(context),
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
