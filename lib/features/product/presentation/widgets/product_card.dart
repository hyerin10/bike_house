import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/product_model.dart';
import '../product_detail_screen.dart';

/// 가격(원)을 "₩00,000" 형태 문자열로 변환
String formatPrice(num price) {
  final intPrice = price.round();
  return '₩${intPrice.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  )}';
}

/// 인기 부품 / 전체 보기 화면 공통으로 사용하는 상품 카드 위젯
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
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

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 상품 이미지: thumbnailUrl이 있으면 실제 이미지, 없으면 placeholder
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            height: 110,
            width: double.infinity,
            child: product.thumbnailUrl != null
                ? Image.network(
                    product.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _Placeholder(),
                  )
                : const _Placeholder(),
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
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 56,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

// ─── 텍스트 정보 영역 ─────────────────────────────────────────────────────────

class _InfoArea extends StatelessWidget {
  const _InfoArea({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상품명
          Text(
            product.name,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // 현재 판매가
          Text(
            formatPrice(product.price),
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          // 재고 부족 경고 (재고 10개 이하)
          if (product.stock != null && product.stock! <= 10)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '재고 ${product.stock}개 남음',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
