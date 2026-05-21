import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/checkout/application/checkout_controller.dart';

class CheckoutStepProgressBar extends StatelessWidget {
  const CheckoutStepProgressBar({super.key, required this.currentStep});

  final CheckoutStep currentStep;

  @override
  Widget build(BuildContext context) {
    final isShipping = currentStep == CheckoutStep.shipping;

    return Row(
      children: [
        const CheckoutStepCircle(number: 1, label: '배송', isActive: true),
        Expanded(
          child: Container(
            height: 2,
            color: isShipping ? AppColors.divider : AppColors.primary,
          ),
        ),
        CheckoutStepCircle(number: 2, label: '결제', isActive: !isShipping),
      ],
    );
  }
}

class CheckoutStepCircle extends StatelessWidget {
  const CheckoutStepCircle({
    super.key,
    required this.number,
    required this.label,
    required this.isActive,
  });

  final int number;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textHint,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? AppColors.primary : AppColors.textHint,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ],
    );
  }
}
