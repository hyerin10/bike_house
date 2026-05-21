import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/core/utils/gallery_permission.dart';
import 'package:bike_house/features/product/application/product_notifier.dart';
import 'package:bike_house/features/product/data/product_model.dart';
import 'package:bike_house/features/admin/data/product_repository.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_constants.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 상품 수정 폼 상태
// ─────────────────────────────────────────────────────────────────────────────

class EditProductState {
  const EditProductState({
    this.name = '',
    this.price = '',
    this.stock = '',
    this.description = '',
    this.isBestSeller = false,
    this.existingThumbnailImageId,
    this.newThumbnail,
    this.existingDetailImages = const [],
    this.newDetailImages = const [],
    this.removedImageIds = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isUpdated = false,
    this.isPermissionPermanentlyDenied = false,
  });

  final String name;

  /// 판매가격 (천 단위 콤마 포함 문자열)
  final String price;

  final String stock;
  final String description;
  final bool isBestSeller;

  /// 기존 대표 이미지의 product_images 레코드 ID (교체 시 삭제에 사용)
  final int? existingThumbnailImageId;

  /// 새로 선택한 대표 이미지 (null이면 기존 유지)
  final XFile? newThumbnail;

  /// DB에서 불러온 기존 상세 이미지 (삭제 표시되지 않은 것들)
  final List<ProductImageModel> existingDetailImages;

  /// 새로 선택한 상세 이미지 (저장 시 업로드)
  final List<XFile> newDetailImages;

  /// 삭제할 기존 이미지 ID 목록 (저장 시 DB에서 제거)
  final List<int> removedImageIds;

  final bool isLoading;
  final String? errorMessage;

  /// 수정 완료 시 true → UI에서 pop 처리
  final bool isUpdated;

  /// true이면 갤러리 권한이 영구 거부된 상태 → UI에서 설정 이동 다이얼로그 표시
  final bool isPermissionPermanentlyDenied;

  /// 현재 표시 중인 상세 이미지 총 개수
  int get totalDetailImageCount =>
      existingDetailImages.length + newDetailImages.length;

  /// 필수 항목이 모두 입력된 경우 true
  bool get isValid =>
      name.trim().isNotEmpty &&
      price.trim().isNotEmpty &&
      stock.trim().isNotEmpty;

  EditProductState copyWith({
    String? name,
    String? price,
    String? stock,
    String? description,
    bool? isBestSeller,
    int? existingThumbnailImageId,
    XFile? newThumbnail,
    bool clearNewThumbnail = false,
    List<ProductImageModel>? existingDetailImages,
    List<XFile>? newDetailImages,
    List<int>? removedImageIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isUpdated,
    bool? isPermissionPermanentlyDenied,
  }) {
    return EditProductState(
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      existingThumbnailImageId:
          existingThumbnailImageId ?? this.existingThumbnailImageId,
      newThumbnail: clearNewThumbnail ? null : (newThumbnail ?? this.newThumbnail),
      existingDetailImages: existingDetailImages ?? this.existingDetailImages,
      newDetailImages: newDetailImages ?? this.newDetailImages,
      removedImageIds: removedImageIds ?? this.removedImageIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUpdated: isUpdated ?? this.isUpdated,
      isPermissionPermanentlyDenied:
          isPermissionPermanentlyDenied ?? this.isPermissionPermanentlyDenied,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 수정 폼 Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// 상품 수정 폼 상태를 관리하는 Notifier
///
/// - `autoDispose`를 사용해 화면이 닫히면 상태가 자동 초기화됩니다.
/// - [init]으로 기존 상품 데이터를 폼에 채워 넣습니다.
/// - [save]로 수정 내용을 Supabase에 반영하고 목록을 갱신합니다.
class EditProductController extends AutoDisposeNotifier<EditProductState> {
  final _picker = ImagePicker();

  @override
  EditProductState build() => const EditProductState();

  /// 기존 상품 데이터로 폼 상태를 초기화합니다.
  void init(ProductModel product) {
    final mainImage = product.images.where((img) => img.isMain).firstOrNull;
    final details = product.images
        .where((img) => !img.isMain)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    state = EditProductState(
      name: product.name,
      price: KRWInputFormatter.format(product.price),
      stock: (product.stock ?? 0).toString(),
      description: product.description ?? '',
      isBestSeller: product.isBestSeller,
      existingThumbnailImageId: mainImage?.id,
      existingDetailImages: details,
    );
  }

  // ── 텍스트 필드 업데이트 ─────────────────────────────────────────────────

  void updateName(String value) => state = state.copyWith(name: value);

  void updatePrice(String value) => state = state.copyWith(price: value);

  void updateStock(String value) =>
      state = state.copyWith(stock: value.isEmpty ? '0' : value);

  void updateDescription(String value) =>
      state = state.copyWith(description: value);

  void toggleBestSeller() =>
      state = state.copyWith(isBestSeller: !state.isBestSeller);

  void clearError() => state = state.copyWith(clearError: true);

  // ── 대표 이미지 관리 ─────────────────────────────────────────────────────

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
    if (file != null) state = state.copyWith(newThumbnail: file);
  }

  /// 새로 선택한 대표 이미지를 취소하고 기존 이미지로 되돌립니다.
  void clearNewThumbnail() =>
      state = state.copyWith(clearNewThumbnail: true);

  // ── 상세 이미지 관리 ─────────────────────────────────────────────────────

  /// 갤러리에서 상세 이미지를 선택합니다 (최대 [kMaxProductDetailImages]장 제한).
  ///
  /// 권한이 없으면 시스템 팝업을 띄웁니다.
  /// 영구 거부 상태이면 [isPermissionPermanentlyDenied]를 true로 설정합니다.
  Future<void> pickDetailImages() async {
    final remaining = kMaxProductDetailImages - state.totalDetailImageCount;
    if (remaining <= 0) return;

    final result = await requestGalleryPermission();
    if (!_handlePermissionResult(result)) return;

    final files = await _picker.pickMultiImage(
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (files.isEmpty) return;

    final combined = [...state.newDetailImages, ...files];
    state = state.copyWith(
      newDetailImages:
          combined.length > remaining ? combined.sublist(0, remaining) : combined,
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

  /// 기존 상세 이미지를 삭제 목록에 추가합니다 (저장 시 DB에서 제거).
  void removeExistingDetailImage(int index) {
    final image = state.existingDetailImages[index];
    final updated = [...state.existingDetailImages]..removeAt(index);
    state = state.copyWith(
      existingDetailImages: updated,
      removedImageIds: [...state.removedImageIds, image.id],
    );
  }

  /// 새로 선택한 상세 이미지를 목록에서 제거합니다.
  void removeNewDetailImage(int index) {
    final updated = [...state.newDetailImages]..removeAt(index);
    state = state.copyWith(newDetailImages: updated);
  }

  // ── 저장 ─────────────────────────────────────────────────────────────────

  /// 수정 내용을 Supabase에 반영하고, productProvider 목록을 갱신합니다.
  ///
  /// 성공 시 [isUpdated]가 true로 전환되어 UI에서 pop + SnackBar를 처리합니다.
  Future<void> save(int productId) async {
    if (!state.isValid || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final price =
          int.tryParse(state.price.replaceAll(',', '').trim()) ?? 0;
      final stock = int.tryParse(state.stock.trim()) ?? 0;
      final repo = ref.read(productRepositoryProvider);

      // 1. 기본 정보 업데이트 (목록 갱신은 모든 작업 완료 후 한 번만 수행)
      await repo.updateProduct(
        productId,
        {
          'name': state.name.trim(),
          'price': price,
          'stock': stock,
          'description': state.description.trim(),
          'is_best_seller': state.isBestSeller,
        },
      );

      // 2. 대표 이미지 교체 (새 이미지를 선택한 경우)
      if (state.newThumbnail != null) {
        if (state.existingThumbnailImageId != null) {
          await repo.deleteDetailImage(state.existingThumbnailImageId!);
        }
        await repo.uploadAndInsertThumbnail(productId, state.newThumbnail!);
      }

      // 3. 삭제 표시된 기존 이미지 제거
      for (final id in state.removedImageIds) {
        await repo.deleteDetailImage(id);
      }

      // 4. 새로 선택한 상세 이미지 업로드
      if (state.newDetailImages.isNotEmpty) {
        final startOrder = state.existingDetailImages.length + 1;
        await repo.addDetailImages(
          productId,
          state.newDetailImages,
          startOrder,
        );
      }

      // 5. 모든 변경(기본정보 + 이미지) 완료 후 상품 목록 갱신
      await ref.read(productProvider.notifier).refresh();

      state = state.copyWith(isLoading: false, isUpdated: true);
    } on PostgrestException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '상품 수정 실패: ${e.message}',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
  }
}

final editProductProvider =
    NotifierProvider.autoDispose<EditProductController, EditProductState>(
  EditProductController.new,
);
