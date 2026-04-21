// 앱 진입점: ProviderScope로 Riverpod 상태 관리 초기화
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(
    // Riverpod 전역 상태 관리를 위해 앱 전체를 ProviderScope로 감쌈
    const ProviderScope(
      child: BikeHouseApp(),
    ),
  );
}

/// Bike House 앱의 루트 위젯
class BikeHouseApp extends StatelessWidget {
  const BikeHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 앱 이름 설정 (OS 작업 관리자, 멀티태스킹 화면에 표시)
      title: kAppName,

      // 디버그 배너 비활성화
      debugShowCheckedModeBanner: false,

      // 앱 전체 테마 적용
      theme: AppTheme.lightTheme,

      // 홈 화면으로 진입
      home: const HomeScreen(),
    );
  }
}
