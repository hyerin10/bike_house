import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 필터 상태 모델 (바텀시트 내 "초안" 상태)
// ─────────────────────────────────────────────────────────────────────────────

class FilterState {
  const FilterState({
    this.minPrice,
    this.maxPrice,
  });

  /// 최소 가격 (null = 제한 없음)
  final double? minPrice;

  /// 최대 가격 (null = 제한 없음)
  final double? maxPrice;

  /// 하나 이상의 필터가 활성화되어 있는지 여부
  bool get hasActiveFilters => minPrice != null || maxPrice != null;

  FilterState copyWith({
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
  }) {
    return FilterState(
      minPrice:
          identical(minPrice, _sentinel) ? this.minPrice : minPrice as double?,
      maxPrice:
          identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as double?,
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
  }) {
    state = FilterState(minPrice: minPrice, maxPrice: maxPrice);
  }

  void setMinPrice(double? value) {
    state = FilterState(minPrice: value, maxPrice: state.maxPrice);
  }

  void setMaxPrice(double? value) {
    state = FilterState(minPrice: state.minPrice, maxPrice: value);
  }

  void reset() {
    state = const FilterState();
  }
}

/// 전역 프로바이더 — 바텀시트 내 임시(초안) 필터 상태
final filterControllerProvider =
    NotifierProvider<FilterController, FilterState>(FilterController.new);
