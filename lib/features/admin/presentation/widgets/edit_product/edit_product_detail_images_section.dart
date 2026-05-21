import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/application/edit_product_controller.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_constants.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

class EditProductDetailImagesSection extends ConsumerWidget {
  const EditProductDetailImagesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProductProvider);
    final existingImages = state.existingDetailImages;
    final newImages = state.newDetailImages;
    final totalCount = state.totalDetailImageCount;

    const max = kMaxProductDetailImages;
    const tile = ProductFormImageLayout.detailTileSize;

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ProductSectionLabel(label: '상세 이미지'),
              Text(
                '$totalCount/$max',
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
            height: ProductFormImageLayout.detailStripHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (totalCount < max)
                  GestureDetector(
                    onTap: () => ref
                        .read(editProductProvider.notifier)
                        .pickDetailImages(),
                    child: Container(
                      width: tile,
                      height: tile,
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
                ...List.generate(existingImages.length, (i) {
                  return _RemovableDetailImageTile(
                    tile: tile,
                    onRemove: () => ref
                        .read(editProductProvider.notifier)
                        .removeExistingDetailImage(i),
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
                  );
                }),
                ...List.generate(newImages.length, (i) {
                  return _RemovableDetailImageTile(
                    tile: tile,
                    onRemove: () => ref
                        .read(editProductProvider.notifier)
                        .removeNewDetailImage(i),
                    child: Image.file(
                      File(newImages[i].path),
                      fit: BoxFit.cover,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '상품 상세 페이지에 표시될 이미지입니다. 최대 $kMaxProductDetailImages장까지 등록 가능합니다.',
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

class _RemovableDetailImageTile extends StatelessWidget {
  const _RemovableDetailImageTile({
    required this.tile,
    required this.child,
    required this.onRemove,
  });

  final double tile;
  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: tile,
          height: tile,
          margin: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
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
  }
}
