import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/cart/application/cart_controller.dart';
import 'package:bike_house/features/checkout/application/checkout_controller.dart';
import 'package:bike_house/features/checkout/application/order_notifier.dart';
import 'package:bike_house/features/orders/application/local_orders_notifier.dart';
import 'package:bike_house/features/orders/domain/order_model.dart';
import 'package:bike_house/features/product/application/popular_parts_controller.dart';
import 'package:bike_house/features/product/application/product_detail_notifier.dart';
import 'package:bike_house/features/product/application/product_notifier.dart';

/// 주문 완료 후처리(캐시 무효화·로컬 주문 반영)까지의 결과
sealed class CheckoutOrderCompletionResult {
  const CheckoutOrderCompletionResult();
}

final class CheckoutOrderCompletionSuccess extends CheckoutOrderCompletionResult {
  const CheckoutOrderCompletionSuccess();
}

final class CheckoutOrderCompletionFailure extends CheckoutOrderCompletionResult {
  const CheckoutOrderCompletionFailure(this.message);

  final String message;
}

String formatCheckoutOrderError(Object? error) {
  if (error == null) return '주문 처리에 실패했습니다.';
  final message = error.toString();
  if (message.contains('INSUFFICIENT_STOCK')) {
    return '재고가 부족한 상품이 있어 주문할 수 없습니다.';
  }
  return message.replaceFirst('Exception: ', '');
}

/// 결제 단계에서 주문 확정: RPC 호출 → 성공 시 캐시/장바구니/체크아웃 정리 및 로컬 주문 저장
Future<CheckoutOrderCompletionResult> completeCheckoutOrder(
  WidgetRef ref, {
  required int totalAmount,
  required String customerName,
  required String customerPhone,
  required String shippingAddress,
}) async {
  final cart = ref.read(cartProvider);

  String orderNumber;
  try {
    orderNumber = await ref.read(orderControllerProvider.notifier).placeOrder(
          items: cart.items,
          totalAmount: totalAmount,
          customerName: customerName,
          customerPhone: customerPhone,
          shippingAddress: shippingAddress,
        );
  } catch (e) {
    return CheckoutOrderCompletionFailure(formatCheckoutOrderError(e));
  }

  final orderState = ref.read(orderControllerProvider);
  if (orderState.hasError) {
    return CheckoutOrderCompletionFailure(
      formatCheckoutOrderError(orderState.error),
    );
  }

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
    customerPhone: customerPhone,
    shippingAddress: shippingAddress,
    totalAmount: totalAmount,
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

  return const CheckoutOrderCompletionSuccess();
}
