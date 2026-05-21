import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/product/application/product_notifier.dart';
import 'package:bike_house/features/product/data/product_model.dart';

/// 상품 검색 쿼리 상태
final adminProductSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

List<ProductModel> _filterProducts(
  List<ProductModel> products,
  String query,
) {
  if (query.isEmpty) return products;
  final q = query.toLowerCase();
  return products
      .where((p) => p.name.toLowerCase().contains(q))
      .toList();
}

/// [productProvider] 목록에 검색어를 적용한 비동기 결과입니다.
final adminFilteredProductsProvider =
    Provider<AsyncValue<List<ProductModel>>>((ref) {
  final asyncProducts = ref.watch(productProvider);
  final searchQuery = ref.watch(adminProductSearchQueryProvider);
  return asyncProducts.when(
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
    data: (products) =>
        AsyncData(_filterProducts(products, searchQuery)),
  );
});
