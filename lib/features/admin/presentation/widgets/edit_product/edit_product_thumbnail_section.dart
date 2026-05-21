import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/application/edit_product_controller.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

class EditProductThumbnailSection extends ConsumerWidget {
  const EditProductThumbnailSection({
    super.key,
    required this.existingThumbnailUrl,
  });

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
                    errorBuilder: (_, __, ___) => const _ThumbPlaceholder(),
                  )
                : const _ThumbPlaceholder(),
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
  const _ThumbPlaceholder();

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
