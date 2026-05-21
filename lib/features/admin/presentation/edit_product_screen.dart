import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/data/product_model.dart';
import 'package:bike_house/features/admin/application/edit_product_controller.dart';
import 'package:bike_house/features/admin/presentation/widgets/add_product_basic_info_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/add_product_description_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/edit_product/edit_product_app_bar.dart';
import 'package:bike_house/features/admin/presentation/widgets/edit_product/edit_product_best_seller_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/edit_product/edit_product_detail_images_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/edit_product/edit_product_thumbnail_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/gallery_permission_denied_dialog.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

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

  Future<void> _onGalleryPermissionPermanentlyDenied() async {
    final confirmed =
        await showGalleryPermissionPermanentlyDeniedDialog(context);
    if (!mounted) return;
    ref.read(editProductProvider.notifier).clearPermissionDenied();
    if (confirmed == true) {
      ref.read(editProductProvider.notifier).openSettings();
    }
  }

  void _listenEditProductSideEffects() {
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
        _onGalleryPermissionPermanentlyDenied();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenEditProductSideEffects();

    final state = ref.watch(editProductProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: EditProductAppBar(
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
            EditProductThumbnailSection(
              existingThumbnailUrl: widget.product.thumbnailUrl,
            ),

            const SizedBox(height: 12),

            AddProductBasicInfoSection(
              nameCtrl: _nameCtrl,
              priceCtrl: _priceCtrl,
              stockCtrl: _stockCtrl,
            ),

            const SizedBox(height: 12),

            EditProductBestSellerSection(
              isBestSeller: state.isBestSeller,
              onToggle: () =>
                  ref.read(editProductProvider.notifier).toggleBestSeller(),
            ),

            const SizedBox(height: 12),

            const EditProductDetailImagesSection(),

            const SizedBox(height: 12),

            AddProductDescriptionSection(descCtrl: _descCtrl),
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
