// 홈 화면: 앱의 메인 진입 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/constants.dart';
import 'package:bike_house/features/cart/presentation/cart_screen.dart';
import 'package:bike_house/features/home/application/selected_nav_index_provider.dart';
import 'package:bike_house/features/home/presentation/show_admin_restricted_nav_snackbar.dart';
import 'package:bike_house/features/home/presentation/widgets/admin_tab_content.dart';
import 'package:bike_house/features/home/presentation/widgets/home_app_bar.dart';
import 'package:bike_house/features/home/presentation/widgets/home_body.dart';
import 'package:bike_house/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:bike_house/features/profile/presentation/my_page_screen.dart';
import 'package:bike_house/providers/auth_provider.dart';

/// 홈 화면: Scaffold 전체 레이아웃 + 하단 네비게이션 바 포함
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    if (isAdminAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdmin = isAdminAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeAppBar(selectedIndex: selectedIndex),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const HomeBody(),
          const CartScreen(),
          const MyPageScreen(),
          AdminTabContent(isAdmin: isAdmin),
        ],
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        selectedIndex: selectedIndex,
        isAdmin: isAdmin,
        onTap: (index) {
          if (isAdmin &&
              (index == NavIndex.cart || index == NavIndex.myPage)) {
            showAdminRestrictedNavSnackBar(context);
            return;
          }
          ref.read(selectedNavIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
