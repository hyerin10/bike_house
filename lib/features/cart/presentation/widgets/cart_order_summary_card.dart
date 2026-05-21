import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/auth_guard.dart';
import 'package:bike_house/core/utils/format_krw.dart';
import 'package:bike_house/features/cart/application/cart_controller.dart';
import 'package:bike_house/features/checkout/presentation/checkout_screen.dart';

class CartOrderSummaryCard extends ConsumerWidget {
  const CartOrderSummaryCard({super.key, required this.cartState});

  final CartState cartState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _SummaryRow(
              label: '상품 수',
              value: '${cartState.totalItemCount}개',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: '총 금액',
              value: formatKrw(cartState.totalAmount),
              isHighlighted: true,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => requireAuth(context, ref, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CheckoutScreen(subtotal: cartState.totalAmount),
                    ),
                  );
                }),
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
