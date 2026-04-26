import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_product.dart';

/// 관리자 대시보드 상태
class AdminDashboardState {
  const AdminDashboardState({
    this.products = const [],
    this.searchQuery = '',
  });

  final List<AdminProduct> products;
  final String searchQuery;

  /// 검색어 필터가 적용된 상품 목록
  List<AdminProduct> get filteredProducts {
    if (searchQuery.isEmpty) return products;
    final q = searchQuery.toLowerCase();
    return products.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  AdminDashboardState copyWith({
    List<AdminProduct>? products,
    String? searchQuery,
  }) {
    return AdminDashboardState(
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// 관리자 대시보드 컨트롤러 (상품 CRUD + 검색)
class AdminDashboardController extends Notifier<AdminDashboardState> {
  @override
  AdminDashboardState build() => AdminDashboardState(products: _sampleProducts);

  static final List<AdminProduct> _sampleProducts = [
    const AdminProduct(
      id: 'p001',
      name: 'K&N 하이플로우 에어필터',
      price: 89900,
      stock: 45,
      category: '필터',
    ),
    const AdminProduct(
      id: 'p002',
      name: 'Brembo 브레이크 패드 세트',
      price: 149900,
      stock: 12,
      category: '브레이크',
    ),
    const AdminProduct(
      id: 'p003',
      name: 'LED 헤드라이트 키트',
      price: 279900,
      stock: 50,
      category: '전기',
    ),
    const AdminProduct(
      id: 'p004',
      name: 'Yoshimura 머플러',
      price: 599900,
      stock: 28,
      category: '배기',
    ),
    const AdminProduct(
      id: 'p005',
      name: 'NGK 이리듐 스파크 플러그',
      price: 64900,
      stock: 0,
      category: '점화',
    ),
    const AdminProduct(
      id: 'p006',
      name: 'OEM 오일 필터 세트',
      price: 24900,
      stock: 3,
      category: '필터',
    ),
  ];

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addProduct(AdminProduct product) {
    state = state.copyWith(products: [...state.products, product]);
  }

  void updateProduct(AdminProduct updated) {
    state = state.copyWith(
      products: state.products
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
    );
  }

  void deleteProduct(String id) {
    state = state.copyWith(
      products: state.products.where((p) => p.id != id).toList(),
    );
  }

  String generateId() => 'p${DateTime.now().millisecondsSinceEpoch}';
}

final adminDashboardProvider =
    NotifierProvider<AdminDashboardController, AdminDashboardState>(
  AdminDashboardController.new,
);
