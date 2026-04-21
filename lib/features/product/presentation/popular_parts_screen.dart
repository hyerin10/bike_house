import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/popular_parts_controller.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/product_card.dart';

/// 인기 부품 전체 목록 화면
class PopularPartsScreen extends ConsumerStatefulWidget {
  const PopularPartsScreen({super.key});

  @override
  ConsumerState<PopularPartsScreen> createState() => _PopularPartsScreenState();
}

class _PopularPartsScreenState extends ConsumerState<PopularPartsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(popularPartsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 검색바
          _SearchBar(controller: _searchController),

          // 정렬 + 필터 컨트롤
          asyncState.when(
            data: (state) => _SortFilterBar(state: state),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // 상품 그리드
          Expanded(
            child: asyncState.when(
              data: (state) => _ProductGrid(state: state),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '상품을 불러오지 못했습니다.\n$e',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Popular Parts',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    );
  }
}

// ─── 검색바 ───────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          ref
              .read(popularPartsControllerProvider.notifier)
              .updateSearchQuery(value);
        },
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search for parts...',
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}

// ─── 정렬 / 필터 컨트롤 바 ────────────────────────────────────────────────────

class _SortFilterBar extends ConsumerWidget {
  const _SortFilterBar({required this.state});

  final PopularPartsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(popularPartsControllerProvider.notifier);
    final count = state.filteredProducts.length;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),

          // 상품 수
          Text(
            '$count 개 상품',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: 8),

          // Sort by 드롭다운 + 필터 아이콘
          Row(
            children: [
              // "Sort by:" 레이블
              Text(
                'Sort by:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),

              // 드롭다운
              DropdownButtonHideUnderline(
                child: DropdownButton<SortOption>(
                  value: state.sortBy,
                  isDense: true,
                  style: Theme.of(context).textTheme.titleMedium,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  onChanged: (option) {
                    if (option != null) controller.updateSort(option);
                  },
                  items: SortOption.values
                      .map(
                        (opt) => DropdownMenuItem(
                          value: opt,
                          child: Text(opt.label),
                        ),
                      )
                      .toList(),
                ),
              ),

              const Spacer(),

              // 필터 아이콘 버튼
              IconButton(
                onPressed: () =>
                    showFilterBottomSheet(context, ref, state),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    // 필터가 하나라도 활성화되면 파란 뱃지 표시
                    if (state.hasActiveFilters)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: '필터',
              ),
            ],
          ),
        ],
      ),
    );
  }

}

// ─── 상품 그리드 ──────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.state});

  final PopularPartsState state;

  @override
  Widget build(BuildContext context) {
    final products = state.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              '검색 결과가 없습니다.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 270,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
