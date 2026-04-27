import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/search_result_notifier.dart';
import '../data/product_model.dart';
import 'widgets/product_card.dart';

/// 검색 결과 및 전체 상품 목록 화면
///
/// - [searchQuery] == null  → 전체 상품을 표시
/// - [searchQuery] != null  → 해당 검색어로 필터링된 결과를 표시
///
/// 화면 내부의 검색창에서 새 검색어를 입력하면 결과가 즉시 갱신됩니다.
class SearchResultScreen extends ConsumerStatefulWidget {
  const SearchResultScreen({super.key, this.searchQuery});

  final String? searchQuery;

  @override
  ConsumerState<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends ConsumerState<SearchResultScreen> {
  late final TextEditingController _controller;
  late String? _currentQuery;

  @override
  void initState() {
    super.initState();
    final initial = (widget.searchQuery?.trim().isEmpty ?? true)
        ? null
        : widget.searchQuery?.trim();
    _currentQuery = initial;
    _controller = TextEditingController(text: initial ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final trimmed = value.trim();
    setState(() {
      _currentQuery = trimmed.isEmpty ? null : trimmed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(searchResultProvider(_currentQuery));
    final appBarTitle =
        _currentQuery != null ? '"$_currentQuery" 검색 결과' : '전체 상품';

    return Scaffold(
      backgroundColor: AppColors.background,

      // ─── 상단 앱바 ───────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          appBarTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),

      body: Column(
        children: [
          // ─── 검색 입력창 ───────────────────────────────────────────
          _SearchField(
            controller: _controller,
            onSearch: _onSearch,
          ),

          // ─── 결과 카운트 바 + 본문 ────────────────────────────────
          Expanded(
            child: asyncProducts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                onRetry: () => ref.refresh(searchResultProvider(_currentQuery)),
              ),
              data: (products) => _ResultBody(
                products: products,
                query: _currentQuery,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 검색 입력창
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: TextField(
        controller: controller,
        onSubmitted: onSearch,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: '상품명을 검색하세요',
          hintStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 22,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            color: AppColors.primary,
            tooltip: '검색',
            onPressed: () => onSearch(controller.text),
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
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 결과 본문: 카운트 바 + 그리드
// ─────────────────────────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.products, required this.query});

  final List<ProductModel> products;
  final String? query;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 결과 수 표시 바
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              Text(
                '${products.length}개 상품',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),

        // 상품 그리드 or 빈 상태
        Expanded(
          child: products.isEmpty
              ? _EmptyState(query: query)
              : _ProductGrid(products: products),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 그리드
// ─────────────────────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: productCardGridAspectRatio(context),
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 빈 상태 (검색 결과 없음)
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String? query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            query != null ? '"$query"에 대한\n검색 결과가 없습니다.' : '등록된 상품이 없습니다.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 에러 상태
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            '상품을 불러오지 못했습니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
