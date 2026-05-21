import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/dashboard_row.dart';
import 'widgets/guest/guest_my_page_body.dart';
import 'widgets/logout_button.dart';
import 'widgets/menu_list.dart';
import 'widgets/profile_card.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: GuestMyPageBody(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('마이페이지', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 2),
            Text(
              '오토바이 부속품 주문·배송 조회',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            const ProfileCard(),
            const SizedBox(height: 20),
            const DashboardRow(),
            const SizedBox(height: 20),
            const MenuList(),
            const SizedBox(height: 20),
            const LogoutButton(),
          ],
        ),
      ),
    );
  }
}
