import 'package:flutter/material.dart';

/// 상품 특징 항목 모델
class ProductFeature {
  const ProductFeature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

/// 상품 상세·목업에서 공통으로 쓰는 기본 혜택(배송/보증/반품) 목록
const kDefaultProductFeatures = <ProductFeature>[
  ProductFeature(icon: Icons.local_shipping_outlined, label: '무료 배송'),
  ProductFeature(icon: Icons.shield_outlined, label: '2년 보증'),
  ProductFeature(icon: Icons.replay_outlined, label: '쉬운 반품'),
];
