import 'package:flutter/material.dart';

import 'package:bike_house/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:bike_house/features/profile/presentation/admin_login_screen.dart';

/// 부모에서 `isAdminProvider` 로딩이 끝난 뒤 전달되는 관리자 여부로 화면을 고릅니다.
class AdminTabContent extends StatelessWidget {
  const AdminTabContent({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return isAdmin ? const AdminDashboardScreen() : const AdminLoginScreen();
  }
}
