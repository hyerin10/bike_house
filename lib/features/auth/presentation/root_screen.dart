import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/presentation/admin_login_screen.dart';

/// 앱 최상위 인증 가드 위젯.
///
/// [authProvider]를 구독하여 로그인 여부에 따라
/// [HomeScreen] 또는 [AdminLoginScreen]을 렌더링합니다.
class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return user != null ? const HomeScreen() : const AdminLoginScreen();
  }
}
