import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/product.dart';
import '../../domain/product_model.dart';
import '../product_detail_screen.dart';

/// 가격(원)을 "₩00,000" 형태 문자열로 변환
String formatPrice(double price) {
  final intPrice = price.round();
  return '₩${intPrice.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  )}';
}

/// 인기 부품 / 전체 보기 화면 공통으로 사용하는 상품 카드 위젯
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(product: kSampleProductDetail),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageArea(product: product),
            _InfoArea(product: product),
          ],
        ),
      ),
    );
  }
}

// ─── 이미지 + 뱃지 영역 ────────────────────────────────────────────────────────

class _ImageArea extends StatelessWidget {
  const _ImageArea({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 상품 이미지 placeholder
        Container(
          height: 110,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: const Center(
            child: Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppColors.textHint,
            ),
          ),
        ),

        // 베스트셀러 뱃지
        if (product.isBestSeller)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Best Seller',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

        // 찜하기 버튼
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border,
              size: 20,
              color: AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 텍스트 정보 영역 ─────────────────────────────────────────────────────────

class _InfoArea extends StatelessWidget {
  const _InfoArea({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 호환 가능 뱃지
          if (product.isCompatible)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.compatible,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 10, color: Colors.white),
                  SizedBox(width: 3),
                  Text(
                    '호환 가능',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),

          // 상품명
          Text(
            product.name,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // 별점 & 리뷰 수
          if (product.rating != null)
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Color(0xFFFFB800)),
                const SizedBox(width: 2),
                Text(
                  '${product.rating}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                if (product.reviewCount != null)
                  Text(
                    '(${product.reviewCount})',
                    style: textTheme.bodyMedium,
                  ),
              ],
            ),

          const SizedBox(height: 6),

          // 현재 판매가
          Text(
            formatPrice(product.price),
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          // 원가 (있을 때만)
          if (product.originalPrice != null)
            Text(
              formatPrice(product.originalPrice!),
              style: textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: AppColors.textHint,
              ),
            ),
        ],
      ),
    );
  }
}
