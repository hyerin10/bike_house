import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/widgets/app_product_search_field.dart';

/// 검색 결과 화면 상단 검색 입력창
class SearchResultSearchField extends StatelessWidget {
  const SearchResultSearchField({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return AppProductSearchBar(
      controller: controller,
      hintText: '상품명을 검색하세요',
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      onSubmitted: onSearch,
      suffixIcon: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        color: AppColors.primary,
        tooltip: '검색',
        onPressed: () => onSearch(controller.text),
      ),
    );
  }
}
