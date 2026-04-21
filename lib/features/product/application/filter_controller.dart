import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 필터 화면에서 선택 가능한 카테고리 목록
const kAllCategories = <String>[
  'Engine',
  'Brakes',
  'Exhaust',
  'Tires',
  'Filters',
  'Lights',
  'Accessories',
];

// ─────────────────────────────────────────────────────────────────────────────
// 필터 상태 모델 (바텀시트 내 "초안" 상태)
// ─────────────────────────────────────────────────────────────────────────────

class FilterState {
  const FilterState({
    this.minPrice,
    this.maxPrice,
    this.selectedCategories = const {},
    this.onlyCompatible = false,
  });

  /// 최소 가격 (null = 제한 없음)
  final double? minPrice;

  /// 최대 가격 (null = 제한 없음)
  final double? maxPrice;

  /// 선택된 카테고리 집합 (빈 Set = 전체)
  final Set<String> selectedCategories;

  /// 내 바이크 호환 상품만 표시
  final bool onlyCompatible;

  /// 하나 이상의 필터가 활성화되어 있는지 여부
  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      selectedCategories.isNotEmpty ||
      onlyCompatible;

  FilterState copyWith({
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    Set<String>? selectedCategories,
    bool? onlyCompatible,
  }) {
    return FilterState(
      minPrice:
          identical(minPrice, _sentinel) ? this.minPrice : minPrice as double?,
      maxPrice:
          identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as double?,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      onlyCompatible: onlyCompatible ?? this.onlyCompatible,
    );
  }
}

// nullable copyWith 처리용 센티널
const _sentinel = Object();

// ─────────────────────────────────────────────────────────────────────────────
// Notifier (바텀시트 내 초안 상태 관리)
// ─────────────────────────────────────────────────────────────────────────────

class FilterController extends Notifier<FilterState> {
  @override
  FilterState build() => const FilterState();

  /// 현재 적용된 필터 상태로 초기화 (바텀시트 오픈 시 호출)
  void initFrom({
    double? minPrice,
    double? maxPrice,
    Set<String> selectedCategories = const {},
    bool onlyCompatible = false,
  }) {
    state = FilterState(
      minPrice: minPrice,
      maxPrice: maxPrice,
      selectedCategories: Set.unmodifiable(selectedCategories),
      onlyCompatible: onlyCompatible,
    );
  }

  /// null 전달 시 필드를 명시적으로 초기화하므로 copyWith 대신 직접 생성
  void setMinPrice(double? value) {
    state = FilterState(
      minPrice: value,
      maxPrice: state.maxPrice,
      selectedCategories: state.selectedCategories,
      onlyCompatible: state.onlyCompatible,
    );
  }

  void setMaxPrice(double? value) {
    state = FilterState(
      minPrice: state.minPrice,
      maxPrice: value,
      selectedCategories: state.selectedCategories,
      onlyCompatible: state.onlyCompatible,
    );
  }

  void toggleCategory(String category) {
    final updated = Set<String>.from(state.selectedCategories);
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    state = state.copyWith(selectedCategories: Set.unmodifiable(updated));
  }

  void toggleCompatibility() {
    state = state.copyWith(onlyCompatible: !state.onlyCompatible);
  }

  void reset() {
    state = const FilterState();
  }
}

/// 전역 프로바이더 — 바텀시트 내 임시(초안) 필터 상태
final filterControllerProvider =
    NotifierProvider<FilterController, FilterState>(FilterController.new);
