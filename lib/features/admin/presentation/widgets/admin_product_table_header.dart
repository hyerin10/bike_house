import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/admin/presentation/widgets/admin_product_table_layout.dart';

class AdminProductTableHeader extends StatelessWidget {
  const AdminProductTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: AdminProductTableLayout.thumbSize),
          SizedBox(width: AdminProductTableLayout.gapAfterThumb),
          Expanded(
            flex: AdminProductTableLayout.nameFlex,
            child: Text(
              '상품명',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: AdminProductTableLayout.priceWidth,
            child: Text(
              '가격',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(width: AdminProductTableLayout.gapAfterPrice),
          SizedBox(
            width: AdminProductTableLayout.stockWidth,
            child: Text(
              '재고',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(width: AdminProductTableLayout.gapAfterStock),
          SizedBox(
            width: AdminProductTableLayout.actionsWidth,
            child: Text(
              '수정/삭제',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
