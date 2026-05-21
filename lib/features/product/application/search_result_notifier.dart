import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/admin/data/product_repository.dart';
import 'package:bike_house/features/product/data/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 검색어(query)를 인자로 받아 상품 목록을 가져오는 FamilyAsyncNotifier
//
// - query == null → 전체 목록
// - query != null → 상품명 ilike 필터링 결과
// ─────────────────────────────────────────────────────────────────────────────

class SearchResultNotifier
    extends FamilyAsyncNotifier<List<ProductModel>, String?> {
  @override
  Future<List<ProductModel>> build(String? arg) =>
      ref.read(productRepositoryProvider).searchProducts(arg);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).searchProducts(arg),
    );
  }
}

final searchResultProvider = AsyncNotifierProvider.family<SearchResultNotifier,
    List<ProductModel>, String?>(
  SearchResultNotifier.new,
);
