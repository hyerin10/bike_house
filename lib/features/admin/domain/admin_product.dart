/// 관리자 상품 도메인 모델 (재고 포함)
class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.category,
  });

  final String id;
  final String name;

  /// 판매가 (원)
  final double price;

  /// 재고 수량
  final int stock;

  final String? imageUrl;
  final String? category;

  AdminProduct copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
