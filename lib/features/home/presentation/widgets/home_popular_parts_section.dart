import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/product_notifier.dart';
import 'package:bike_house/features/product/presentation/search_result_screen.dart';
import 'package:bike_house/features/product/presentation/widgets/product_card.dart';

class HomePopularPartsSection extends ConsumerWidget {
  const HomePopularPartsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인기 부품',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    '내 바이크에 맞는 부품',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SearchResultScreen(),
                    ),
                  );
                },
                child: Text(
                  '전체 보기',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        asyncProducts.when(
          loading: () => const SizedBox(
            height: 270,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 8),
                Text(
                  '상품을 불러오지 못했습니다.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => ref.read(productProvider.notifier).refresh(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
          data: (products) {
            final preview = products.take(4).toList();
            if (preview.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '등록된 상품이 없습니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: productCardGridAspectRatio(context),
                ),
                itemCount: preview.length,
                itemBuilder: (context, index) =>
                    ProductCard(product: preview[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}
