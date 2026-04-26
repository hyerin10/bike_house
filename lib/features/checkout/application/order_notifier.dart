import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../cart/application/cart_controller.dart';

/// 주문 생성 + 재고 차감 RPC를 호출하는 Notifier
class OrderNotifier extends AsyncNotifier<void> {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<void> build() async {}

  Future<void> placeOrder({
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
    });
  }
}

final orderControllerProvider =
    AsyncNotifierProvider<OrderNotifier, void>(OrderNotifier.new);
