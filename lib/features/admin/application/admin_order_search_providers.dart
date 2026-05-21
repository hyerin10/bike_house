import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/orders/application/orders_notifier.dart';
import 'package:bike_house/features/orders/domain/order_model.dart';

/// 관리자 주문 탭 검색어
final adminOrderSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

List<OrderModel> filterAdminOrders(List<OrderModel> orders, String rawQuery) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) return orders;

  final digitQuery = q.replaceAll(RegExp(r'\D'), '');

  return orders.where((o) {
    if (o.orderNumber.toLowerCase().contains(q)) return true;
    if (o.customerName.toLowerCase().contains(q)) return true;
    if (o.customerPhone.toLowerCase().contains(q)) return true;
    if (digitQuery.isNotEmpty) {
      final phoneDigits = o.customerPhone.replaceAll(RegExp(r'\D'), '');
      if (phoneDigits.contains(digitQuery)) return true;
    }
    return false;
  }).toList();
}

/// [ordersProvider] 목록을 관리자 탭 검색어로 필터링한 비동기 값
final adminFilteredOrdersProvider =
    Provider<AsyncValue<List<OrderModel>>>((ref) {
  final async = ref.watch(ordersProvider);
  final query = ref.watch(adminOrderSearchQueryProvider);
  return async.when(
    data: (orders) => AsyncValue.data(filterAdminOrders(orders, query)),
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
