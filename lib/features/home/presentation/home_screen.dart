// 홈 화면: 앱의 메인 진입 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../features/cart/presentation/cart_screen.dart';
import '../../../features/category/presentation/category_screen.dart';
import '../../../features/product/domain/product_model.dart';
import '../../../features/product/presentation/product_detail_screen.dart';
import '../../../features/profile/presentation/profile_screen.dart';

/// 하단 네비게이션의 현재 선택된 탭 인덱스를 관리하는 프로바이더
final selectedNavIndexProvider = StateProvider<int>((ref) => NavIndex.home);

/// 홈 화면: Scaffold 전체 레이아웃 + 하단 네비게이션 바 포함
///
/// ConsumerWidget은 Riverpod 상태를 구독하는 StatelessWidget의 대체 위젯
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// 탭 인덱스에 따라 표시할 화면 목록
  static const List<Widget> _pages = [
    _HomeBody(),
    CategoryScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 탭 인덱스 구독
    final selectedIndex = ref.watch(selectedNavIndexProvider);

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
        actions: [
          // 검색 아이콘 버튼
          IconButton(
            onPressed: () {
              // 추후 검색 화면으로 이동
            },
            icon: const Icon(Icons.search, size: 26),
            color: AppColors.textPrimary,
            tooltip: '검색',
          ),

          // 알림 아이콘 버튼 (알림 뱃지 포함)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // 추후 알림 화면으로 이동
                  },
                  icon: const Icon(Icons.notifications_outlined, size: 26),
                  color: AppColors.textPrimary,
                  tooltip: '알림',
                ),
                // 알림 뱃지
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ─── 탭별 화면 본문 ─────────────────────────────────────────
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),

      // ─── 하단 네비게이션 바 ──────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            // 선택된 탭 인덱스 업데이트
            ref.read(selectedNavIndexProvider.notifier).state = index;
          },
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: '카테고리',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: '장바구니',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '마이 페이지',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 홈 탭 본문: 스크롤 가능한 콘텐츠 영역
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

          // 내 바이크 선택 카드
          _MyBikeCard(),

          const SizedBox(height: 16),

          // 배너 섹션
          _BannerSection(),

          const SizedBox(height: 24),

          // 인기 부품 섹션
          _PopularPartsSection(),

          const SizedBox(height: 24),

          // 빠른 접근 섹션
          _QuickAccessSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내 바이크 선택 카드
// ─────────────────────────────────────────────────────────────────────────────

class _MyBikeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // 바이크 아이콘
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.two_wheeler,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // 바이크 이름 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 바이크',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Honda CBR600RR',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),

            // 드롭다운 화살표
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 프로모션 배너 섹션
// ─────────────────────────────────────────────────────────────────────────────

class _BannerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.bannerBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '신제품 입고',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '2024 퍼포먼스 파츠 컬렉션',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '지금 쇼핑하기',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
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

class _PopularPartsSection extends StatelessWidget {
  /// 임시 상품 더미 데이터
  static const List<Map<String, dynamic>> _dummyProducts = [
    {
      'name': 'K&N 하이플로우 에어필터',
      'price': '₩89,900',
      'originalPrice': '₩110,000',
      'rating': 4.8,
      'reviews': 245,
      'isBestSeller': true,
      'isCompatible': true,
    },
    {
      'name': 'Brembo 브레이크 패드 세트',
      'price': '₩145,000',
      'originalPrice': null,
      'rating': 4.7,
      'reviews': 189,
      'isBestSeller': false,
      'isCompatible': true,
    },
    {
      'name': 'NGK 이리듐 스파크 플러그 (4개입)',
      'price': '₩64,900',
      'originalPrice': '₩79,900',
      'rating': 4.6,
      'reviews': 243,
      'isBestSeller': false,
      'isCompatible': true,
    },
    {
      'name': 'OEM 오일 필터 세트',
      'price': '₩24,900',
      'originalPrice': null,
      'rating': 4.5,
      'reviews': 567,
      'isBestSeller': false,
      'isCompatible': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
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
                  // 추후 전체 목록 화면으로 이동
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

        // 2열 그리드 상품 목록
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // childAspectRatio 대신 고정 픽셀 높이로 지정해 콘텐츠 overflow 방지
              mainAxisExtent: 270,
            ),
            itemCount: _dummyProducts.length,
            itemBuilder: (context, index) {
              final product = _dummyProducts[index];
              return _ProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }
}

/// 개별 상품 카드 위젯
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final isBestSeller = product['isBestSeller'] as bool;
    final isCompatible = product['isCompatible'] as bool;
    final originalPrice = product['originalPrice'] as String?;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: kSampleProductDetail),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지 영역
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 56,
                    color: AppColors.textHint,
                  ),
                ),
              ),

              // 베스트셀러 뱃지
              if (isBestSeller)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '베스트',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // 찜하기 버튼
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () {
                    // 추후 찜하기 기능 구현
                  },
                  icon: const Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),

          // 상품 정보 영역
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 호환성 뱃지
                if (isCompatible)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.compatible,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 10, color: Colors.white),
                        SizedBox(width: 3),
                        Text(
                          '호환 가능',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 6),

                // 상품명
                Text(
                  product['name'] as String,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // 별점 & 리뷰 수
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFFFB800)),
                    const SizedBox(width: 2),
                    Text(
                      '${product['rating']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product['reviews']})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 가격 정보
                Text(
                  product['price'] as String,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),

                // 할인 전 가격 (있을 경우에만 표시)
                if (originalPrice != null)
                  Text(
                    originalPrice,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textHint,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 빠른 접근 섹션 (서비스 카테고리 칩)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAccessSection extends StatelessWidget {
  /// 빠른 접근 메뉴 목록
  static const List<String> _menuItems = [
    '오일 교환',
    '브레이크 정비',
    '체인 관리',
    '타이어',
    '전기 부품',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '빠른 접근',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 12),

        // 수평 스크롤 칩 목록
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _menuItems.map((label) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    // 추후 해당 카테고리 화면으로 이동
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
