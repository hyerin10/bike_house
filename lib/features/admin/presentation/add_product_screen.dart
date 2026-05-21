import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/application/add_product_controller.dart';
import 'package:bike_house/features/admin/presentation/widgets/add_product_app_bar.dart';
import 'package:bike_house/features/admin/presentation/widgets/add_product_basic_info_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/add_product_description_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/add_product_detail_images_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/add_product_thumbnail_section.dart';
import 'package:bike_house/features/admin/presentation/widgets/gallery_permission_denied_dialog.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';
import 'package:bike_house/features/product/application/product_notifier.dart';

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

  void _handleSave() => ref.read(addProductProvider.notifier).save();

  void _handleCancel() => Navigator.of(context).pop();

  void _listenAddProductSideEffects() {
    ref.listen<AddProductState>(addProductProvider, (prev, next) {
      if (!mounted) return;

      if (next.isSaved && !(prev?.isSaved ?? false)) {
        ref.read(productProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상품이 등록되었습니다.'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
        Navigator.of(context).maybePop();
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

      if (next.isPermissionPermanentlyDenied &&
          !(prev?.isPermissionPermanentlyDenied ?? false)) {
        _onGalleryPermissionPermanentlyDenied();
      }
    });
  }

  Future<void> _onGalleryPermissionPermanentlyDenied() async {
    final confirmed =
        await showGalleryPermissionPermanentlyDeniedDialog(context);
    if (!mounted) return;
    ref.read(addProductProvider.notifier).clearPermissionDenied();
    if (confirmed == true) {
      ref.read(addProductProvider.notifier).openSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenAddProductSideEffects();

    final state = ref.watch(addProductProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AddProductAppBar(
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
            AddProductThumbnailSection(thumbnail: state.thumbnail),
            const SizedBox(height: 12),
            AddProductBasicInfoSection(
              nameCtrl: _nameCtrl,
              priceCtrl: _priceCtrl,
              stockCtrl: _stockCtrl,
            ),
            const SizedBox(height: 12),
            AddProductDetailImagesSection(images: state.detailImages),
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
      ),
    );
  }
}
