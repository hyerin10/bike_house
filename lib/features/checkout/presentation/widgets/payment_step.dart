import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/checkout/application/checkout_constants.dart';
import 'package:bike_house/features/checkout/presentation/widgets/checkout_shared_widgets.dart';

class CheckoutPaymentStep extends StatelessWidget {
  const CheckoutPaymentStep({
    super.key,
    required this.totalPriceText,
  });

  final String totalPriceText;

  @override
  Widget build(BuildContext context) {
    return CheckoutSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CheckoutSectionTitle(
            icon: Icons.account_balance_outlined,
            label: '계좌 입금 안내',
          ),
          const SizedBox(height: 12),
          const CheckoutBankNoticeRow(
            label: '입금 계좌',
            value: kBankAccountDisplayText,
          ),
          const SizedBox(height: 10),
          CheckoutBankNoticeRow(label: '총 결제 금액', value: totalPriceText),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Text(
              '1시간 이내에 입금을 해주셔야 하며, 입금 확인되지 않을 시 주문이 자동 취소됩니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9A3412),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutBankNoticeRow extends StatelessWidget {
  const CheckoutBankNoticeRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
