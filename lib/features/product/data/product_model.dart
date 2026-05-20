import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// product_images 테이블 모델
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class ProductImageModel with _$ProductImageModel {
  const factory ProductImageModel({
    required int id,
    @JsonKey(name: 'product_id') required int productId,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'display_order') required int displayOrder,
    @JsonKey(name: 'is_main') required bool isMain,
  }) = _ProductImageModel;

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      _$ProductImageModelFromJson(json);
}

// ─────────────────────────────────────────────────────────────────────────────
// products 테이블 모델 (product_images 조인 포함)
//
// 실제 DB 컬럼: id, name, price, stock, description, created_at, is_best_seller
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    required int id,
    required String name,
    required int price,
    int? stock,
    String? description,
    @JsonKey(name: 'is_best_seller') @Default(false) bool isBestSeller,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'product_images') @Default([]) List<ProductImageModel> images,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// product_images 중 is_main: true인 이미지 URL 반환
  /// 없으면 첫 번째 이미지 URL, 이미지가 없으면 null
  String? get thumbnailUrl {
    if (images.isEmpty) return null;
    try {
      return images.firstWhere((img) => img.isMain).imageUrl;
    } catch (_) {
      return images.first.imageUrl;
    }
  }
}
