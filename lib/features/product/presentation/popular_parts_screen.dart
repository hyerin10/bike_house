import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/popular_parts_controller.dart';
import 'package:bike_house/features/product/presentation/widgets/popular_parts_product_grid.dart';
import 'package:bike_house/features/product/presentation/widgets/popular_parts_search_bar.dart';
import 'package:bike_house/features/product/presentation/widgets/popular_parts_sort_filter_bar.dart';

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
      body: asyncState.when(
        data: (state) => Column(
          children: [
            PopularPartsSearchBar(controller: _searchController),
            PopularPartsSortFilterBar(state: state),
            Expanded(child: PopularPartsProductGrid(state: state)),
          ],
        ),
        loading: () => Column(
          children: [
            PopularPartsSearchBar(controller: _searchController),
            const PopularPartsSortFilterBarPlaceholder(),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        error: (e, _) => Column(
          children: [
            PopularPartsSearchBar(controller: _searchController),
            const PopularPartsSortFilterBarPlaceholder(
              statusMessage: '목록을 불러오지 못했습니다',
            ),
            Expanded(
              child: Center(
                child: Text(
                  '상품을 불러오지 못했습니다.\n$e',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
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
