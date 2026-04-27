import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/order_repository.dart';
import '../domain/order_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 상태 클래스: 입력값 + AsyncValue 결과를 함께 관리
// ─────────────────────────────────────────────────────────────────────────────

class OrderLookupState {
  const OrderLookupState({
    this.orderNumber = '',
    this.phoneNumber = '',
    this.orders = const AsyncValue.data([]),
  });

  final String orderNumber;
  final String phoneNumber;
  final AsyncValue<List<OrderModel>> orders;

  OrderLookupState copyWith({
    String? orderNumber,
    String? phoneNumber,
    AsyncValue<List<OrderModel>>? orders,
  }) {
    return OrderLookupState(
      orderNumber: orderNumber ?? this.orderNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      orders: orders ?? this.orders,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NotifierProvider: 입력 상태 + 주문 조회 결과 관리
// ─────────────────────────────────────────────────────────────────────────────

class OrderLookupNotifier extends Notifier<OrderLookupState> {
  OrderRepository get _repo =>
      OrderRepository(Supabase.instance.client);

  @override
  OrderLookupState build() => const OrderLookupState();

  void setOrderNumber(String value) {
    state = state.copyWith(orderNumber: value);
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value);
  }

  /// 주문번호와 전화번호로 Supabase에서 주문 내역을 조회합니다.
  Future<void> fetchMyOrders() async {
    if (state.orderNumber.trim().isEmpty || state.phoneNumber.trim().isEmpty) {
      return;
    }

    state = state.copyWith(orders: const AsyncValue.loading());

    final next = await AsyncValue.guard(
      () => _repo.fetchMyOrders(
        orderNumber: state.orderNumber,
        phoneNumber: state.phoneNumber,
      ),
    );

    state = state.copyWith(orders: next);
  }

  void reset() {
    state = const OrderLookupState();
  }
}

final orderLookupProvider =
    NotifierProvider<OrderLookupNotifier, OrderLookupState>(
  OrderLookupNotifier.new,
);
