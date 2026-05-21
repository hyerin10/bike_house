import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/admin/data/product_repository.dart';
import 'package:bike_house/features/product/data/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 정렬 옵션 Enum
// ─────────────────────────────────────────────────────────────────────────────

enum SortOption {
  newest('최신순'),
  priceAsc('낮은 가격순'),
  priceDesc('높은 가격순');

  const SortOption(this.label);

  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
// 화면 상태 모델
// ─────────────────────────────────────────────────────────────────────────────

class PopularPartsState {
  const PopularPartsState({
    required this.allProducts,
    this.sortBy = SortOption.newest,
    this.searchQuery = '',
    this.minPrice,
    this.maxPrice,
  });

  /// 원본 상품 목록 (Supabase에서 가져온 실제 데이터)
  final List<ProductModel> allProducts;

  /// 정렬 기준
  final SortOption sortBy;

  /// 검색어 필터
  final String searchQuery;

  /// 최소 가격 필터 (null = 제한 없음)
  final double? minPrice;

  /// 최대 가격 필터 (null = 제한 없음)
  final double? maxPrice;

  /// 필터가 하나라도 활성화된 경우 true
  bool get hasActiveFilters => minPrice != null || maxPrice != null;

  /// 정렬·필터가 모두 적용된 최종 상품 목록 (파생 상태)
  List<ProductModel> get filteredProducts {
    var result = allProducts;

    // 검색어 필터
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    // 최소 가격 필터
    if (minPrice != null) {
      result = result.where((p) => p.price >= minPrice!).toList();
    }

    // 최대 가격 필터
    if (maxPrice != null) {
      result = result.where((p) => p.price <= maxPrice!).toList();
    }

    // 정렬
    result = List.of(result);
    switch (sortBy) {
      case SortOption.newest:
        result.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(0);
          final bDate = b.createdAt ?? DateTime(0);
          return bDate.compareTo(aDate);
        });
      case SortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
    }

    return result;
  }

  PopularPartsState copyWith({
    List<ProductModel>? allProducts,
    SortOption? sortBy,
    String? searchQuery,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
  }) {
    return PopularPartsState(
      allProducts: allProducts ?? this.allProducts,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice:
          identical(minPrice, _sentinel) ? this.minPrice : minPrice as double?,
      maxPrice:
          identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as double?,
    );
  }
}

const _sentinel = Object();

// ─────────────────────────────────────────────────────────────────────────────
// AsyncNotifier: Supabase에서 데이터 로드 + 필터/정렬 관리
// ─────────────────────────────────────────────────────────────────────────────

class PopularPartsController extends AsyncNotifier<PopularPartsState> {
  @override
  Future<PopularPartsState> build() async {
    final products =
        await ref.read(productRepositoryProvider).fetchProducts();
    return PopularPartsState(allProducts: products);
  }

  // ── 정렬 변경 ──────────────────────────────────────────────────────────────

  void updateSort(SortOption newSort) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(value.copyWith(sortBy: newSort));
    }
  }

  // ── 검색어 변경 ────────────────────────────────────────────────────────────

  void updateSearchQuery(String query) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(value.copyWith(searchQuery: query));
    }
  }

  // ── 가격 필터 적용 (FilterBottomSheet의 Apply 버튼에서 호출) ───────────────

  void applyFilter({
    double? minPrice,
    double? maxPrice,
  }) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(
        value.copyWith(
          minPrice: minPrice,
          maxPrice: maxPrice,
        ),
      );
    }
  }
}

/// 전역 프로바이더
final popularPartsControllerProvider =
    AsyncNotifierProvider<PopularPartsController, PopularPartsState>(
  PopularPartsController.new,
);
