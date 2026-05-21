import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/filter_controller.dart';
import 'package:bike_house/features/product/application/popular_parts_controller.dart';

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
      );

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const FilterBottomSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FilterBottomSheet 위젯
// ─────────────────────────────────────────────────────────────────────────────

/// 가격 범위 필터를 제공하는 바텀시트.
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
            onReset: _handleReset,
          ),

          const Divider(height: 1, color: AppColors.divider),

          // ── Price Range 섹션 ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: _PriceRangeSection(
              minController: _minController,
              maxController: _maxController,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 상단 헤더 ────────────────────────────────────────────────────────────────

class _FilterHeader extends ConsumerWidget {
  const _FilterHeader({
    required this.onCancel,
    required this.onApply,
    required this.onReset,
  });

  final VoidCallback onCancel;
  final VoidCallback onApply;
  final VoidCallback onReset;

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

          // Apply / Reset 버튼 (오른쪽)
          Align(
            alignment: Alignment.centerRight,
            child: hasActive
                ? TextButton(
                    onPressed: onReset,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: onApply,
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: AppColors.primary,
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
            Expanded(
              child: _PriceField(
                label: 'Min',
                controller: minController,
                onChanged: (val) => notifier.setMinPrice(double.tryParse(val)),
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
            Expanded(
              child: _PriceField(
                label: 'Max',
                controller: maxController,
                onChanged: (val) => notifier.setMaxPrice(double.tryParse(val)),
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
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
