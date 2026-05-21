import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 위시리스트 화면 상단 앱바
PreferredSizeWidget buildWishlistAppBar(
  BuildContext context, {
  required int itemCount,
}) {
  return AppBar(
    backgroundColor: AppColors.surface,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
    ),
    title: const Text(
      '위시리스트',
      style: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    ),
    actions: [
      if (itemCount > 0)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$itemCount개',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
