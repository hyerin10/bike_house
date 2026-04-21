import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 결제 단계
// ─────────────────────────────────────────────────────────────────────────────

enum CheckoutStep { shipping, payment }

// ─────────────────────────────────────────────────────────────────────────────
// 배송 옵션 모델 + Mock 데이터
// ─────────────────────────────────────────────────────────────────────────────

class DeliveryOptionItem {
  const DeliveryOptionItem({
    required this.id,
    required this.name,
    required this.duration,
    required this.fee,
  });

  final String id;
  final String name;
  final String duration;
  final int fee;

  String get formattedFee =>
      '₩${fee.toString().replaceAllMapped(_comma, (m) => '${m[1]},')}';

  static final _comma = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
}

const kDeliveryOptions = [
  DeliveryOptionItem(
    id: 'standard',
    name: '일반 배송',
    duration: '3~5일',
    fee: 9900,
  ),
  DeliveryOptionItem(
    id: 'express',
    name: '빠른 배송',
    duration: '1~2일',
    fee: 19900,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// 결제 방법 모델 + Mock 데이터
// ─────────────────────────────────────────────────────────────────────────────

class PaymentMethodItem {
  const PaymentMethodItem({required this.id, required this.name});

  final String id;
  final String name;
}

const kPaymentMethods = [
  PaymentMethodItem(id: 'card', name: '신용카드 / 체크카드'),
  PaymentMethodItem(id: 'kakao', name: '카카오페이'),
  PaymentMethodItem(id: 'naver', name: '네이버페이'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Checkout 상태
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutState {
  const CheckoutState({
    this.step = CheckoutStep.shipping,
    this.selectedDeliveryId = 'standard',
    this.selectedPaymentId = 'card',
    this.subtotal = 0,
  });

  final CheckoutStep step;
  final String selectedDeliveryId;
  final String selectedPaymentId;
  final int subtotal;

  DeliveryOptionItem get selectedDelivery =>
      kDeliveryOptions.firstWhere((o) => o.id == selectedDeliveryId);

  int get shippingFee => selectedDelivery.fee;
  int get total => subtotal + shippingFee;

  String _fmt(int value) =>
      '₩${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String get formattedSubtotal => _fmt(subtotal);
  String get formattedShipping => _fmt(shippingFee);
  String get formattedTotal => _fmt(total);

  CheckoutState copyWith({
    CheckoutStep? step,
    String? selectedDeliveryId,
    String? selectedPaymentId,
    int? subtotal,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      selectedDeliveryId: selectedDeliveryId ?? this.selectedDeliveryId,
      selectedPaymentId: selectedPaymentId ?? this.selectedPaymentId,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkout 컨트롤러
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void setSubtotal(int amount) =>
      state = state.copyWith(subtotal: amount);

  void selectDelivery(String id) =>
      state = state.copyWith(selectedDeliveryId: id);

  void selectPayment(String id) =>
      state = state.copyWith(selectedPaymentId: id);

  void nextStep() {
    if (state.step == CheckoutStep.shipping) {
      state = state.copyWith(step: CheckoutStep.payment);
    }
  }

  void previousStep() {
    if (state.step == CheckoutStep.payment) {
      state = state.copyWith(step: CheckoutStep.shipping);
    }
  }

  /// 결제 완료 후 상태 초기화 (다음 주문을 위해)
  void reset() => state = const CheckoutState();
}

/// Checkout 프로바이더
final checkoutProvider = NotifierProvider<CheckoutController, CheckoutState>(
  CheckoutController.new,
);
