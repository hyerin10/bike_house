import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/application/add_product_controller.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_constants.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

class AddProductDetailImagesSection extends ConsumerWidget {
  const AddProductDetailImagesSection({super.key, required this.images});

  final List<XFile> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = images.length;
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
                '$count/$max',
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
                if (count < max)
                  GestureDetector(
                    onTap: () => ref
                        .read(addProductProvider.notifier)
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
                ...List.generate(count, (i) {
                  return Stack(
                    children: [
                      Container(
                        width: tile,
                        height: tile,
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
