import 'package:bike_house/features/cart/application/cart_controller.dart';
import 'package:bike_house/features/product/data/product_model.dart';

extension ProductModelCartX on ProductModel {
  CartItem toCartItem({int quantity = 1}) {
    return CartItem(
      id: id.toString(),
      name: name,
      price: price,
      imageUrl: thumbnailUrl,
      quantity: quantity,
      stock: stock,
    );
  }
}
