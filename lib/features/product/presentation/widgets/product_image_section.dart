import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/image_slider_provider.dart';
import 'package:bike_house/features/product/data/product_model.dart';

class ProductImageSection extends ConsumerStatefulWidget {
  const ProductImageSection({
    super.key,
    required this.productId,
    required this.images,
    required this.isBestSeller,
  });

  final int productId;
  final List<ProductImageModel> images;
  final bool isBestSeller;

  @override
  ConsumerState<ProductImageSection> createState() =>
      _ProductImageSectionState();
}

class _ProductImageSectionState extends ConsumerState<ProductImageSection> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.images]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final currentIndex =
        ref.watch(imageSliderIndexProvider(widget.productId));

    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: sorted.isEmpty
              ? _buildPlaceholder()
              : PageView.builder(
                  controller: _pageController,
                  itemCount: sorted.length,
                  onPageChanged: (i) {
                    ref
                        .read(imageSliderIndexProvider(widget.productId)
                            .notifier)
                        .state = i;
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      sorted[index].imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return _buildPlaceholder();
                      },
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    );
                  },
                ),
        ),
        if (widget.isBestSeller)
          Positioned(
            top: 96,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '베스트셀러',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (sorted.length > 1)
          Positioned(
            bottom: 12,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${currentIndex + 1} / ${sorted.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 100,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
