import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/product/application/search_query_utils.dart';
import 'package:bike_house/features/product/application/search_result_notifier.dart';
import 'package:bike_house/features/product/presentation/widgets/search_result_body.dart';
import 'package:bike_house/features/product/presentation/widgets/search_result_error_view.dart';
import 'package:bike_house/features/product/presentation/widgets/search_result_search_field.dart';

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
  late String? _submittedQuery;

  @override
  void initState() {
    super.initState();
    _submittedQuery = normalizeSearchQuery(widget.searchQuery);
    _controller = TextEditingController(text: _submittedQuery ?? '');
  }

  @override
  void didUpdateWidget(SearchResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = normalizeSearchQuery(widget.searchQuery);
    final prev = normalizeSearchQuery(oldWidget.searchQuery);
    if (next != prev) {
      setState(() {
        _submittedQuery = next;
        _controller.text = next ?? '';
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    setState(() {
      _submittedQuery = normalizeSearchQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(searchResultProvider(_submittedQuery));
    final appBarTitle = _submittedQuery != null
        ? '"$_submittedQuery" 검색 결과'
        : '전체 상품';

    return Scaffold(
      backgroundColor: AppColors.background,
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
          SearchResultSearchField(
            controller: _controller,
            onSearch: _onSearch,
          ),
          Expanded(
            child: asyncProducts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => SearchResultErrorView(
                onRetry: () => ref
                    .read(searchResultProvider(_submittedQuery).notifier)
                    .refresh(),
              ),
              data: (products) => SearchResultBody(
                products: products,
                query: _submittedQuery,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
