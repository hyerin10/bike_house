import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/product_detail_notifier.dart';
import 'package:bike_house/features/product/domain/product_model.dart';
import 'package:bike_house/features/product/presentation/widgets/description_section.dart';
import 'package:bike_house/features/product/presentation/widgets/feature_grid.dart';
import 'package:bike_house/features/product/presentation/widgets/product_detail_app_bar.dart';
import 'package:bike_house/features/product/presentation/widgets/product_detail_bottom_action_bar.dart';
import 'package:bike_house/features/product/presentation/widgets/product_image_section.dart';
import 'package:bike_house/features/product/presentation/widgets/product_info_section.dart';

/// 상품 상세 화면
///
/// [productId]로 Supabase에서 단일 상품 정보를 조회하여 렌더링합니다.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: ProductDetailAppBar(productId: productId),
      body: asyncProduct.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
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
                '상품 정보를 불러오지 못했습니다.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(productDetailProvider(productId).notifier).refresh(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (product) => SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageSection(
                productId: productId,
                images: product.images,
                isBestSeller: product.isBestSeller,
              ),
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductInfoSection(product: product),
                    const SizedBox(height: 20),
                    const FeatureGrid(features: kDefaultProductFeatures),
                    const SizedBox(height: 24),
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      DescriptionSection(description: product.description!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: asyncProduct.valueOrNull != null
          ? ProductDetailBottomActionBar(product: asyncProduct.valueOrNull!)
          : null,
    );
  }
}
