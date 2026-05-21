import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/widgets/app_floating_snackbar.dart';
import 'package:bike_house/features/cart/application/cart_controller.dart';
import 'package:bike_house/features/checkout/presentation/checkout_screen.dart';
import 'package:bike_house/features/product/data/product_model.dart';
import 'package:bike_house/features/product/data/product_model_cart.dart';

class ProductDetailBottomActionBar extends ConsumerWidget {
  const ProductDetailBottomActionBar({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartItem = cartState.items
        .where((e) => e.id == product.id.toString())
        .firstOrNull;
    final cartQty = cartItem?.quantity ?? 0;
    final isOutOfStock = product.stock != null && cartQty >= product.stock!;

    void showStockSnackBar() {
      showAppFloatingSnackBar(
        context,
        '재고가 부족합니다.',
        backgroundColor: Colors.red.shade700,
      );
    }

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
          Expanded(
            child: OutlinedButton(
              onPressed: isOutOfStock
                  ? null
                  : () {
                      final success = ref
                          .read(cartProvider.notifier)
                          .addItem(product.toCartItem());
                      if (success) {
                        showAppFloatingSnackBar(
                          context,
                          '장바구니에 추가되었습니다.',
                        );
                      } else {
                        showStockSnackBar();
                      }
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isOutOfStock ? AppColors.textHint : AppColors.textPrimary,
                side: BorderSide(
                  color: isOutOfStock
                      ? AppColors.divider.withValues(alpha: 0.4)
                      : AppColors.divider,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isOutOfStock ? '재고 소진' : '장바구니 담기',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isOutOfStock ? AppColors.textHint : null,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isOutOfStock
                  ? null
                  : () {
                      final success = ref
                          .read(cartProvider.notifier)
                          .addItem(product.toCartItem());
                      if (!success) {
                        showStockSnackBar();
                        return;
                      }
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
