import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

class AdminProductSearchBar extends StatelessWidget {
  const AdminProductSearchBar({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '상품명으로 검색...',
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon:
            const Icon(Icons.search, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
