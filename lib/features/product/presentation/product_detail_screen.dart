import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../cart/application/cart_controller.dart';
import '../../checkout/presentation/checkout_screen.dart';
import '../application/product_detail_notifier.dart';
import '../data/product_model.dart';
import '../domain/product_model.dart';


// ─────────────────────────────────────────────────────────────────────────────
// 고정 특징 목록 (무료 배송 / 보증 / 반품)
// ─────────────────────────────────────────────────────────────────────────────

const _kDefaultFeatures = [
  ProductFeature(icon: Icons.local_shipping_outlined, label: '무료 배송'),
  ProductFeature(icon: Icons.shield_outlined, label: '2년 보증'),
  ProductFeature(icon: Icons.replay_outlined, label: '쉬운 반품'),
];

// ─────────────────────────────────────────────────────────────────────────────
// 상품 상세 화면
// ─────────────────────────────────────────────────────────────────────────────

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

      // 투명 앱바 (이미지 영역 위에 오버레이)
      appBar: _buildAppBar(context),

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
              // 상품 이미지 슬라이더
              _ProductImageSection(
                images: product.images,
                isBestSeller: product.isBestSeller,
              ),

              // 흰 카드 영역 (상품명 ~ 설명)
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품명 + 가격
                    _ProductInfo(product: product),

                    const SizedBox(height: 20),

                    // 특징 그리드 (고정)
                    const FeatureGrid(features: _kDefaultFeatures),

                    const SizedBox(height: 24),

                    // 상품 설명
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

      // 하단 고정 액션 바 (데이터 로드 후에만 표시)
      bottomNavigationBar: asyncProduct.valueOrNull != null
          ? _BottomActionBar(product: asyncProduct.valueOrNull!)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
// 상품 이미지 슬라이더
// ─────────────────────────────────────────────────────────────────────────────

class _ProductImageSection extends StatefulWidget {
  const _ProductImageSection({
    required this.images,
    required this.isBestSeller,
  });

  final List<ProductImageModel> images;
  final bool isBestSeller;

  @override
  State<_ProductImageSection> createState() => _ProductImageSectionState();
}

class _ProductImageSectionState extends State<_ProductImageSection> {
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // display_order 오름차순 정렬 (is_main=true 이미지가 display_order=0)
    final sorted = [...widget.images]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Stack(
      children: [
        // 이미지 슬라이더 (이미지 없으면 플레이스홀더)
        SizedBox(
          height: 300,
          width: double.infinity,
          child: sorted.isEmpty
              ? _buildPlaceholder()
              : PageView.builder(
                  controller: _pageController,
                  itemCount: sorted.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    return Image.network(
                      sorted[index].imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return _buildPlaceholder();
                      },
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    );
                  },
                ),
        ),

        // 베스트셀러 배지
        if (widget.isBestSeller)
          Positioned(
            top: 96,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

        // 페이지 인디케이터 (이미지 2장 이상일 때만 표시)
        if (sorted.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(sorted.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 100,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 호환성 배너 (재사용 가능 위젯)
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
// 상품 정보 (이름 / 가격)
// ─────────────────────────────────────────────────────────────────────────────

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});

  final ProductModel product;

  String _formatPrice(int price) {
    return '₩${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상품명
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),

        const SizedBox(height: 10),

        // 가격
        Text(
          _formatPrice(product.price),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),

        // 재고 부족 경고 (재고 10개 이하)
        if (product.stock != null && product.stock! <= 10) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDED),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '재고 ${product.stock}개 남음',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ],
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

  final ProductModel product;

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
                        id: product.id.toString(),
                        name: product.name,
                        price: product.price,
                        imageUrl: product.thumbnailUrl,
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
                final item = CartItem(
                  id: product.id.toString(),
                  name: product.name,
                  price: product.price,
                  imageUrl: product.thumbnailUrl,
                  quantity: 1,
                );
                ref.read(cartProvider.notifier).addItem(item);
                final subtotal = ref.read(cartProvider).totalAmount;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(subtotal: subtotal),
                  ),
                );
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
