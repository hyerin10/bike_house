import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/admin/data/product_repository.dart';
import '../data/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Supabase에서 상품 목록을 가져오는 AsyncNotifier
// ─────────────────────────────────────────────────────────────────────────────

class ProductNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() => _fetch();

  Future<List<ProductModel>> _fetch() =>
      ref.read(productRepositoryProvider).fetchProducts();

  /// 수동 새로고침 (pull-to-refresh 등에서 호출)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final productProvider =
    AsyncNotifierProvider<ProductNotifier, List<ProductModel>>(
  ProductNotifier.new,
);
