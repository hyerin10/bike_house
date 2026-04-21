import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 정렬 옵션 Enum
// ─────────────────────────────────────────────────────────────────────────────

enum SortOption {
  popularity('인기순'),
  priceAsc('낮은 가격순'),
  priceDesc('높은 가격순'),
  rating('별점순');

  const SortOption(this.label);

  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
// 화면 상태 모델
// ─────────────────────────────────────────────────────────────────────────────

class PopularPartsState {
  const PopularPartsState({
    required this.allProducts,
    this.sortBy = SortOption.popularity,
    this.searchQuery = '',
    this.showCompatibleOnly = false,
    this.minPrice,
    this.maxPrice,
    this.selectedCategories = const {},
  });

  /// 원본 상품 목록
  final List<Product> allProducts;

  /// 정렬 기준
  final SortOption sortBy;

  /// 검색어 필터
  final String searchQuery;

  /// 호환 가능 상품만 보기
  final bool showCompatibleOnly;

  /// 최소 가격 필터 (null = 제한 없음)
  final double? minPrice;

  /// 최대 가격 필터 (null = 제한 없음)
  final double? maxPrice;

  /// 선택된 카테고리 (빈 Set = 전체)
  final Set<String> selectedCategories;

  /// 필터가 하나라도 활성화된 경우 true
  bool get hasActiveFilters =>
      showCompatibleOnly ||
      minPrice != null ||
      maxPrice != null ||
      selectedCategories.isNotEmpty;

  /// 정렬·필터가 모두 적용된 최종 상품 목록 (파생 상태)
  List<Product> get filteredProducts {
    var result = allProducts;

    // 검색어 필터
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    // 호환 여부 필터
    if (showCompatibleOnly) {
      result = result.where((p) => p.isCompatible).toList();
    }

    // 최소 가격 필터
    if (minPrice != null) {
      result = result.where((p) => p.price >= minPrice!).toList();
    }

    // 최대 가격 필터
    if (maxPrice != null) {
      result = result.where((p) => p.price <= maxPrice!).toList();
    }

    // 카테고리 필터
    if (selectedCategories.isNotEmpty) {
      result = result
          .where((p) =>
              p.category != null && selectedCategories.contains(p.category))
          .toList();
    }

    // 정렬
    result = List.of(result);
    switch (sortBy) {
      case SortOption.popularity:
        result.sort(
            (a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
      case SortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.rating:
        result.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    return result;
  }

  PopularPartsState copyWith({
    List<Product>? allProducts,
    SortOption? sortBy,
    String? searchQuery,
    bool? showCompatibleOnly,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    Set<String>? selectedCategories,
  }) {
    return PopularPartsState(
      allProducts: allProducts ?? this.allProducts,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      showCompatibleOnly: showCompatibleOnly ?? this.showCompatibleOnly,
      minPrice:
          identical(minPrice, _sentinel) ? this.minPrice : minPrice as double?,
      maxPrice:
          identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as double?,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }
}

const _sentinel = Object();

// ─────────────────────────────────────────────────────────────────────────────
// 목업 데이터 (실제 API 연동 시 data/ 레이어로 이동)
// ─────────────────────────────────────────────────────────────────────────────

final _kMockProducts = <Product>[
  const Product(
    id: 'p001',
    name: 'K&N 하이플로우 에어필터',
    price: 89900,
    originalPrice: 110000,
    rating: 4.8,
    reviewCount: 245,
    isBestSeller: true,
    isCompatible: true,
    category: 'Filters',
  ),
  const Product(
    id: 'p002',
    name: 'Brembo 브레이크 패드 세트',
    price: 145000,
    rating: 4.7,
    reviewCount: 189,
    isCompatible: true,
    category: 'Brakes',
  ),
  const Product(
    id: 'p003',
    name: 'NGK 이리듐 스파크 플러그 (4개입)',
    price: 64900,
    originalPrice: 79900,
    rating: 4.6,
    reviewCount: 243,
    isCompatible: true,
    category: 'Engine',
  ),
  const Product(
    id: 'p004',
    name: 'OEM 오일 필터 세트',
    price: 24900,
    rating: 4.5,
    reviewCount: 567,
    isCompatible: true,
    category: 'Filters',
  ),
  const Product(
    id: 'p005',
    name: 'Yoshimura RS-9 슬립온 머플러',
    price: 599900,
    rating: 4.9,
    reviewCount: 876,
    isCompatible: false,
    category: 'Exhaust',
  ),
  const Product(
    id: 'p006',
    name: 'Renthal 핸들바 그립 세트',
    price: 39900,
    originalPrice: 48000,
    rating: 4.4,
    reviewCount: 312,
    isCompatible: true,
    category: 'Accessories',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// AsyncNotifier
// ─────────────────────────────────────────────────────────────────────────────

class PopularPartsController extends AsyncNotifier<PopularPartsState> {
  @override
  Future<PopularPartsState> build() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return PopularPartsState(allProducts: _kMockProducts);
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

  // ── 필터 일괄 적용 (FilterBottomSheet의 Apply 버튼에서 호출) ───────────────

  void applyFilter({
    double? minPrice,
    double? maxPrice,
    Set<String> selectedCategories = const {},
    bool showCompatibleOnly = false,
  }) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(
        value.copyWith(
          showCompatibleOnly: showCompatibleOnly,
          minPrice: minPrice,
          maxPrice: maxPrice,
          selectedCategories: selectedCategories,
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
