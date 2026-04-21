import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../cart/application/cart_controller.dart';
import '../../home/presentation/home_screen.dart';
import '../application/checkout_controller.dart';

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

  void _onContinue() {
    final checkout = ref.read(checkoutProvider);
    if (checkout.step == CheckoutStep.shipping) {
      if (_formKey.currentState?.validate() ?? false) {
        ref.read(checkoutProvider.notifier).nextStep();
      }
    } else {
      _showOrderCompleteDialog();
    }
  }

  void _showOrderCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 24),
            SizedBox(width: 8),
            Text('주문 완료'),
          ],
        ),
        content: const Text(
          '주문이 성공적으로 접수되었습니다.\n배송 현황은 마이페이지에서 확인하세요.',
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleOrderConfirmed(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('쇼핑 계속하기'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleOrderConfirmed(BuildContext dialogContext) {
    // 1. 다이얼로그 닫기
    Navigator.of(dialogContext).pop();

    // 2. 장바구니 초기화
    ref.read(cartProvider.notifier).clearCart();

    // 3. Checkout 상태 초기화
    ref.read(checkoutProvider.notifier).reset();

    // 4. 결제/장바구니 스택을 모두 제거하고 홈으로 이동
    //    mounted 체크로 위젯이 아직 트리에 있는지 확인
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);
    final isShipping = checkout.step == CheckoutStep.shipping;

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
                    : const _PaymentStep(key: ValueKey('payment')),
              ),

              const SizedBox(height: 24),

              // 주문 요약
              _OrderSummaryCard(state: checkout),

              const SizedBox(height: 20),

              // 다음 단계 버튼
              _ContinueButton(
                label: isShipping ? '결제 단계로 이동' : '주문 완료',
                onTap: _onContinue,
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
            checkout.step == CheckoutStep.shipping ? '배송 정보 입력' : '결제 방법 선택',
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
        const SizedBox(height: 16),
        const _DeliveryOptionsSection(),
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
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  controller: lastNameCtrl,
                  label: '성',
                  hint: '길동',
                  validator: _required,
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
            validator: _required,
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
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormField(
                  controller: zipCtrl,
                  label: '우편번호',
                  hint: '06234',
                  keyboardType: TextInputType.number,
                  validator: _required,
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
            validator: _required,
          ),
        ],
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? '필수 항목입니다' : null;
}

// ─── 배송 옵션 선택 ─────────────────────────────────────────────────────────

class _DeliveryOptionsSection extends ConsumerWidget {
  const _DeliveryOptionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(checkoutProvider).selectedDeliveryId;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.local_shipping_outlined,
            label: '배송 옵션',
          ),
          const SizedBox(height: 12),
          ...kDeliveryOptions.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DeliveryOptionTile(
                option: option,
                isSelected: option.id == selected,
                onTap: () =>
                    ref.read(checkoutProvider.notifier).selectDelivery(option.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOptionTile extends StatelessWidget {
  const _DeliveryOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final DeliveryOptionItem option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // 라디오 버튼
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // 배송 이름 + 소요 기간
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    option.duration,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // 배송비
            Text(
              option.formattedFee,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2: 결제 방법 선택
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentStep extends ConsumerWidget {
  const _PaymentStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(checkoutProvider).selectedPaymentId;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.payment_outlined, label: '결제 방법'),
          const SizedBox(height: 12),
          ...kPaymentMethods.map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaymentMethodTile(
                method: method,
                isSelected: method.id == selectedId,
                onTap: () => ref
                    .read(checkoutProvider.notifier)
                    .selectPayment(method.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethodItem method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              method.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
            ),
          ],
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
// 다음 단계 진행 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
