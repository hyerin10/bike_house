import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            // 현재 대표 이미지 미리보기 (읽기 전용)
            _CurrentThumbnailSection(thumbnailUrl: widget.product.thumbnailUrl),

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
// 현재 대표 이미지 미리보기 (읽기 전용)
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentThumbnailSection extends StatelessWidget {
  const _CurrentThumbnailSection({required this.thumbnailUrl});

  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProductSectionLabel(label: '대표 이미지'),
          const SizedBox(height: 4),
          const Text(
            '이미지 변경은 현재 지원하지 않습니다.',
            style: TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: thumbnailUrl != null
                  ? Image.network(
                      thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ThumbPlaceholder(),
                    )
                  : _ThumbPlaceholder(),
            ),
          ),
        ],
      ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '베스트셀러',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
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
