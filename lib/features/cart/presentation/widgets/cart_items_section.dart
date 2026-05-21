import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/cart/application/cart_controller.dart';
import 'package:bike_house/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:bike_house/features/cart/presentation/widgets/cart_order_summary_card.dart';

class CartItemsSection extends ConsumerWidget {
  const CartItemsSection({super.key, required this.cartState});

  final CartState cartState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = cartState.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                CartItemCard(item: items[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        CartOrderSummaryCard(cartState: cartState),
        const SizedBox(height: 32),
      ],
    );
  }
}
