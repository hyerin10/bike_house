import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/application/add_product_controller.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_constants.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

class AddProductThumbnailSection extends ConsumerWidget {
  const AddProductThumbnailSection({super.key, required this.thumbnail});

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
                ? const _ThumbnailPlaceholder()
                : _ThumbnailPreview(thumbnail: thumbnail!),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ProductFormImageLayout.thumbnailHeight,
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
                    color: Colors.black.withValues(alpha: 0.08),
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
            height: ProductFormImageLayout.thumbnailHeight,
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
