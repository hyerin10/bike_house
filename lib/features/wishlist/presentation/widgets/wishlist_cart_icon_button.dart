import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/cart/application/cart_controller.dart';
import 'package:bike_house/features/product/data/product_model.dart';

/// 위시리스트 행에서 장바구니에 담는 원형 버튼
class WishlistCartIconButton extends ConsumerWidget {
  const WishlistCartIconButton({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final success = ref.read(cartProvider.notifier).addItem(
              CartItem(
                id: product.id.toString(),
                name: product.name,
                price: product.price,
                imageUrl: product.thumbnailUrl,
                quantity: 1,
                stock: product.stock,
              ),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '장바구니에 추가되었습니다.' : '재고가 부족합니다.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: success ? null : Colors.red.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
