import 'package:flutter/material.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({super.key});

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
