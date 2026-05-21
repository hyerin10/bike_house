import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/checkout/application/checkout_controller.dart';
import 'package:bike_house/features/checkout/application/checkout_order_completion.dart';
import 'package:bike_house/features/checkout/application/order_notifier.dart';
import 'package:bike_house/features/checkout/presentation/order_success_screen.dart';
import 'package:bike_house/features/checkout/presentation/widgets/checkout_app_bar.dart';
import 'package:bike_house/features/checkout/presentation/widgets/checkout_shared_widgets.dart';
import 'package:bike_house/features/checkout/presentation/widgets/checkout_step_progress.dart';
import 'package:bike_house/features/checkout/presentation/widgets/order_summary_card.dart';
import 'package:bike_house/features/checkout/presentation/widgets/payment_step.dart';
import 'package:bike_house/features/checkout/presentation/widgets/shipping_address_section.dart';

/// 결제 화면 (`TextEditingController` 보관을 위해 `ConsumerStatefulWidget`)
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.subtotal});

  final int subtotal;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).setSubtotal(widget.subtotal);
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final checkout = ref.read(checkoutProvider);
    if (checkout.step == CheckoutStep.shipping) {
      if (_formKey.currentState?.validate() ?? false) {
        ref.read(checkoutProvider.notifier).nextStep();
      }
      return;
    }

    final customerName =
        '${_firstNameCtrl.text.trim()}${_lastNameCtrl.text.trim()}';
    final shippingAddress =
        '${_addressCtrl.text.trim()}, ${_cityCtrl.text.trim()}, ${_zipCtrl.text.trim()}';
    final phoneDigitsOnly =
        _phoneCtrl.text.trim().replaceAll(RegExp(r'[\s\-]'), '');

    final result = await completeCheckoutOrder(
      ref,
      totalAmount: checkout.total,
      customerName: customerName,
      customerPhone: phoneDigitsOnly,
      shippingAddress: shippingAddress,
    );

    if (!mounted) return;

    switch (result) {
      case CheckoutOrderCompletionFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case CheckoutOrderCompletionSuccess():
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);
    final isShipping = checkout.step == CheckoutStep.shipping;
    final isOrdering = ref.watch(orderControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CheckoutAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckoutStepProgressBar(currentStep: checkout.step),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: isShipping
                    ? ShippingAddressSection(
                        key: const ValueKey('shipping'),
                        firstNameCtrl: _firstNameCtrl,
                        lastNameCtrl: _lastNameCtrl,
                        addressCtrl: _addressCtrl,
                        cityCtrl: _cityCtrl,
                        zipCtrl: _zipCtrl,
                        phoneCtrl: _phoneCtrl,
                      )
                    : CheckoutPaymentStep(
                        key: const ValueKey('payment'),
                        totalPriceText: checkout.formattedTotal,
                      ),
              ),
              const SizedBox(height: 24),
              CheckoutOrderSummaryCard(state: checkout),
              const SizedBox(height: 20),
              CheckoutContinueButton(
                label: isShipping ? '결제 단계로 이동' : '주문 완료',
                onPressed: isOrdering ? null : _onContinue,
                isLoading: isOrdering,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
