import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../cart/application/cart_controller.dart';

/// 주문 생성 + 재고 차감 RPC를 호출하는 Notifier
///
/// 성공 시 생성된 주문번호(예: ORD-2026-001)를 상태로 보관합니다.
class OrderNotifier extends AsyncNotifier<String?> {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<String?> build() async => null;

  Future<String> placeOrder({
    required List<CartItem> items,
    required int totalAmount,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (items.isEmpty) {
        throw Exception('장바구니가 비어 있습니다.');
      }

      final payload = items.map((item) {
        final productId = int.tryParse(item.id);
        if (productId == null) {
          throw Exception('잘못된 상품 ID가 포함되어 있습니다.');
        }
        return {
          'product_id': productId,
          'quantity': item.quantity,
          'unit_price': item.price,
        };
      }).toList();

      final result = await _client.rpc(
        'create_order_with_stock_check',
        params: {
          'p_customer_name': customerName,
          'p_customer_phone': customerPhone,
          'p_shipping_address': shippingAddress,
          'p_total_amount': totalAmount,
          'p_items': payload,
        },
      );

      final isSuccess = result == true;
      if (!isSuccess) {
        throw Exception('주문 처리에 실패했습니다. 잠시 후 다시 시도해주세요.');
      }

      final orderRow = await _client
          .from('orders')
          .select('id, created_at')
          .eq('customer_name', customerName)
          .eq('customer_phone', customerPhone)
          .eq('shipping_address', shippingAddress)
          .eq('total_amount', totalAmount)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (orderRow == null) {
        throw Exception('주문은 완료되었지만 주문번호를 가져오지 못했습니다.');
      }

      final id = orderRow['id'] as int?;
      if (id == null) {
        throw Exception('주문번호를 생성할 수 없습니다.');
      }

      final createdAtRaw = orderRow['created_at'] as String?;
      final year =
          DateTime.tryParse(createdAtRaw ?? '')?.year ?? DateTime.now().year;
      return 'ORD-$year-${id.toString().padLeft(3, '0')}';
    });

    final orderNumber = state.value;
    if (orderNumber == null) {
      throw Exception('주문번호를 가져오지 못했습니다.');
    }
    return orderNumber;
  }
}

final orderControllerProvider =
    AsyncNotifierProvider<OrderNotifier, String?>(OrderNotifier.new);
