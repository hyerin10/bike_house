import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/core/utils/gallery_permission.dart';
import 'package:bike_house/features/admin/data/product_repository.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 상품 등록 폼 상태
// ─────────────────────────────────────────────────────────────────────────────

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
    this.isPermissionPermanentlyDenied = false,
  });

  final XFile? thumbnail;
  final String name;

  /// 판매가격 (천 단위 콤마 포함 문자열)
  final String price;

  final String stock;
  final String description;

  /// 상세 이미지 목록 (최대 10장)
  final List<XFile> detailImages;

  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;

  /// true이면 갤러리 권한이 영구 거부된 상태 → UI에서 설정 이동 다이얼로그 표시
  final bool isPermissionPermanentlyDenied;

  /// 필수 항목(대표 이미지, 상품명, 판매가격, 재고)이 모두 입력된 경우 true
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
    bool? isPermissionPermanentlyDenied,
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
      isPermissionPermanentlyDenied:
          isPermissionPermanentlyDenied ?? this.isPermissionPermanentlyDenied,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 등록 폼 Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// 상품 등록 폼 상태를 관리하는 Notifier
///
/// - 이미지 선택, 텍스트 필드 업데이트 등 폼 인터랙션을 처리합니다.
/// - 저장 시 [ProductRepository]에 위임하여 Supabase와 통신합니다.
/// - `autoDispose`를 사용해 화면이 닫히면 상태가 자동으로 초기화됩니다.
class AddProductController extends AutoDisposeNotifier<AddProductState> {
  final _picker = ImagePicker();

  @override
  AddProductState build() => const AddProductState();

  // ── 텍스트 필드 업데이트 ──────────────────────────────────────────────────

  void updateName(String value) => state = state.copyWith(name: value);

  void updatePrice(String value) => state = state.copyWith(price: value);

  void updateStock(String value) =>
      state = state.copyWith(stock: value.isEmpty ? '0' : value);

  void updateDescription(String value) =>
      state = state.copyWith(description: value);

  // ── 이미지 선택 ───────────────────────────────────────────────────────────

  /// 갤러리에서 대표 이미지 1장 선택
  ///
  /// 권한이 없으면 시스템 팝업을 띄웁니다.
  /// 영구 거부 상태이면 [isPermissionPermanentlyDenied]를 true로 설정합니다.
  Future<void> pickThumbnail() async {
    final result = await requestGalleryPermission();
    if (!_handlePermissionResult(result)) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file != null) state = state.copyWith(thumbnail: file);
  }

  /// 갤러리에서 상세 이미지 선택 (현재 장수 + 선택 장수가 [kMaxProductDetailImages]를 초과하지 않도록 제한)
  ///
  /// 권한이 없으면 시스템 팝업을 띄웁니다.
  /// 영구 거부 상태이면 [isPermissionPermanentlyDenied]를 true로 설정합니다.
  Future<void> pickDetailImages() async {
    final remaining = kMaxProductDetailImages - state.detailImages.length;
    if (remaining <= 0) return;

    final result = await requestGalleryPermission();
    if (!_handlePermissionResult(result)) return;

    final files = await _picker.pickMultiImage(
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (files.isEmpty) return;

    final combined = [...state.detailImages, ...files];
    state = state.copyWith(
      detailImages: combined.length > kMaxProductDetailImages
          ? combined.sublist(0, kMaxProductDetailImages)
          : combined,
    );
  }

  /// [GalleryPermissionResult]를 처리하고 계속 진행 가능하면 true를 반환합니다.
  bool _handlePermissionResult(GalleryPermissionResult result) {
    switch (result) {
      case GalleryPermissionResult.granted:
        return true;
      case GalleryPermissionResult.permanentlyDenied:
        state = state.copyWith(isPermissionPermanentlyDenied: true);
        return false;
      case GalleryPermissionResult.denied:
        return false;
    }
  }

  /// 영구 거부 다이얼로그를 닫은 뒤 상태를 초기화합니다.
  void clearPermissionDenied() =>
      state = state.copyWith(isPermissionPermanentlyDenied: false);

  /// 시스템 앱 설정 화면으로 이동합니다.
  Future<void> openSettings() => openAppSettings();

  /// 상세 이미지 목록에서 특정 인덱스 항목 제거
  void removeDetailImage(int index) {
    final updated = [...state.detailImages]..removeAt(index);
    state = state.copyWith(detailImages: updated);
  }

  void clearThumbnail() => state = state.copyWith(clearThumbnail: true);

  void clearError() => state = state.copyWith(clearError: true);

  // ── 저장 ──────────────────────────────────────────────────────────────────

  /// 상품 등록 실행
  ///
  /// [ProductRepository.createProduct]에 위임합니다:
  /// 1. `products` 테이블 insert → 생성된 ID 반환
  /// 2. 대표 이미지 업로드 → `product_images` (is_main: true)
  /// 3. 상세 이미지 반복 업로드 → `product_images` (is_main: false)
  Future<void> save() async {
    if (!state.isValid || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final price =
          int.tryParse(state.price.replaceAll(',', '').trim()) ?? 0;
      final stock = int.tryParse(state.stock.trim()) ?? 0;

      await ref.read(productRepositoryProvider).createProduct(
            CreateProductRequest(
              name: state.name.trim(),
              price: price,
              stock: stock,
              description: state.description.trim(),
              thumbnail: state.thumbnail!,
              detailImages: state.detailImages,
            ),
          );

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
}

final addProductProvider =
    NotifierProvider.autoDispose<AddProductController, AddProductState>(
  AddProductController.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// ProductNotifier (AsyncNotifier)
// ─────────────────────────────────────────────────────────────────────────────

/// 상품 단건 등록의 비동기 상태를 관리하는 AsyncNotifier
///
/// - UI에서 `ref.watch(productNotifierProvider)`로 [AsyncValue]를 구독합니다.
/// - 로딩/에러/완료 상태를 [AsyncValue]로 표현하므로 별도 isLoading 필드가 불필요합니다.
/// - 반환값은 Supabase가 생성한 `product.id`입니다.
class ProductNotifier extends AutoDisposeAsyncNotifier<int?> {
  @override
  Future<int?> build() async => null;

  /// [request]를 받아 상품 등록을 실행합니다.
  ///
  /// 성공 시 state는 `AsyncData(productId)`, 실패 시 `AsyncError`로 전환됩니다.
  Future<void> createProduct(CreateProductRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).createProduct(request),
    );
  }
}

final productNotifierProvider =
    AsyncNotifierProvider.autoDispose<ProductNotifier, int?>(
  ProductNotifier.new,
);
