import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/domain/product_model.dart';

/// 상품 특징 3열 그리드
class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key, required this.features});

  final List<ProductFeature> features;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: features.map((feature) {
        final isLast = feature == features.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: _FeatureItem(feature: feature),
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.feature});

  final ProductFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(feature.icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 6),
          Text(
            feature.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
