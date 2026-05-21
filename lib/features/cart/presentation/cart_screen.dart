import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/cart/application/cart_controller.dart';
import 'package:bike_house/features/cart/presentation/widgets/cart_empty_view.dart';
import 'package:bike_house/features/cart/presentation/widgets/cart_header.dart';
import 'package:bike_house/features/cart/presentation/widgets/cart_items_section.dart';

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
          const CartHeader(),
          const SizedBox(height: 24),
          if (cartState.isEmpty)
            const CartEmptyView()
          else
            CartItemsSection(cartState: cartState),
        ],
      ),
    );
  }
}
