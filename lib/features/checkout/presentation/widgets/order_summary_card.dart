import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/checkout/application/checkout_controller.dart';
import 'package:bike_house/features/checkout/presentation/widgets/checkout_shared_widgets.dart';

class CheckoutOrderSummaryCard extends StatelessWidget {
  const CheckoutOrderSummaryCard({super.key, required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    return CheckoutSectionCard(
      child: Column(
        children: [
          CheckoutSummaryRow(label: '상품 금액', value: state.formattedSubtotal),
          const SizedBox(height: 8),
          CheckoutSummaryRow(label: '배송비', value: state.formattedShipping),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          CheckoutSummaryRow(
            label: '총 결제 금액',
            value: state.formattedTotal,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }
}

class CheckoutSummaryRow extends StatelessWidget {
  const CheckoutSummaryRow({
    super.key,
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
          style: isHighlighted
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: isHighlighted
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  )
              : Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
