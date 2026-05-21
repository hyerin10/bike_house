// 홈 화면: 앱의 메인 진입 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/constants.dart';
import 'package:bike_house/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:bike_house/features/cart/presentation/cart_screen.dart';
import 'package:bike_house/features/product/application/product_notifier.dart';
import 'package:bike_house/features/product/presentation/search_result_screen.dart';
import 'package:bike_house/features/product/presentation/widgets/product_card.dart';
import 'package:bike_house/features/profile/presentation/admin_login_screen.dart';
import 'package:bike_house/features/profile/presentation/my_page_screen.dart';
import 'package:bike_house/providers/auth_provider.dart';
import 'package:bike_house/features/home/presentation/widgets/home_search_bar.dart';

/// 하단 네비게이션의 현재 선택된 탭 인덱스를 관리하는 프로바이더
final selectedNavIndexProvider = StateProvider<int>((ref) => NavIndex.home);

/// 홈 화면: Scaffold 전체 레이아웃 + 하단 네비게이션 바 포함
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    _HomeBody(),
    CartScreen(),
    MyPageScreen(),
    _AdminTabWrapper(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    // 관리자 여부 조회 중 — 로딩 스플래시
    if (isAdminAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdmin = isAdminAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ─── 상단 앱바 ───────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kAppName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              kAppSlogan,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: const [],
        bottom: selectedIndex == NavIndex.home
            ? const PreferredSize(
                preferredSize: Size.fromHeight(84),
                child: HomeSearchBar(),
              )
            : const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.divider),
              ),
      ),

      // ─── 탭별 화면 본문 ─────────────────────────────────────────
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),

      // ─── 하단 네비게이션 바 ──────────────────────────────────────
      bottomNavigationBar: _AdminAwareBottomNav(
        selectedIndex: selectedIndex,
        isAdmin: isAdmin,
        onTap: (index) {
          // 관리자 모드에서 비활성 탭 차단
          if (isAdmin &&
              (index == NavIndex.cart || index == NavIndex.myPage)) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                const SnackBar(
                  content: Text('관리자 모드에서는 사용할 수 없는 메뉴입니다.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            return;
          }
          ref.read(selectedNavIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 홈 탭 본문
// ─────────────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _BannerSection(),
          const SizedBox(height: 24),
          const _PopularPartsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 웰컴 배너 섹션
// ─────────────────────────────────────────────────────────────────────────────

class _BannerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A6BFF), Color(0xFF4D8FFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bike_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              '오늘도 안전하게, 즐거운 라이딩 하세요!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 인기 부품 섹션
// ─────────────────────────────────────────────────────────────────────────────

class _PopularPartsSection extends ConsumerWidget {
  const _PopularPartsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인기 부품',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    '내 바이크에 맞는 부품',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SearchResultScreen(),
                    ),
                  );
                },
                child: Text(
                  '전체 보기',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        asyncProducts.when(
          loading: () => const SizedBox(
            height: 270,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 8),
                Text(
                  '상품을 불러오지 못했습니다.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => ref.read(productProvider.notifier).refresh(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
          data: (products) {
            final preview = products.take(4).toList();
            if (preview.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '등록된 상품이 없습니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: productCardGridAspectRatio(context),
                ),
                itemCount: preview.length,
                itemBuilder: (context, index) =>
                    ProductCard(product: preview[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 관리자 탭 래퍼: admins 테이블 기반으로 대시보드 or 로그인 화면 분기
// ─────────────────────────────────────────────────────────────────────────────

class _AdminTabWrapper extends ConsumerWidget {
  const _AdminTabWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);

    return isAdminAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const AdminLoginScreen(),
      data: (isAdmin) =>
          isAdmin ? const AdminDashboardScreen() : const AdminLoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 관리자 인식 바텀 네비게이션 바
// ─────────────────────────────────────────────────────────────────────────────

class _AdminAwareBottomNav extends StatelessWidget {
  const _AdminAwareBottomNav({
    required this.selectedIndex,
    required this.isAdmin,
    required this.onTap,
  });

  final int selectedIndex;
  final bool isAdmin;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: '홈'),
    (
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: '장바구니'
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: '마이페이지'
    ),
    (
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings,
      label: '관리자'
    ),
  ];

  bool _isDisabled(int index) =>
      isAdmin && (index == NavIndex.cart || index == NavIndex.myPage);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = selectedIndex == index;
              final disabled = _isDisabled(index);

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Opacity(
                    opacity: disabled ? 0.30 : 1.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
