// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemProductImpl _$$OrderItemProductImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderItemProductImpl(
      name: json['name'] as String,
    );

Map<String, dynamic> _$$OrderItemProductImplToJson(
        _$OrderItemProductImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

_$OrderItemModelImpl _$$OrderItemModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemModelImpl(
      id: (json['id'] as num).toInt(),
      orderId: (json['order_id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toInt(),
      products: json['products'] == null
          ? null
          : OrderItemProduct.fromJson(json['products'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$OrderItemModelImplToJson(
        _$OrderItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'products': instance.products,
    };

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: (json['id'] as num).toInt(),
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      shippingAddress: json['shipping_address'] as String,
      totalAmount: (json['total_amount'] as num).toInt(),
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      orderItems: (json['order_items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'shipping_address': instance.shippingAddress,
      'total_amount': instance.totalAmount,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'order_items': instance.orderItems,
    };
