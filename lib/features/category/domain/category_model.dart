import 'package:flutter/material.dart';

/// 카테고리 항목 모델
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.productCount,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  final String id;
  final String name;
  final int productCount;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
}

/// 브랜드 모델
class BrandModel {
  const BrandModel({required this.name});

  final String name;
}

/// 카테고리 Mock 데이터
const List<CategoryModel> kCategories = [
  CategoryModel(
    id: 'maintenance',
    name: '정비',
    productCount: 245,
    icon: Icons.build_outlined,
    iconColor: Color(0xFF1A6BFF),
    iconBackgroundColor: Color(0xFFE8F0FF),
  ),
  CategoryModel(
    id: 'electrical',
    name: '전기',
    productCount: 128,
    icon: Icons.bolt_outlined,
    iconColor: Color(0xFFF59E0B),
    iconBackgroundColor: Color(0xFFFFF8E1),
  ),
  CategoryModel(
    id: 'engine',
    name: '엔진',
    productCount: 312,
    icon: Icons.settings_outlined,
    iconColor: Color(0xFFEF4444),
    iconBackgroundColor: Color(0xFFFFEBEB),
  ),
  CategoryModel(
    id: 'body',
    name: '바디',
    productCount: 189,
    icon: Icons.shield_outlined,
    iconColor: Color(0xFF22C55E),
    iconBackgroundColor: Color(0xFFEAFAF1),
  ),
  CategoryModel(
    id: 'convenience',
    name: '편의',
    productCount: 156,
    icon: Icons.inventory_2_outlined,
    iconColor: Color(0xFF8B5CF6),
    iconBackgroundColor: Color(0xFFF3EEFF),
  ),
  CategoryModel(
    id: 'brakes',
    name: '브레이크',
    productCount: 98,
    icon: Icons.circle_outlined,
    iconColor: Color(0xFFFF7C3A),
    iconBackgroundColor: Color(0xFFFFF0E8),
  ),
  CategoryModel(
    id: 'suspension',
    name: '서스펜션',
    productCount: 67,
    icon: Icons.swap_vert,
    iconColor: Color(0xFF38BDF8),
    iconBackgroundColor: Color(0xFFE8F7FF),
  ),
  CategoryModel(
    id: 'exhaust',
    name: '배기',
    productCount: 84,
    icon: Icons.air,
    iconColor: Color(0xFF6B7280),
    iconBackgroundColor: Color(0xFFF3F4F6),
  ),
];

/// 브랜드 Mock 데이터
const List<BrandModel> kFeaturedBrands = [
  BrandModel(name: 'K&N'),
  BrandModel(name: 'Brembo'),
  BrandModel(name: 'Yoshimura'),
  BrandModel(name: 'Akrapovic'),
  BrandModel(name: 'NGK'),
  BrandModel(name: 'Motul'),
];
