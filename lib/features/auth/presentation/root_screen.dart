import 'package:flutter/material.dart';

import '../../home/presentation/home_screen.dart';

/// 앱 최상위 진입 위젯.
///
/// 관리자 인증 상태는 HomeScreen 내부의 _AdminTabWrapper에서 처리합니다.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
