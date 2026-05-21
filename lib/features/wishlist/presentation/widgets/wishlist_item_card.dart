import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/format_krw.dart';
import 'package:bike_house/features/product/data/product_model.dart';
import 'package:bike_house/features/product/presentation/product_detail_screen.dart';
import 'package:bike_house/features/wishlist/application/wishlist_notifier.dart';
import 'package:bike_house/features/wishlist/presentation/widgets/wishlist_cart_icon_button.dart';

const _kBestSellerStarColor = Color(0xFFFBBF24);

/// 위시리스트 한 줄 카드 (탭 시 상세, 하트로 찜 해제)
class WishlistItemCard extends ConsumerWidget {
  const WishlistItemCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: product.thumbnailUrl != null
                    ? Image.network(
                        product.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _WishlistImagePlaceholder(),
                      )
                    : const _WishlistImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref
                            .read(wishlistProvider.notifier)
                            .toggle(product),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.favorite,
                            color: AppColors.wishlistRed,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (product.isBestSeller)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: _kBestSellerStarColor,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '베스트셀러',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formatKrw(product.price),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      WishlistCartIconButton(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistImagePlaceholder extends StatelessWidget {
  const _WishlistImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 32,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
