import 'package:flutter/material.dart';

import 'package:bike_house/features/cart/presentation/widgets/empty_state_view.dart';

class CartEmptyView extends StatelessWidget {
  const CartEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

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
