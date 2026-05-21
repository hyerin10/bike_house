import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/checkout/application/checkout_controller.dart';

class CheckoutAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CheckoutAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () {
          if (checkout.step == CheckoutStep.payment) {
            ref.read(checkoutProvider.notifier).previousStep();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('결제', style: Theme.of(context).textTheme.titleLarge),
          Text(
            checkout.step == CheckoutStep.shipping ? '배송 정보 입력' : '계좌 입금 안내',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
