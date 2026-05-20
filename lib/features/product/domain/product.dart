// 상품 도메인 모델 (추후 freezed로 확장 예정)

/// 상품의 기본 도메인 모델
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.rating,
    this.reviewCount,
    this.isBestSeller = false,
    this.isCompatible = false,
    this.category,
  });

  /// 상품 고유 ID
  final String id;

  /// 상품명
  final String name;

  /// 현재 판매가 (원)
  final double price;

  /// 할인 전 원래 가격 (원), null이면 미할인 상품
  final double? originalPrice;

  /// 평균 별점 (0.0 ~ 5.0)
  final double? rating;

  /// 리뷰 수
  final int? reviewCount;

  /// 베스트셀러 여부
  final bool isBestSeller;

  /// 내 바이크 호환 여부
  final bool isCompatible;

  /// 상품 카테고리 (필터용)
  final String? category;
}
