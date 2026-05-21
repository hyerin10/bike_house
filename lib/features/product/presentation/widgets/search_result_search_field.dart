import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

InputDecoration searchResultSearchFieldDecoration(BuildContext context) {
  const radius = 12.0;
  final unfocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    hintText: '상품명을 검색하세요',
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
    border: unfocusedBorder,
    enabledBorder: unfocusedBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12),
    isDense: true,
  );
}

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
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: TextField(
        controller: controller,
        onSubmitted: onSearch,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: searchResultSearchFieldDecoration(context).copyWith(
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            color: AppColors.primary,
            tooltip: '검색',
            onPressed: () => onSearch(controller.text),
          ),
        ),
      ),
    );
  }
}
