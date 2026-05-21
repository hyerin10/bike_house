import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/data/product_model.dart';
import 'package:bike_house/features/product/presentation/widgets/product_card.dart';

/// 결과 수 바 + 그리드 또는 빈 상태
class SearchResultBody extends StatelessWidget {
  const SearchResultBody({
    super.key,
    required this.products,
    required this.query,
  });

  final List<ProductModel> products;
  final String? query;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              Text(
                '${products.length}개 상품',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? SearchResultEmptyState(query: query)
              : SearchResultProductGrid(products: products),
        ),
      ],
    );
  }
}

class SearchResultProductGrid extends StatelessWidget {
  const SearchResultProductGrid({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: productCardGridAspectRatio(context),
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}

class SearchResultEmptyState extends StatelessWidget {
  const SearchResultEmptyState({super.key, required this.query});

  final String? query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            query != null ? '"$query"에 대한\n검색 결과가 없습니다.' : '등록된 상품이 없습니다.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
