import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 상품 설명 텍스트 섹션
class DescriptionSection extends StatelessWidget {
  const DescriptionSection({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상품 설명',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
