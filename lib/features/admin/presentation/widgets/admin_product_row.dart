import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/format_krw.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_product_table_layout.dart';
import 'package:bike_house/features/product/data/product_model.dart';

class AdminProductRow extends StatelessWidget {
  const AdminProductRow({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final stock = product.stock ?? 0;
    final isOutOfStock = stock == 0;
    final isLowStock = stock > 0 && stock <= 5;
    final thumbnailUrl = product.thumbnailUrl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: AdminProductTableLayout.thumbSize,
              height: AdminProductTableLayout.thumbSize,
              child: thumbnailUrl != null
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const _ProductThumbnailPlaceholder(),
                    )
                  : const _ProductThumbnailPlaceholder(),
            ),
          ),
          const SizedBox(width: AdminProductTableLayout.gapAfterThumb),
          Expanded(
            flex: AdminProductTableLayout.nameFlex,
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: AdminProductTableLayout.priceWidth,
            child: Text(
              formatKrw(product.price),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AdminProductTableLayout.gapAfterPrice),
          SizedBox(
            width: AdminProductTableLayout.stockWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? const Color(0xFFFFEDED)
                    : isLowStock
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$stock',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isOutOfStock
                      ? AppColors.accent
                      : isLowStock
                          ? const Color(0xFFE65100)
                          : const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          const SizedBox(width: AdminProductTableLayout.gapAfterStock),
          SizedBox(
            width: AdminProductTableLayout.actionsWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onEdit,
                  tooltip: '수정',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 28),
                    fixedSize: const Size(24, 28),
                  ),
                  iconSize: 19,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  tooltip: '삭제',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 28),
                    fixedSize: const Size(24, 28),
                  ),
                  iconSize: 19,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductThumbnailPlaceholder extends StatelessWidget {
  const _ProductThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F1F5),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textHint,
        size: 20,
      ),
    );
  }
}
