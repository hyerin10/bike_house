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

/// 상품 상세 도메인 모델
class ProductDetail {
  const ProductDetail({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.features,
    this.originalPrice,
    this.compatibleBike,
    this.isBestSeller = false,
  });

  final String id;
  final String name;

  /// 현재 판매가 (원)
  final int price;

  /// 할인 전 원가 (null이면 미할인)
  final int? originalPrice;

  final double rating;
  final int reviewCount;
  final String description;
  final List<ProductFeature> features;

  /// 호환 바이크 정보 (null이면 배너 미표시)
  final String? compatibleBike;

  final bool isBestSeller;

  /// 할인율 (originalPrice가 있을 때만 유효)
  int? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100).round();
  }

  String get formattedPrice =>
      '₩${price.toString().replaceAllMapped(_comma, (m) => '${m[1]},')}';

  String? get formattedOriginalPrice => originalPrice == null
      ? null
      : '₩${originalPrice.toString().replaceAllMapped(_comma, (m) => '${m[1]},')}';

  static final _comma = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock 상품 상세 데이터
// ─────────────────────────────────────────────────────────────────────────────

const kSampleProductDetail = ProductDetail(
  id: 'p001',
  name: 'K&N 하이플로우 에어필터',
  price: 89900,
  originalPrice: 109900,
  rating: 4.8,
  reviewCount: 324,
  compatibleBike: 'Honda CBR600RR 2024',
  isBestSeller: true,
  description:
      '오토바이 성능을 향상시키기 위해 설계된 프리미엄 품질의 부품입니다. '
      '정밀한 엔지니어링과 내구성 있는 소재로 제작되어 장기간 안정적인 신뢰성을 제공합니다. '
      '포괄적인 설명서가 포함되어 간편하게 설치할 수 있습니다.',
  features: [
    ProductFeature(icon: Icons.local_shipping_outlined, label: '무료 배송'),
    ProductFeature(icon: Icons.shield_outlined, label: '2년 보증'),
    ProductFeature(icon: Icons.replay_outlined, label: '쉬운 반품'),
  ],
);
