import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../product/data/product_model.dart';

const _kBucket = 'product_images';

/// 상품 등록에 필요한 데이터를 담는 순수 데이터 클래스
class CreateProductRequest {
  const CreateProductRequest({
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.thumbnail,
    required this.detailImages,
  });

  final String name;
  final int price;
  final int stock;
  final String description;

  /// 대표 이미지 (is_main: true)
  final XFile thumbnail;

  /// 상세 이미지 목록 (is_main: false, 최대 10장)
  final List<XFile> detailImages;
}

/// Supabase와 직접 통신하는 상품 데이터 레이어
///
/// - [createProduct]: products 테이블에 insert 후 생성된 ID 반환,
///   이어서 product_images 테이블에 이미지 정보 insert 및 스토리지 업로드 처리
class ProductRepository {
  ProductRepository(this._supabase);

  final SupabaseClient _supabase;

  /// 상품을 등록하고 생성된 product ID를 반환합니다.
  ///
  /// 순서:
  /// 1. `products` 테이블에 기본 정보 insert → ID 반환
  /// 2. 대표 이미지 스토리지 업로드 → `product_images`에 `is_main: true`로 insert
  /// 3. 상세 이미지들 순서대로 업로드 → `product_images`에 `is_main: false`로 insert
  Future<int> createProduct(CreateProductRequest request) async {
    // 1. products 테이블에 insert 후 생성된 ID 반환
    final row = await _supabase
        .from('products')
        .insert({
          'name': request.name,
          'price': request.price,
          'stock': request.stock,
          'description': request.description,
        })
        .select('id')
        .single();

    final productId = row['id'] as int;

    // 2. 대표 이미지 업로드 (is_main: true, display_order: 0)
    final thumbnailUrl = await _uploadImage(request.thumbnail, 'thumbnails');
    await _supabase.from('product_images').insert({
      'product_id': productId,
      'image_url': thumbnailUrl,
      'display_order': 0,
      'is_main': true,
    });

    // 3. 상세 이미지 반복 업로드 (is_main: false, display_order: 1~N)
    for (int i = 0; i < request.detailImages.length; i++) {
      final url = await _uploadImage(request.detailImages[i], 'details');
      await _supabase.from('product_images').insert({
        'product_id': productId,
        'image_url': url,
        'display_order': i + 1,
        'is_main': false,
      });
    }

    return productId;
  }

  /// 단일 상품을 product_images와 조인하여 반환합니다.
  Future<ProductModel> fetchProductById(int id) async {
    final response = await _supabase
        .from('products')
        .select('*, product_images(*)')
        .eq('id', id)
        .single();

    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  /// products 테이블의 해당 상품 정보를 업데이트합니다.
  ///
  /// [data] 예시: `{'name': '..', 'price': 10000, 'stock': 5, 'is_best_seller': true}`
  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await _supabase.from('products').update(data).eq('id', id);
  }

  /// 상품과 연결된 이미지를 삭제한 뒤, 상품 자체를 삭제합니다.
  ///
  /// Supabase DB에 Cascade Delete가 설정되어 있지 않은 경우를 대비하여
  /// `product_images` 레코드를 먼저 삭제하고, 이후 `products`를 삭제합니다.
  Future<void> deleteProduct(int id) async {
    await _supabase.from('product_images').delete().eq('product_id', id);
    await _supabase.from('products').delete().eq('id', id);
  }

  /// products 테이블과 product_images 테이블을 조인하여 전체 상품 목록을 반환합니다.
  Future<List<ProductModel>> fetchProducts() async {
    final response = await _supabase
        .from('products')
        .select('*, product_images(*)')
        .order('id');

    return (response as List)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 검색어로 상품 목록을 필터링하여 반환합니다.
  ///
  /// - [query]가 null이거나 비어있으면 전체 목록을 반환합니다.
  /// - 검색 시 대소문자와 띄어쓰기를 무시하고 비교합니다.
  ///   (예: "cbr 600" → "CBR600RR" 매칭, "br6" → "BR 600" 매칭)
  Future<List<ProductModel>> searchProducts(String? query) async {
    final response = await _supabase
        .from('products')
        .select('*, product_images(*)')
        .order('id');

    final all = (response as List)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();

    if (query == null || query.trim().isEmpty) return all;

    // 검색어와 상품명 모두 소문자 변환 + 공백 제거 후 포함 여부 확인
    final normalized = query.toLowerCase().replaceAll(' ', '');
    return all.where((product) {
      final normalizedName = product.name.toLowerCase().replaceAll(' ', '');
      return normalizedName.contains(normalized);
    }).toList();
  }

  /// Supabase Storage에 이미지를 업로드하고 public URL을 반환합니다.
  Future<String> _uploadImage(XFile file, String folder) async {
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final path =
        '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    await _supabase.storage.from(_kBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: file.mimeType ?? 'image/$ext',
            upsert: false,
          ),
        );

    return _supabase.storage.from(_kBucket).getPublicUrl(path);
  }
}

/// [ProductRepository]를 앱 전역에서 접근하는 Provider
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(Supabase.instance.client),
);
