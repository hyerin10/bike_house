import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../application/add_product_controller.dart';
import 'widgets/product_form_widgets.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _stockCtrl = TextEditingController(text: '0');
    _descCtrl = TextEditingController();

    _nameCtrl.addListener(
      () => ref.read(addProductProvider.notifier).updateName(_nameCtrl.text),
    );
    _priceCtrl.addListener(
      () => ref
          .read(addProductProvider.notifier)
          .updatePrice(_priceCtrl.text.replaceAll(',', '')),
    );
    _stockCtrl.addListener(
      () =>
          ref.read(addProductProvider.notifier).updateStock(_stockCtrl.text),
    );
    _descCtrl.addListener(
      () => ref
          .read(addProductProvider.notifier)
          .updateDescription(_descCtrl.text),
    );
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
      ref.read(addProductProvider.notifier).save();

  void _handleCancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    ref.listen<AddProductState>(addProductProvider, (prev, next) {
      if (!mounted) return;

      if (next.isSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상품이 등록되었습니다.'),
            backgroundColor: Color(0xFF22C55E),
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
          ),
        );
        ref.read(addProductProvider.notifier).clearError();
      }
    });

    final state = ref.watch(addProductProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AddAppBar(
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
            _ThumbnailSection(thumbnail: state.thumbnail),
            const SizedBox(height: 12),
            _BasicInfoSection(
              nameCtrl: _nameCtrl,
              priceCtrl: _priceCtrl,
              stockCtrl: _stockCtrl,
            ),
            const SizedBox(height: 12),
            _DetailImagesSection(images: state.detailImages),
            const SizedBox(height: 12),
            _DescriptionSection(descCtrl: _descCtrl),
          ],
        ),
      ),
      bottomNavigationBar: ProductFormBottomBar(
        isLoading: state.isLoading,
        isValid: state.isValid,
        onCancel: _handleCancel,
        onSave: _handleSave,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 등록 전용 AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _AddAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AddAppBar({
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
      title: const Text('상품 등록'),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    '저장하기',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1: 대표 이미지
// ─────────────────────────────────────────────────────────────────────────────

class _ThumbnailSection extends ConsumerWidget {
  const _ThumbnailSection({required this.thumbnail});

  final XFile? thumbnail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProductSectionLabel(label: '대표 이미지', required: true),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () =>
                ref.read(addProductProvider.notifier).pickThumbnail(),
            child: thumbnail == null
                ? _ThumbnailPlaceholder()
                : _ThumbnailPreview(thumbnail: thumbnail!),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.file_upload_outlined,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이미지 업로드',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '클릭하여 파일 선택',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailPreview extends ConsumerWidget {
  const _ThumbnailPreview({required this.thumbnail});

  final XFile thumbnail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(thumbnail.path),
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
                ref.read(addProductProvider.notifier).clearThumbnail(),
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
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () =>
                ref.read(addProductProvider.notifier).pickThumbnail(),
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
                  Icon(Icons.edit, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    '변경',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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

// ─────────────────────────────────────────────────────────────────────────────
// Section 2: 기본 정보
// ─────────────────────────────────────────────────────────────────────────────

class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({
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
// Section 3: 상세 이미지
// ─────────────────────────────────────────────────────────────────────────────

class _DetailImagesSection extends ConsumerWidget {
  const _DetailImagesSection({required this.images});

  final List<XFile> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = images.length;

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ProductSectionLabel(label: '상세 이미지'),
              Text(
                '$count/10',
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
                if (count < 10)
                  GestureDetector(
                    onTap: () =>
                        ref.read(addProductProvider.notifier).pickDetailImages(),
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
                ...List.generate(count, (i) {
                  return Stack(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(images[i].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(addProductProvider.notifier)
                              .removeDetailImage(i),
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
// Section 4: 상품 설명
// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.descCtrl});

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
