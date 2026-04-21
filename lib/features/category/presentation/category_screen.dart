import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/category_model.dart';

/// 카테고리 목록 화면
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CategoryBody();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 카테고리 화면 본문
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBody extends StatelessWidget {
  const _CategoryBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // 헤더
          const _CategoryHeader(),

          const SizedBox(height: 16),

          // 검색 바
          const _CategorySearchBar(),

          const SizedBox(height: 16),

          // 카테고리 리스트
          _CategoryList(),

          const SizedBox(height: 28),

          // 주요 브랜드 섹션
          _FeaturedBrandsSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 헤더: 타이틀 + 서브타이틀
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카테고리',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 2),
          Text(
            '파트별 탐색',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 검색 바
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySearchBar extends StatelessWidget {
  const _CategorySearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: '카테고리 검색...',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textHint,
                ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textHint,
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 카테고리 리스트 (ListView.separated)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _CategoryListItem(category: kCategories[index]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 카테고리 항목 카드
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryListItem extends StatelessWidget {
  const _CategoryListItem({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 추후 카테고리 상세 화면으로 이동
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // 카테고리 아이콘
            _CategoryIcon(category: category),

            const SizedBox(width: 14),

            // 카테고리 이름 + 상품 개수
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.productCount}개 상품',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),

            // 이동 화살표
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 아이콘 위젯
class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: category.iconBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        category.icon,
        color: category.iconColor,
        size: 26,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 주요 브랜드 섹션
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedBrandsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '주요 브랜드',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),

        const SizedBox(height: 14),

        // 브랜드 그리드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 64,
            ),
            itemCount: kFeaturedBrands.length,
            itemBuilder: (context, index) {
              return _BrandCard(brand: kFeaturedBrands[index]);
            },
          ),
        ),
      ],
    );
  }
}

/// 브랜드 카드 위젯
class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.brand});

  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 추후 브랜드 상세 화면으로 이동
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          brand.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
