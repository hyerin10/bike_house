import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../checkout/presentation/checkout_screen.dart';
import '../application/cart_controller.dart';

/// 장바구니 화면
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // 헤더
          const _CartHeader(),

          const SizedBox(height: 24),

          // 상태에 따라 빈 화면 또는 아이템 목록 분기
          if (cartState.isEmpty)
            const _EmptyCartView()
          else
            _CartItemsView(cartState: cartState),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 헤더: 타이틀 + 서브타이틀
// ─────────────────────────────────────────────────────────────────────────────

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '장바구니',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 2),
          Text(
            '쇼핑하신 부품들을 확인하세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 빈 장바구니 뷰
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.55,
      child: const Center(
        child: EmptyStateView(
          icon: Icons.shopping_bag_outlined,
          title: '장바구니가 비어 있습니다.',
          subtitle: '부품을 추가하여 쇼핑을 시작해보세요.',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 재사용 가능한 빈 상태 뷰 위젯
// ─────────────────────────────────────────────────────────────────────────────

/// 아이템이 없을 때 표시하는 공통 Empty State 위젯
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아이콘 컨테이너
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 42,
            color: AppColors.textHint,
          ),
        ),

        const SizedBox(height: 20),

        // 메인 텍스트
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // 서브 텍스트
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 장바구니 아이템 목록 뷰 (상품이 있을 때)
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemsView extends ConsumerWidget {
  const _CartItemsView({required this.cartState});

  final CartState cartState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아이템 목록
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartState.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _CartItemCard(item: cartState.items[index]);
            },
          ),
        ),

        const SizedBox(height: 24),

        // 결제 요약 카드
        _OrderSummaryCard(cartState: cartState),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 개별 장바구니 아이템 카드
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(cartProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // 상품 이미지 영역
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: AppColors.textHint,
            ),
          ),

          const SizedBox(width: 12),

          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₩${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 수량 조절 + 삭제
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 삭제 버튼
              GestureDetector(
                onTap: () => controller.removeItem(item.id),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ),

              const SizedBox(height: 8),

              // 수량 조절
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onTap: () =>
                        controller.updateQuantity(item.id, item.quantity - 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    isDisabled: item.isAtStockLimit,
                    onTap: () {
                      final success = controller.updateQuantity(
                        item.id,
                        item.quantity + 1,
                      );
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('재고가 부족합니다.'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 수량 조절 버튼
class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.background : null,
          border: Border.all(
            color: isDisabled ? AppColors.divider.withOpacity(0.4) : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDisabled ? AppColors.textHint : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 주문 요약 카드
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.cartState});

  final CartState cartState;

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주문 요약',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 14),

            // 총 상품 수
            _SummaryRow(
              label: '상품 수',
              value: '${cartState.totalItemCount}개',
            ),

            const SizedBox(height: 8),

            // 총 금액
            _SummaryRow(
              label: '총 금액',
              value: '₩${_formatPrice(cartState.totalAmount)}',
              isHighlighted: true,
            ),

            const SizedBox(height: 18),

            // 결제하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CheckoutScreen(subtotal: cartState.totalAmount),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '결제하기',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: isHighlighted
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  )
              : Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
