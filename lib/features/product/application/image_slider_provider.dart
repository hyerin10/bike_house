import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 상품 이미지 슬라이더 현재 인덱스 프로바이더
//
// 왜 StateProvider.autoDispose.family 인가?
//  - family: 상품마다 고유한 인덱스를 유지해야 하므로 productId를 키로 사용
//  - autoDispose: 상세 페이지를 벗어나면 인덱스가 자동 초기화됨
//    (다음에 같은 상품을 열면 첫 번째 이미지부터 시작)
// ─────────────────────────────────────────────────────────────────────────────

/// 상품 ID별 이미지 슬라이더 현재 인덱스 (0-based)
final imageSliderIndexProvider =
    StateProvider.autoDispose.family<int, int>((ref, productId) => 0);
