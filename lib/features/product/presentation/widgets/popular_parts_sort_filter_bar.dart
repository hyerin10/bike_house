import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/popular_parts_controller.dart';
import 'package:bike_house/features/product/presentation/widgets/filter_bottom_sheet.dart';

/// 정렬·가격 필터 컨트롤 (데이터 로드 완료 후)
class PopularPartsSortFilterBar extends ConsumerWidget {
  const PopularPartsSortFilterBar({super.key, required this.state});

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
          Text(
            '$count 개 상품',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Sort by:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
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
              IconButton(
                onPressed: () => showFilterBottomSheet(context, ref, state),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
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

/// 로딩·에러 시에도 정렬 바 영역 높이를 유지하기 위한 자리 표시자
class PopularPartsSortFilterBarPlaceholder extends StatelessWidget {
  const PopularPartsSortFilterBarPlaceholder({
    super.key,
    this.statusMessage = '불러오는 중…',
  });

  /// 상단 카운트 자리에 표시할 안내 문구 (로딩 / 에러 등)
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Text(
            statusMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Sort by:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.45,
                child: IgnorePointer(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SortOption>(
                      value: SortOption.newest,
                      isDense: true,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                      onChanged: null,
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
                ),
              ),
              const Spacer(),
              const IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.tune_rounded,
                  color: AppColors.textHint,
                  size: 22,
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
