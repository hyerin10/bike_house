import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../cart/application/cart_controller.dart';
import '../domain/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 찜하기 토글 Provider (상품 ID별 관리)
// ─────────────────────────────────────────────────────────────────────────────

final wishlistProvider =
    StateProvider.family<bool, String>((ref, productId) => false);

// ─────────────────────────────────────────────────────────────────────────────
// 상품 상세 화면
// ─────────────────────────────────────────────────────────────────────────────

/// 상품 상세 화면
///
/// [product]를 전달하지 않으면 샘플 데이터로 렌더링됩니다.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, this.product});

  final ProductDetail? product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = product ?? kSampleProductDetail;
    final isWishlisted = ref.watch(wishlistProvider(detail.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,

      // 투명 앱바 (이미지 영역 위에 오버레이)
      appBar: _buildAppBar(context, ref, detail, isWishlisted),

      // 스크롤 가능한 본문
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지 영역
            _ProductImageSection(isBestSeller: detail.isBestSeller),

            // 흰 카드 영역 (호환성 배너 ~ 설명)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 호환성 배너
                  if (detail.compatibleBike != null)
                    CompatibilityBanner(bikeName: detail.compatibleBike!),

                  if (detail.compatibleBike != null) const SizedBox(height: 16),

                  // 상품명 + 가격 + 별점
                  _ProductInfo(detail: detail),

                  const SizedBox(height: 20),

                  // 특징 그리드
                  FeatureGrid(features: detail.features),

                  const SizedBox(height: 24),

                  // 상품 설명
                  DescriptionSection(description: detail.description),
                ],
              ),
            ),
          ],
        ),
      ),

      // 하단 고정 액션 바
      bottomNavigationBar: _BottomActionBar(product: detail),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    ProductDetail detail,
    bool isWishlisted,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: _CircleIconButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        _CircleIconButton(
          icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
          iconColor: isWishlisted ? const Color(0xFFEF4444) : AppColors.textPrimary,
          onTap: () {
            ref.read(wishlistProvider(detail.id).notifier).state = !isWishlisted;
          },
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.share_outlined,
          onTap: () {
            // 추후 공유 기능 구현
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 앱바 원형 아이콘 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 이미지 섹션
// ─────────────────────────────────────────────────────────────────────────────

class _ProductImageSection extends StatelessWidget {
  const _ProductImageSection({required this.isBestSeller});

  final bool isBestSeller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 이미지 배경
        Container(
          height: 300,
          width: double.infinity,
          color: AppColors.background,
          child: const Center(
            child: Icon(
              Icons.inventory_2_outlined,
              size: 100,
              color: AppColors.textHint,
            ),
          ),
        ),

        // 베스트셀러 뱃지
        if (isBestSeller)
          Positioned(
            top: 96,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '베스트셀러',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 호환성 배너
// ─────────────────────────────────────────────────────────────────────────────

/// 바이크 호환성을 강조하는 초록색 배너 위젯 (재사용 가능)
class CompatibilityBanner extends StatelessWidget {
  const CompatibilityBanner({super.key, required this.bikeName});

  final String bikeName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAFAF1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '내 바이크와 호환됩니다',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF16A34A),
                    ),
              ),
              const SizedBox(height: 1),
              Text(
                bikeName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF22C55E),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 정보 (이름 / 가격 / 별점)
// ─────────────────────────────────────────────────────────────────────────────

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.detail});

  final ProductDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상품명
        Text(
          detail.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),

        const SizedBox(height: 10),

        // 가격 행
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 현재 가격
            Text(
              detail.formattedPrice,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),

            if (detail.formattedOriginalPrice != null) ...[
              const SizedBox(width: 10),

              // 원가 (취소선)
              Text(
                detail.formattedOriginalPrice!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textHint,
                    ),
              ),

              const SizedBox(width: 8),

              // 할인율 뱃지
              if (detail.discountPercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${detail.discountPercent}% 할인',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // 별점 + 리뷰 수
        Row(
          children: [
            _StarRating(rating: detail.rating),
            const SizedBox(width: 6),
            Text(
              '${detail.rating}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 4),
            Text(
              '(${detail.reviewCount}개 리뷰)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}

/// 별점 표시 위젯
class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        const starColor = Color(0xFFFFB800);
        final filled = index < rating.floor();
        final isHalf = !filled && index < rating;

        return Icon(
          isHalf ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
          color: starColor,
          size: 18,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 특징 그리드 (무료 배송 / 보증 / 반품)
// ─────────────────────────────────────────────────────────────────────────────

/// 상품 특징 3열 그리드 (재사용 가능)
class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key, required this.features});

  final List<ProductFeature> features;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: features.map((feature) {
        final isLast = feature == features.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: _FeatureItem(feature: feature),
          ),
        );
      }).toList(),
    );
  }
}

/// 특징 아이템 카드
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.feature});

  final ProductFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(feature.icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 6),
          Text(
            feature.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 설명 섹션
// ─────────────────────────────────────────────────────────────────────────────

/// 상품 설명 텍스트 섹션 (재사용 가능)
class DescriptionSection extends StatelessWidget {
  const DescriptionSection({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상품 설명',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 하단 고정 액션 바
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // 장바구니 담기 버튼
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).addItem(
                      CartItem(
                        id: product.id,
                        name: product.name,
                        price: product.price,
                        quantity: 1,
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('장바구니에 추가되었습니다.'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.divider, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '장바구니 담기',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 바로 구매 버튼
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // 추후 결제 화면으로 이동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '바로 구매',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
