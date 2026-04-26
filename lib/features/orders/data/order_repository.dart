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
}
