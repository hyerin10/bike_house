import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 장바구니 개별 아이템 모델
class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  final String id;
  final String name;
  final int price;
  final int quantity;
  final String? imageUrl;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }

  int get totalPrice => price * quantity;
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
  void addItem(CartItem item) {
    final existing = state.items.indexWhere((e) => e.id == item.id);
    if (existing != -1) {
      final updated = List<CartItem>.from(state.items);
      updated[existing] = updated[existing].copyWith(
        quantity: updated[existing].quantity + item.quantity,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  /// 아이템 제거
  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((e) => e.id != id).toList(),
    );
  }

  /// 수량 변경 (0 이하이면 제거)
  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeItem(id);
      return;
    }
    final updated = state.items.map((e) {
      return e.id == id ? e.copyWith(quantity: quantity) : e;
    }).toList();
    state = state.copyWith(items: updated);
  }

  /// 장바구니 전체 비우기
  void clearCart() => state = const CartState();
}

/// 장바구니 프로바이더
final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);
