import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 주문 상품의 products 테이블 조인 결과 (이름만 필요)
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class OrderItemProduct with _$OrderItemProduct {
  const factory OrderItemProduct({
    required String name,
  }) = _OrderItemProduct;

  factory OrderItemProduct.fromJson(Map<String, dynamic> json) =>
      _$OrderItemProductFromJson(json);
}

// ─────────────────────────────────────────────────────────────────────────────
// order_items 테이블 모델
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class OrderItemModel with _$OrderItemModel {
  const OrderItemModel._();

  const factory OrderItemModel({
    required int id,
    @JsonKey(name: 'order_id') required int orderId,
    @JsonKey(name: 'product_id') required int productId,
    required int quantity,
    @JsonKey(name: 'unit_price') required int unitPrice,
    OrderItemProduct? products,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  String get productName => products?.name ?? '상품 #$productId';
}

// ─────────────────────────────────────────────────────────────────────────────
// orders 테이블 모델 (order_items + products 조인 포함)
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class OrderModel with _$OrderModel {
  const OrderModel._();

  const factory OrderModel({
    required int id,
    @JsonKey(name: 'customer_name') required String customerName,
    @JsonKey(name: 'customer_phone') required String customerPhone,
    @JsonKey(name: 'shipping_address') required String shippingAddress,
    @JsonKey(name: 'total_amount') required int totalAmount,
    @Default('pending') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'order_items') @Default([]) List<OrderItemModel> orderItems,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  /// ORD-YYYY-NNN 형식의 주문 번호
  String get orderNumber {
    final year = createdAt?.year ?? DateTime.now().year;
    return 'ORD-$year-${id.toString().padLeft(3, '0')}';
  }

  /// 주문 취소 가능 여부 (completed / cancelled 상태 제외)
  bool get isCancellable =>
      status != 'completed' && status != 'cancelled';

  /// 입금 확인 가능 여부 (pending 상태일 때만)
  bool get isPaymentConfirmable => status == 'pending';
}
