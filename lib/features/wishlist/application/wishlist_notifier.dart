import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/providers/auth_provider.dart';
import 'package:bike_house/features/product/data/product_model.dart';

/// 위시리스트 상태 관리 — Supabase `wishlists` 테이블과 실시간 동기화
class WishlistNotifier extends AsyncNotifier<List<ProductModel>> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<List<ProductModel>> build() async {
    final user = ref.watch(authProvider);
    if (user == null) return [];
    return _fetchWishlist();
  }

  Future<List<ProductModel>> _fetchWishlist() async {
    final rows = await _supabase
        .from('wishlists')
        .select('products(*, product_images(*))')
        .order('created_at', ascending: false);

    return rows
        .map((e) =>
            ProductModel.fromJson(e['products'] as Map<String, dynamic>))
        .toList();
  }

  /// 찜 토글: 위시리스트에 없으면 추가, 있으면 삭제
  Future<void> toggle(ProductModel product) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final current = state.valueOrNull ?? [];
    final alreadyIn = current.any((p) => p.id == product.id);

    // 낙관적(Optimistic) UI 업데이트
    if (alreadyIn) {
      state = AsyncData(current.where((p) => p.id != product.id).toList());
    } else {
      state = AsyncData([product, ...current]);
    }

    try {
      if (alreadyIn) {
        await _supabase
            .from('wishlists')
            .delete()
            .eq('user_id', user.id)
            .eq('product_id', product.id);
      } else {
        await _supabase.from('wishlists').insert({
          'user_id': user.id,
          'product_id': product.id,
        });
      }
    } catch (_) {
      // DB 오류 시 서버 상태로 복원
      state = AsyncData(await _fetchWishlist());
    }
  }

  /// 특정 상품 ID가 위시리스트에 포함되어 있는지 확인
  bool isWishlisted(int productId) {
    return state.valueOrNull?.any((p) => p.id == productId) ?? false;
  }
}

/// 전역 위시리스트 프로바이더
final wishlistProvider =
    AsyncNotifierProvider<WishlistNotifier, List<ProductModel>>(
  WishlistNotifier.new,
);

/// 위시리스트 총 개수 (마이페이지 배지용)
final wishlistCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistProvider).valueOrNull?.length ?? 0;
});
