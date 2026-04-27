import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../cart/application/cart_controller.dart';
import '../application/checkout_controller.dart';
import '../application/order_notifier.dart';
import '../../orders/application/local_orders_notifier.dart';
import '../../orders/domain/order_model.dart';
import '../../product/application/popular_parts_controller.dart';
import '../../product/application/product_detail_notifier.dart';
import '../../product/application/product_notifier.dart';
import 'order_success_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 결제 화면 (ConsumerStatefulWidget — TextEditingController 관리 필요)
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.subtotal});

  final int subtotal;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const _bankAccountText = 'xxx-xxxxx-xxxx oo은행 kkk';
  final _formKey = GlobalKey<FormState>();

  // 배송지 입력 컨트롤러
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 소계 금액 주입
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
    } else {
      final cart = ref.read(cartProvider);
      final customerName =
          '${_firstNameCtrl.text.trim()}${_lastNameCtrl.text.trim()}';
      final shippingAddress =
          '${_addressCtrl.text.trim()}, ${_cityCtrl.text.trim()}, ${_zipCtrl.text.trim()}';
      final phoneDigitsOnly =
          _phoneCtrl.text.trim().replaceAll(RegExp(r'[\s\-]'), '');
      final orderNumber =
          await ref.read(orderControllerProvider.notifier).placeOrder(
                items: cart.items,
                totalAmount: checkout.total,
                customerName: customerName,
                customerPhone: phoneDigitsOnly,
                shippingAddress: shippingAddress,
              );

      final orderState = ref.read(orderControllerProvider);
      if (orderState.hasError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_toErrorMessage(orderState.error)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // 주문 성공 후 재고/상품 정보 캐시 무효화
      ref.invalidate(productProvider);
      ref.invalidate(popularPartsControllerProvider);
      for (final item in cart.items) {
        final productId = int.tryParse(item.id);
        if (productId != null) {
          ref.invalidate(productDetailProvider(productId));
        }
      }

      ref.read(cartProvider.notifier).clearCart();
      ref.read(checkoutProvider.notifier).reset();

      final orderId = int.tryParse(orderNumber.split('-').last) ?? 0;
      final now = DateTime.now();
      final localOrder = OrderModel(
        id: orderId,
        customerName: customerName,
        customerPhone: phoneDigitsOnly,
        shippingAddress: shippingAddress,
        totalAmount: checkout.total,
        status: 'pending',
        createdAt: now,
        orderItems: [
          for (var i = 0; i < cart.items.length; i++)
            OrderItemModel(
              id: i + 1,
              orderId: orderId,
              productId: int.tryParse(cart.items[i].id) ?? 0,
              quantity: cart.items[i].quantity,
              unitPrice: cart.items[i].price,
              products: OrderItemProduct(name: cart.items[i].name),
            ),
        ],
      );
      await ref.read(localOrdersProvider.notifier).addOrder(localOrder);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
      );
    }
  }

  String _toErrorMessage(Object? error) {
    if (error == null) return '주문 처리에 실패했습니다.';
    final message = error.toString();
    if (message.contains('INSUFFICIENT_STOCK')) {
      return '재고가 부족한 상품이 있어 주문할 수 없습니다.';
    }
    return message.replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);
    final isShipping = checkout.step == CheckoutStep.shipping;
    final isOrdering = ref.watch(orderControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref, checkout),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 단계 진행 인디케이터
              _StepProgressBar(currentStep: checkout.step),

              const SizedBox(height: 24),

              // 단계별 콘텐츠
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: isShipping
                    ? _ShippingStep(
                        key: const ValueKey('shipping'),
                        firstNameCtrl: _firstNameCtrl,
                        lastNameCtrl: _lastNameCtrl,
                        addressCtrl: _addressCtrl,
                        cityCtrl: _cityCtrl,
                        zipCtrl: _zipCtrl,
                        phoneCtrl: _phoneCtrl,
                      )
                    : _PaymentStep(
                        key: const ValueKey('payment'),
                        totalPriceText: checkout.formattedTotal,
                      ),
              ),

              const SizedBox(height: 24),

              // 주문 요약
              _OrderSummaryCard(state: checkout),

              const SizedBox(height: 20),

              // 다음 단계 버튼
              _ContinueButton(
                label: isShipping ? '결제 단계로 이동' : '주문 완료',
                onTap: isOrdering ? null : _onContinue,
                isLoading: isOrdering,
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkout,
  ) {
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

// ─────────────────────────────────────────────────────────────────────────────
// 단계 진행 인디케이터
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.currentStep});

  final CheckoutStep currentStep;

  @override
  Widget build(BuildContext context) {
    final isShipping = currentStep == CheckoutStep.shipping;

    return Row(
      children: [
        _StepCircle(number: 1, label: '배송', isActive: true),
        Expanded(
          child: Container(
            height: 2,
            color: isShipping ? AppColors.divider : AppColors.primary,
          ),
        ),
        _StepCircle(number: 2, label: '결제', isActive: !isShipping),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
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

// ─────────────────────────────────────────────────────────────────────────────
// Step 1: 배송지 폼 + 배송 옵션
// ─────────────────────────────────────────────────────────────────────────────

class _ShippingStep extends StatelessWidget {
  const _ShippingStep({
    super.key,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.zipCtrl,
    required this.phoneCtrl,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController zipCtrl;
  final TextEditingController phoneCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShippingAddressSection(
          firstNameCtrl: firstNameCtrl,
          lastNameCtrl: lastNameCtrl,
          addressCtrl: addressCtrl,
          cityCtrl: cityCtrl,
          zipCtrl: zipCtrl,
          phoneCtrl: phoneCtrl,
        ),
      ],
    );
  }
}

// ─── 배송지 주소 입력 폼 ────────────────────────────────────────────────────

class _ShippingAddressSection extends StatelessWidget {
  const _ShippingAddressSection({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.zipCtrl,
    required this.phoneCtrl,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController zipCtrl;
  final TextEditingController phoneCtrl;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.location_on_outlined, label: '배송 주소'),
          const SizedBox(height: 16),

          // 이름 (2열)
          Row(
            children: [
              Expanded(
                child: _FormField(
                  controller: firstNameCtrl,
                  label: '이름',
                  hint: '홍',
                  validator: _validateName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  controller: lastNameCtrl,
                  label: '성',
                  hint: '길동',
                  validator: _validateName,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 주소
          _FormField(
            controller: addressCtrl,
            label: '주소',
            hint: '서울시 강남구 테헤란로 123',
            validator: _validateAddress,
          ),

          const SizedBox(height: 12),

          // 도시 + 우편번호 (2열)
          Row(
            children: [
              Expanded(
                child: _FormField(
                  controller: cityCtrl,
                  label: '도시',
                  hint: '서울',
                  validator: _validateCity,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  controller: zipCtrl,
                  label: '우편번호',
                  hint: '06234',
                  keyboardType: TextInputType.number,
                  validator: _validateZip,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 전화번호
          _FormField(
            controller: phoneCtrl,
            label: '전화번호',
            hint: '010-1234-5678',
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
        ],
      ),
    );
  }

  /// 이름/성: 한글·영문 1~10자
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return '필수 항목입니다.';
    final trimmed = v.trim();
    if (trimmed.length > 10) return '10자 이내로 입력해주세요.';
    if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(trimmed)) {
      return '한글 또는 영문만 입력 가능합니다.';
    }
    return null;
  }

  /// 주소: 5자 이상
  String? _validateAddress(String? v) {
    if (v == null || v.trim().isEmpty) return '주소를 입력해주세요.';
    if (v.trim().length < 5) return '정확한 주소를 입력해주세요. (5자 이상)';
    return null;
  }

  /// 도시: 한글·영문
  String? _validateCity(String? v) {
    if (v == null || v.trim().isEmpty) return '도시를 입력해주세요.';
    if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(v.trim())) {
      return '한글 또는 영문만 입력 가능합니다.';
    }
    return null;
  }

  /// 우편번호: 숫자 5자리
  String? _validateZip(String? v) {
    if (v == null || v.trim().isEmpty) return '우편번호를 입력해주세요.';
    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length != 5) return '5자리 숫자로 입력해주세요.';
    return null;
  }

  /// 전화번호: 010으로 시작하는 11자리
  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return '전화번호를 입력해주세요.';
    final digits = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^010\d{8}$').hasMatch(digits)) {
      return '010으로 시작하는 11자리 번호를 입력해주세요. (예: 010-1234-5678)';
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2: 결제 방법 선택
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    super.key,
    required this.totalPriceText,
  });

  final String totalPriceText;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.account_balance_outlined, label: '계좌 입금 안내'),
          const SizedBox(height: 12),
          _BankNoticeRow(
            label: '입금 계좌',
            value: _CheckoutScreenState._bankAccountText,
          ),
          const SizedBox(height: 10),
          _BankNoticeRow(label: '총 결제 금액', value: totalPriceText),
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

class _BankNoticeRow extends StatelessWidget {
  const _BankNoticeRow({required this.label, required this.value});

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

// ─────────────────────────────────────────────────────────────────────────────
// 다음 단계 진행 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final Future<void> Function()? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap == null || isLoading
            ? null
            : () async {
                await onTap!.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 주문 요약 카드
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        children: [
          _SummaryRow(label: '상품 금액', value: state.formattedSubtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: '배송비', value: state.formattedShipping),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _SummaryRow(
            label: '총 결제 금액',
            value: state.formattedTotal,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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

// ─────────────────────────────────────────────────────────────────────────────
// 공통 섹션 카드
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 공통 섹션 타이틀 (아이콘 + 레이블)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 공통 입력 필드
// ─────────────────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textHint,
                ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}
