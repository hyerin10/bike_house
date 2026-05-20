import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/search_provider.dart';
import '../../../product/presentation/search_result_screen.dart';

/// 홈 화면 AppBar 하단에 배치되는 검색바 위젯.
///
/// - 텍스트 변경 시 [searchQueryProvider]를 갱신하되, 검색바 자체는 리빌드하지 않는다.
/// - 키보드 검색 버튼 또는 우측 화살표 아이콘을 누르면 [SearchResultScreen]으로 이동한다.
/// - '전체보기'를 누르면 query 없이 [SearchResultScreen]으로 이동해 전체 상품을 보여준다.
class HomeSearchBar extends ConsumerStatefulWidget {
  const HomeSearchBar({super.key});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToResults({String? query}) {
    final trimmed = (query ?? _controller.text).trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultScreen(
          searchQuery: trimmed.isEmpty ? null : trimmed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 검색 텍스트필드
          TextField(
            controller: _controller,
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            onSubmitted: (value) => _navigateToResults(query: value),
            textInputAction: TextInputAction.search,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: '상품명으로 검색...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textHint,
                  ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                color: AppColors.primary,
                tooltip: '검색',
                onPressed: _navigateToResults,
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

        ],
      ),
    );
  }
}
