import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/widgets/app_product_search_field.dart';
import 'package:bike_house/features/product/application/popular_parts_controller.dart';

/// 인기 부품 화면 상단 검색 필드
class PopularPartsSearchBar extends ConsumerWidget {
  const PopularPartsSearchBar({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppProductSearchBar(
      controller: controller,
      hintText: 'Search for parts...',
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      onChanged: (value) {
        ref
            .read(popularPartsControllerProvider.notifier)
            .updateSearchQuery(value);
      },
    );
  }
}
