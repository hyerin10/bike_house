import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/popular_parts_controller.dart';

/// 인기 부품 화면 상단 검색 필드
class PopularPartsSearchBar extends ConsumerWidget {
  const PopularPartsSearchBar({super.key, required this.controller});

  final TextEditingController controller;

  static const _radius = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rounded = BorderRadius.circular(_radius);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          ref
              .read(popularPartsControllerProvider.notifier)
              .updateSearchQuery(value);
        },
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search for parts...',
          hintStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 22,
          ),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: rounded,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: rounded,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: rounded,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}
