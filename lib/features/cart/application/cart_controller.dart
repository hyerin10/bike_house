import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 장바구니 개별 아이템 모델
class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.stock,
  });

  final String id;
  final String name;
  final int price;
  final int quantity;
  final String? imageUrl;

  /// 상품 총 재고 수량 (null이면 재고 제한 없음)
  final int? stock;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      stock: stock,
    );
  }

  int get totalPrice => price * quantity;

  /// 현재 수량이 재고 한도에 도달했는지 여부
  bool get isAtStockLimit => stock != null && quantity >= stock!;
}

/// 장바구니 상태: 아이템 목록을 불변 리스트로 관리
class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalAmount =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

/// 장바구니 컨트롤러
class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  /// 아이템 추가 (이미 있으면 수량 증가)
  ///
  /// 재고를 초과하는 경우 상태를 변경하지 않고 `false`를 반환합니다.
  /// 추가에 성공하면 `true`를 반환합니다.
  bool addItem(CartItem item) {
    final existing = state.items.indexWhere((e) => e.id == item.id);
    if (existing != -1) {
      final currentItem = state.items[existing];
      final newQty = currentItem.quantity + item.quantity;
      final stockLimit = item.stock ?? currentItem.stock;
      if (stockLimit != null && newQty > stockLimit) return false;

      final updated = List<CartItem>.from(state.items);
      updated[existing] = currentItem.copyWith(quantity: newQty);
      state = state.copyWith(items: updated);
    } else {
      if (item.stock != null && item.quantity > item.stock!) return false;
      state = state.copyWith(items: [...state.items, item]);
    }
    return true;
  }

  /// 아이템 제거
  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((e) => e.id != id).toList(),
    );
  }

  /// 수량 변경 (0 이하이면 제거)
  ///
  /// 재고를 초과하는 경우 상태를 변경하지 않고 `false`를 반환합니다.
  /// 변경에 성공하면 `true`를 반환합니다.
  bool updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeItem(id);
      return true;
    }
    final item = state.items.firstWhere((e) => e.id == id);
    if (item.stock != null && quantity > item.stock!) return false;

    final updated = state.items.map((e) {
      return e.id == id ? e.copyWith(quantity: quantity) : e;
    }).toList();
    state = state.copyWith(items: updated);
    return true;
  }

  /// 장바구니 전체 비우기
  void clearCart() => state = const CartState();
}

/// 장바구니 프로바이더
final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);
