import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/presentation/widgets/product_form_widgets.dart';

class EditProductBestSellerSection extends StatelessWidget {
  const EditProductBestSellerSection({
    super.key,
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '베스트셀러',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
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
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
