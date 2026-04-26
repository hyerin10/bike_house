import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/data/product_repository.dart';
import '../data/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// productId를 인자로 받아 단일 상품을 조회하는 AsyncNotifier
// ─────────────────────────────────────────────────────────────────────────────

class ProductDetailNotifier extends FamilyAsyncNotifier<ProductModel, int> {
  @override
  Future<ProductModel> build(int arg) =>
      ref.read(productRepositoryProvider).fetchProductById(arg);

  /// 상세 정보 수동 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).fetchProductById(arg),
    );
  }
}

final productDetailProvider =
    AsyncNotifierProviderFamily<ProductDetailNotifier, ProductModel, int>(
  ProductDetailNotifier.new,
);
