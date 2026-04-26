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

  /// 상품 정보를 업데이트하고 서버에서 목록을 다시 불러옵니다.
  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    await ref.read(productRepositoryProvider).updateProduct(id, data);
    state = await AsyncValue.guard(_fetch);
  }

  /// 상품을 삭제하고 서버에서 목록을 다시 불러옵니다.
  ///
  /// 삭제 → 로딩 전환 → refetch 순서로 진행하여
  /// 화면이 서버 상태와 항상 일치하도록 보장합니다.
  Future<void> deleteProduct(int id) async {
    state = const AsyncLoading();
    await ref.read(productRepositoryProvider).deleteProduct(id);
    state = await AsyncValue.guard(_fetch);
  }
}

final productProvider =
    AsyncNotifierProvider<ProductNotifier, List<ProductModel>>(
  ProductNotifier.new,
);
