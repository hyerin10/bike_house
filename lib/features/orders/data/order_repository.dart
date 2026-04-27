import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/order_model.dart';

/// orders 테이블에 대한 Supabase 데이터 접근 레이어
class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient _client;

  /// 모든 주문을 최신순으로 가져옵니다.
  /// order_items 와 각 item 의 products(name) 을 함께 조인합니다.
  Future<List<OrderModel>> fetchOrders() async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products(name))')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// cancel_order RPC를 호출해 주문을 취소하고 재고를 복원합니다.
  /// 트랜잭션 실패 시 PostgreSQL 예외가 그대로 throw됩니다.
  Future<void> cancelOrder(int orderId) async {
    await _client.rpc('cancel_order', params: {'p_order_id': orderId});
  }

  /// confirm_payment RPC를 호출해 주문 상태를 paid로 변경합니다.
  /// 트랜잭션 실패 시 PostgreSQL 예외가 그대로 throw됩니다.
  Future<void> confirmPayment(int orderId) async {
    await _client.rpc('confirm_payment', params: {'p_order_id': orderId});
  }

  /// 비회원 주문 조회: 주문번호(ORD-YYYY-NNN 형식)와 전화번호가 일치하는 주문을 반환합니다.
  /// 주문번호에서 ID를 파싱하여 customer_phone과 함께 Supabase에서 조회합니다.
  Future<List<OrderModel>> fetchMyOrders({
    required String orderNumber,
    required String phoneNumber,
  }) async {
    final trimmedOrder = orderNumber.trim();
    final trimmedPhone = phoneNumber.trim();

    // ORD-YYYY-NNN 형식 파싱, 실패 시 숫자 직접 파싱 시도
    int? orderId;
    final parts = trimmedOrder.split('-');
    if (parts.length == 3 && parts[0] == 'ORD') {
      orderId = int.tryParse(parts[2]);
    } else {
      orderId = int.tryParse(trimmedOrder);
    }

    if (orderId == null) return [];

    final response = await _client
        .from('orders')
        .select('*, order_items(*, products(name))')
        .eq('id', orderId)
        .eq('customer_phone', trimmedPhone);

    return (response as List)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
