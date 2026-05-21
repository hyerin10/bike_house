import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/features/admin/data/product_repository.dart';
import 'package:bike_house/features/product/data/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Supabase에서 상품 목록을 가져오는 AsyncNotifier (Realtime 구독 포함)
// ─────────────────────────────────────────────────────────────────────────────

class ProductNotifier extends AsyncNotifier<List<ProductModel>> {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<ProductModel>> build() async {
    final products = await _fetch();
    _subscribeRealtime();
    return products;
  }

  /// products / product_images 테이블 변경을 실시간으로 감지합니다.
  void _subscribeRealtime() {
    final channel = _client
        .channel('public:products:realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (_) => _silentRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'product_images',
          callback: (_) => _silentRefresh(),
        )
        .subscribe();

    ref.onDispose(() => _client.removeChannel(channel));
  }

  /// 로딩 스피너 없이 백그라운드에서 목록을 갱신합니다.
  Future<void> _silentRefresh() async {
    final next = await AsyncValue.guard(_fetch);
    if (next is AsyncData<List<ProductModel>>) {
      state = next;
    }
  }

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
