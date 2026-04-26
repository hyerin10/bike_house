import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Storage 버킷 이름
const _kBucket = 'product-images';

/// 상품 등록 폼의 불변 상태
class AddProductState {
  const AddProductState({
    this.thumbnail,
    this.name = '',
    this.price = '',
    this.stock = '0',
    this.description = '',
    this.detailImages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
  });

  final XFile? thumbnail;

  /// 상품명
  final String name;

  /// 판매가격 (숫자 문자열, 콤마 없음)
  final String price;

  /// 재고 수량 (숫자 문자열)
  final String stock;

  /// 상품 설명
  final String description;

  /// 상세 이미지 목록 (최대 10장)
  final List<XFile> detailImages;

  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;

  /// 필수 항목(대표 이미지, 상품명, 판매가격, 재고 수량)이 모두 입력된 경우 true
  bool get isValid =>
      thumbnail != null &&
      name.trim().isNotEmpty &&
      price.trim().isNotEmpty &&
      stock.trim().isNotEmpty;

  AddProductState copyWith({
    XFile? thumbnail,
    bool clearThumbnail = false,
    String? name,
    String? price,
    String? stock,
    String? description,
    List<XFile>? detailImages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSaved,
  }) {
    return AddProductState(
      thumbnail: clearThumbnail ? null : (thumbnail ?? this.thumbnail),
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      detailImages: detailImages ?? this.detailImages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// 상품 등록 폼 상태를 관리하는 Notifier
///
/// autoDispose를 사용해 화면이 닫히면 상태가 자동으로 초기화됩니다.
class AddProductController extends AutoDisposeNotifier<AddProductState> {
  final _picker = ImagePicker();

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  AddProductState build() => const AddProductState();

  void updateName(String value) => state = state.copyWith(name: value);

  void updatePrice(String value) => state = state.copyWith(price: value);

  void updateStock(String value) =>
      state = state.copyWith(stock: value.isEmpty ? '0' : value);

  void updateDescription(String value) =>
      state = state.copyWith(description: value);

  /// 갤러리에서 대표 이미지 1장 선택
  Future<void> pickThumbnail() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file != null) state = state.copyWith(thumbnail: file);
  }

  /// 갤러리에서 상세 이미지 선택 (최대 10장 합산)
  Future<void> pickDetailImages() async {
    final remaining = 10 - state.detailImages.length;
    if (remaining <= 0) return;

    final files = await _picker.pickMultiImage(
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (files.isEmpty) return;

    final combined = [...state.detailImages, ...files];
    state = state.copyWith(
      detailImages:
          combined.length > 10 ? combined.sublist(0, 10) : combined,
    );
  }

  /// 상세 이미지 목록에서 특정 인덱스 항목 제거
  void removeDetailImage(int index) {
    final updated = [...state.detailImages]..removeAt(index);
    state = state.copyWith(detailImages: updated);
  }

  /// 상품 저장: 이미지 업로드 후 Supabase products 테이블에 insert
  Future<void> save() async {
    if (!state.isValid || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final thumbnailUrl = await _uploadFile(state.thumbnail!, 'thumbnails');

      final detailUrls = <String>[];
      for (final img in state.detailImages) {
        detailUrls.add(await _uploadFile(img, 'details'));
      }

      final price =
          int.tryParse(state.price.replaceAll(',', '').trim()) ?? 0;
      final stock = int.tryParse(state.stock.trim()) ?? 0;

      await _supabase.from('products').insert({
        'name': state.name.trim(),
        'price': price,
        'stock': stock,
        'description': state.description.trim(),
        'thumbnail_url': thumbnailUrl,
        'detail_image_urls': detailUrls,
      });

      state = state.copyWith(isLoading: false, isSaved: true);
    } on StorageException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '이미지 업로드 실패: ${e.message}',
      );
    } on PostgrestException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '상품 저장 실패: ${e.message}',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
  }

  void clearThumbnail() => state = state.copyWith(clearThumbnail: true);

  void clearError() => state = state.copyWith(clearError: true);

  /// Supabase Storage에 이미지를 업로드하고 public URL을 반환
  Future<String> _uploadFile(XFile file, String folder) async {
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

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

final addProductProvider =
    NotifierProvider.autoDispose<AddProductController, AddProductState>(
  AddProductController.new,
);
