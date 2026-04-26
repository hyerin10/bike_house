import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/product/application/product_notifier.dart';
import '../../../features/product/data/product_model.dart';
import '../presentation/widgets/product_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 상품 수정 폼 상태
// ─────────────────────────────────────────────────────────────────────────────

class EditProductState {
  const EditProductState({
    this.name = '',
    this.price = '',
    this.stock = '',
    this.description = '',
    this.isBestSeller = false,
    this.isLoading = false,
    this.errorMessage,
    this.isUpdated = false,
  });

  final String name;

  /// 판매가격 (천 단위 콤마 포함 문자열)
  final String price;

  final String stock;
  final String description;
  final bool isBestSeller;
  final bool isLoading;
  final String? errorMessage;

  /// 수정 완료 시 true → UI에서 pop 처리
  final bool isUpdated;

  /// 필수 항목이 모두 입력된 경우 true
  bool get isValid =>
      name.trim().isNotEmpty &&
      price.trim().isNotEmpty &&
      stock.trim().isNotEmpty;

  EditProductState copyWith({
    String? name,
    String? price,
    String? stock,
    String? description,
    bool? isBestSeller,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isUpdated,
  }) {
    return EditProductState(
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUpdated: isUpdated ?? this.isUpdated,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 수정 폼 Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// 상품 수정 폼 상태를 관리하는 Notifier
///
/// - `autoDispose`를 사용해 화면이 닫히면 상태가 자동 초기화됩니다.
/// - [init]으로 기존 상품 데이터를 폼에 채워 넣습니다.
/// - [save]로 수정 내용을 Supabase에 반영하고 목록을 갱신합니다.
class EditProductController extends AutoDisposeNotifier<EditProductState> {
  @override
  EditProductState build() => const EditProductState();

  /// 기존 상품 데이터로 폼 상태를 초기화합니다.
  void init(ProductModel product) {
    state = EditProductState(
      name: product.name,
      price: KRWInputFormatter.format(product.price),
      stock: (product.stock ?? 0).toString(),
      description: product.description ?? '',
      isBestSeller: product.isBestSeller,
    );
  }

  // ── 텍스트 필드 업데이트 ─────────────────────────────────────────────────

  void updateName(String value) => state = state.copyWith(name: value);

  void updatePrice(String value) => state = state.copyWith(price: value);

  void updateStock(String value) =>
      state = state.copyWith(stock: value.isEmpty ? '0' : value);

  void updateDescription(String value) =>
      state = state.copyWith(description: value);

  void toggleBestSeller() =>
      state = state.copyWith(isBestSeller: !state.isBestSeller);

  void clearError() => state = state.copyWith(clearError: true);

  // ── 저장 ─────────────────────────────────────────────────────────────────

  /// 수정 내용을 Supabase에 반영하고, productProvider 목록을 갱신합니다.
  ///
  /// 성공 시 [isUpdated]가 true로 전환되어 UI에서 pop + SnackBar를 처리합니다.
  Future<void> save(int productId) async {
    if (!state.isValid || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final price =
          int.tryParse(state.price.replaceAll(',', '').trim()) ?? 0;
      final stock = int.tryParse(state.stock.trim()) ?? 0;

      await ref.read(productProvider.notifier).updateProduct(
        productId,
        {
          'name': state.name.trim(),
          'price': price,
          'stock': stock,
          'description': state.description.trim(),
          'is_best_seller': state.isBestSeller,
        },
      );

      state = state.copyWith(isLoading: false, isUpdated: true);
    } on PostgrestException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '상품 수정 실패: ${e.message}',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
  }
}

final editProductProvider =
    NotifierProvider.autoDispose<EditProductController, EditProductState>(
  EditProductController.new,
);
