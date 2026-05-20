import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/product/data/product_model.dart';
import '../application/edit_product_controller.dart';
import 'widgets/product_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 상품 수정 화면
// ─────────────────────────────────────────────────────────────────────────────

/// 기존 상품 정보를 수정하는 화면
///
/// [product]의 현재 값으로 폼을 초기화하고,
/// 저장 시 [editProductProvider]를 통해 Supabase를 업데이트합니다.
class EditProductScreen extends ConsumerStatefulWidget {
  const EditProductScreen({super.key, required this.product});

  final ProductModel product;

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();

    // 컨트롤러를 기존 상품 데이터로 초기화
    _nameCtrl = TextEditingController(text: widget.product.name);
    _priceCtrl = TextEditingController(
      text: KRWInputFormatter.format(widget.product.price),
    );
    _stockCtrl = TextEditingController(
      text: (widget.product.stock ?? 0).toString(),
    );
    _descCtrl = TextEditingController(
      text: widget.product.description ?? '',
    );

    // 변경 내용을 editProductProvider에 동기화
    _nameCtrl.addListener(
      () => ref.read(editProductProvider.notifier).updateName(_nameCtrl.text),
    );
    _priceCtrl.addListener(
      () => ref
          .read(editProductProvider.notifier)
          .updatePrice(_priceCtrl.text.replaceAll(',', '')),
    );
    _stockCtrl.addListener(
      () =>
          ref.read(editProductProvider.notifier).updateStock(_stockCtrl.text),
    );
    _descCtrl.addListener(
      () => ref
          .read(editProductProvider.notifier)
          .updateDescription(_descCtrl.text),
    );

    // 첫 프레임 이후 프로바이더 상태를 현재 상품 데이터로 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(editProductProvider.notifier).init(widget.product);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _handleSave() =>
      ref.read(editProductProvider.notifier).save(widget.product.id);

  void _handleCancel() => Navigator.of(context).pop();

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '사진 접근 권한 필요',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '사진 라이브러리 접근 권한이 영구적으로 거부되어 있습니다.\n'
          '이미지를 업로드하려면 설정에서 직접 권한을 허용해 주세요.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    ref.read(editProductProvider.notifier).clearPermissionDenied();
    if (confirmed == true) {
      ref.read(editProductProvider.notifier).openSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 수정 완료 / 에러 리스닝
    ref.listen<EditProductState>(editProductProvider, (prev, next) {
      if (!mounted) return;

      if (next.isUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('상품이 수정되었습니다.'),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        ref.read(editProductProvider.notifier).clearError();
      }

      // 갤러리 권한 영구 거부 → 설정 이동 안내 다이얼로그
      if (next.isPermissionPermanentlyDenied &&
          !(prev?.isPermissionPermanentlyDenied ?? false)) {
        _showPermissionDeniedDialog(context);
      }
    });

    final state = ref.watch(editProductProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _EditAppBar(
        isLoading: state.isLoading,
        isValid: state.isValid,
        onCancel: _handleCancel,
        onSave: _handleSave,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 대표 이미지 (변경 가능)
            _EditThumbnailSection(
              existingThumbnailUrl: widget.product.thumbnailUrl,
            ),

            const SizedBox(height: 12),

            // 기본 정보 (사전 값 채워짐)
            _EditBasicInfoSection(
              nameCtrl: _nameCtrl,
              priceCtrl: _priceCtrl,
              stockCtrl: _stockCtrl,
            ),

            const SizedBox(height: 12),

            // 베스트셀러 토글
            _BestSellerSection(
              isBestSeller: state.isBestSeller,
              onToggle: () =>
                  ref.read(editProductProvider.notifier).toggleBestSeller(),
            ),

            const SizedBox(height: 12),

            // 상세 이미지 (기존 이미지 로드 + 추가/삭제)
            const _EditDetailImagesSection(),

            const SizedBox(height: 12),

            // 상품 설명 (사전 값 채워짐)
            _EditDescriptionSection(descCtrl: _descCtrl),
          ],
        ),
      ),
      bottomNavigationBar: ProductFormBottomBar(
        isLoading: state.isLoading,
        isValid: state.isValid,
        onCancel: _handleCancel,
        onSave: _handleSave,
        saveLabel: '수정 완료',
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 수정 전용 AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _EditAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _EditAppBar({
    required this.isLoading,
    required this.isValid,
    required this.onCancel,
    required this.onSave,
  });

  final bool isLoading;
  final bool isValid;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: isLoading ? null : onCancel,
      ),
      title: const Text('상품 수정'),
      actions: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: const Text(
            '취소',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton(
            onPressed: isValid && !isLoading ? onSave : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              disabledBackgroundColor: AppColors.textHint,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '수정 완료',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 대표 이미지 섹션 (수정 가능)
// ─────────────────────────────────────────────────────────────────────────────

class _EditThumbnailSection extends ConsumerWidget {
  const _EditThumbnailSection({required this.existingThumbnailUrl});

  final String? existingThumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newThumbnail = ref.watch(
      editProductProvider.select((s) => s.newThumbnail),
    );

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProductSectionLabel(label: '대표 이미지'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () =>
                ref.read(editProductProvider.notifier).pickThumbnail(),
            child: newThumbnail != null
                ? _NewThumbnailPreview(file: newThumbnail)
                : _ExistingThumbnailPreview(url: existingThumbnailUrl),
          ),
        ],
      ),
    );
  }
}

/// 기존 대표 이미지 미리보기 — 탭하면 변경, 카메라 오버레이 표시
class _ExistingThumbnailPreview extends StatelessWidget {
  const _ExistingThumbnailPreview({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: url != null
                ? Image.network(
                    url!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ThumbPlaceholder(),
                  )
                : _ThumbPlaceholder(),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  '사진 변경',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 새로 선택한 대표 이미지 미리보기 — X 버튼으로 되돌리기 가능
class _NewThumbnailPreview extends ConsumerWidget {
  const _NewThumbnailPreview({required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(file.path),
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () =>
                ref.read(editProductProvider.notifier).clearNewThumbnail(),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onTap: () =>
                ref.read(editProductProvider.notifier).pickThumbnail(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '다시 선택',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 48,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 기본 정보 섹션 (수정용 — 사전 값 채워짐)
// ─────────────────────────────────────────────────────────────────────────────

class _EditBasicInfoSection extends StatelessWidget {
  const _EditBasicInfoSection({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProductSectionLabel(label: '기본 정보'),
          const SizedBox(height: 16),

          const ProductFieldLabel(label: '상품명', required: true),
          const SizedBox(height: 6),
          ProductInputField(
            controller: nameCtrl,
            hintText: '상품명을 입력하세요',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          const ProductFieldLabel(label: '판매가격', required: true),
          const SizedBox(height: 6),
          ProductInputField(
            controller: priceCtrl,
            hintText: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [KRWInputFormatter()],
            suffixText: '원',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          const ProductFieldLabel(label: '재고 수량', required: true),
          const SizedBox(height: 6),
          ProductInputField(
            controller: stockCtrl,
            hintText: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffixText: '개',
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 베스트셀러 토글 섹션
// ─────────────────────────────────────────────────────────────────────────────

class _BestSellerSection extends StatelessWidget {
  const _BestSellerSection({
    required this.isBestSeller,
    required this.onToggle,
  });

  final bool isBestSeller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isBestSeller
                  ? AppColors.primaryLight
                  : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.star_rounded,
              color:
                  isBestSeller ? AppColors.primary : AppColors.textHint,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '베스트셀러',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '홈 화면과 상품 카드에 베스트셀러 배지가 표시됩니다.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isBestSeller,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상세 이미지 섹션 (수정용 — 기존 이미지 로드 + 추가/삭제)
// ─────────────────────────────────────────────────────────────────────────────

class _EditDetailImagesSection extends ConsumerWidget {
  const _EditDetailImagesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProductProvider);
    final existingImages = state.existingDetailImages;
    final newImages = state.newDetailImages;
    final totalCount = state.totalDetailImageCount;

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ProductSectionLabel(label: '상세 이미지'),
              Text(
                '$totalCount/10',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (totalCount < 10)
                  GestureDetector(
                    onTap: () => ref
                        .read(editProductProvider.notifier)
                        .pickDetailImages(),
                    child: Container(
                      width: 88,
                      height: 88,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: CustomPaint(
                        painter: DashedBorderPainter(radius: 10),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.textSecondary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                // 기존 상세 이미지 (네트워크 이미지)
                ...List.generate(existingImages.length, (i) {
                  return Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            existingImages[i].imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF0F2F5),
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(editProductProvider.notifier)
                              .removeExistingDetailImage(i),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                // 새로 선택한 상세 이미지 (로컬 파일)
                ...List.generate(newImages.length, (i) {
                  return Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(newImages[i].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(editProductProvider.notifier)
                              .removeNewDetailImage(i),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '상품 상세 페이지에 표시될 이미지입니다. 최대 10장까지 등록 가능합니다.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 설명 섹션 (수정용)
// ─────────────────────────────────────────────────────────────────────────────

class _EditDescriptionSection extends StatelessWidget {
  const _EditDescriptionSection({required this.descCtrl});

  final TextEditingController descCtrl;

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProductSectionLabel(label: '상품 설명'),
          const SizedBox(height: 12),
          ProductInputField(
            controller: descCtrl,
            hintText: '상품에 대한 상세 설명을 입력하세요...',
            keyboardType: TextInputType.multiline,
            minLines: 6,
            maxLines: null,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }
}
