import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/filter_controller.dart';
import '../../application/popular_parts_controller.dart';

/// 필터 바텀시트 진입점 — `_SortFilterBar`에서 호출
void showFilterBottomSheet(
  BuildContext context,
  WidgetRef ref,
  PopularPartsState currentState,
) {
  // 바텀시트 오픈 전에 현재 적용 상태로 초안(draft) 초기화
  ref.read(filterControllerProvider.notifier).initFrom(
        minPrice: currentState.minPrice,
        maxPrice: currentState.maxPrice,
        selectedCategories: currentState.selectedCategories,
        onlyCompatible: currentState.showCompatibleOnly,
      );

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    // 키보드가 올라올 때 시트가 함께 밀리도록 설정
    builder: (ctx) => const FilterBottomSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FilterBottomSheet 위젯
// ─────────────────────────────────────────────────────────────────────────────

/// 가격 범위 · 카테고리 · 호환성 필터를 제공하는 바텀시트.
///
/// - 내부 상태 변경은 [filterControllerProvider]를 통해 관리한다.
/// - Apply 버튼을 누르면 [popularPartsControllerProvider]로 커밋된다.
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    // 현재 초안 상태로 컨트롤러 초기화 (ref.read — 구독 불필요)
    final filter = ref.read(filterControllerProvider);
    _minController = TextEditingController(
      text: filter.minPrice != null ? filter.minPrice!.toInt().toString() : '',
    );
    _maxController = TextEditingController(
      text: filter.maxPrice != null ? filter.maxPrice!.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _handleApply() {
    final filter = ref.read(filterControllerProvider);
    ref.read(popularPartsControllerProvider.notifier).applyFilter(
          minPrice: filter.minPrice,
          maxPrice: filter.maxPrice,
          selectedCategories: filter.selectedCategories,
          showCompatibleOnly: filter.onlyCompatible,
        );
    Navigator.of(context).pop();
  }

  void _handleCancel() => Navigator.of(context).pop();

  void _handleReset() {
    ref.read(filterControllerProvider.notifier).reset();
    _minController.clear();
    _maxController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 높이를 고려한 하단 패딩
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 상단 헤더 (Cancel / Filters / Apply) ──────────────────────────
          _FilterHeader(
            onCancel: _handleCancel,
            onApply: _handleApply,
          ),

          const Divider(height: 1, color: AppColors.divider),

          // ── 스크롤 가능한 본문 ─────────────────────────────────────────────
          ConstrainedBox(
            // 화면 높이의 80%를 넘지 않도록 제한
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8 -
                  bottomInset -
                  56, // 헤더 높이
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range 섹션
                  _PriceRangeSection(
                    minController: _minController,
                    maxController: _maxController,
                  ),

                  const SizedBox(height: 28),

                  // Categories 섹션
                  const _CategoriesSection(),

                  const SizedBox(height: 28),

                  // Compatibility 섹션
                  const _CompatibilitySection(),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 상단 헤더 ────────────────────────────────────────────────────────────────

class _FilterHeader extends ConsumerWidget {
  const _FilterHeader({required this.onCancel, required this.onApply});

  final VoidCallback onCancel;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActive = ref.watch(
      filterControllerProvider.select((s) => s.hasActiveFilters),
    );

    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cancel 버튼 (왼쪽)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // 타이틀 (중앙)
          const Text(
            'Filters',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          // Apply 버튼 (오른쪽)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onApply,
              child: Text(
                'Apply',
                style: TextStyle(
                  color: hasActive ? AppColors.primary : AppColors.textHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Price Range 섹션 ─────────────────────────────────────────────────────────

class _PriceRangeSection extends ConsumerWidget {
  const _PriceRangeSection({
    required this.minController,
    required this.maxController,
  });

  final TextEditingController minController;
  final TextEditingController maxController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(filterControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            // Min 입력
            Expanded(
              child: _PriceField(
                label: 'Min',
                controller: minController,
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  notifier.setMinPrice(parsed);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '–',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Max 입력
            Expanded(
              child: _PriceField(
                label: 'Max',
                controller: maxController,
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  notifier.setMaxPrice(parsed);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

// ─── Categories 섹션 ──────────────────────────────────────────────────────────

class _CategoriesSection extends ConsumerWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // selectedCategories 변경 시에만 이 위젯 리빌드
    final selected = ref.watch(
      filterControllerProvider.select((s) => s.selectedCategories),
    );
    final notifier = ref.read(filterControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kAllCategories.map((category) {
            final isSelected = selected.contains(category);
            return _CategoryChip(
              label: category,
              isSelected: isSelected,
              onTap: () => notifier.toggleCategory(category),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }
}

// ─── Compatibility 섹션 ───────────────────────────────────────────────────────

class _CompatibilitySection extends ConsumerWidget {
  const _CompatibilitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // onlyCompatible 변경 시에만 이 위젯 리빌드
    final onlyCompatible = ref.watch(
      filterControllerProvider.select((s) => s.onlyCompatible),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compatibility',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: onlyCompatible,
          onChanged: (_) =>
              ref.read(filterControllerProvider.notifier).toggleCompatibility(),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Only show ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                TextSpan(
                  text: 'compatible parts',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
          activeColor: AppColors.primary,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
