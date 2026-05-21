import 'package:flutter/material.dart';

import 'package:bike_house/core/widgets/app_product_search_field.dart';

class AdminProductSearchBar extends StatelessWidget {
  const AdminProductSearchBar({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppProductSearchBar(
      hintText: '상품명으로 검색...',
      wrapWithBackground: false,
      padding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}
