// 앱 전체에서 사용하는 테마 정의
import 'package:flutter/material.dart';

/// Bike House 앱의 색상 및 테마 상수
class AppColors {
  AppColors._();

  // 주요 색상
  static const Color primary = Color(0xFF1A6BFF);
  static const Color primaryLight = Color(0xFFE8F0FF);
  static const Color accent = Color(0xFFFF4C00);

  // 배경 색상
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);

  // 배너 색상
  static const Color bannerBackground = Color(0xFFE8523A);

  // 호환성 표시 색상
  static const Color compatible = Color(0xFF22C55E);

  // 구분선 색상
  static const Color divider = Color(0xFFE5E7EB);

  // 마이페이지 전용 색상
  static const Color wishlistRed = Color(0xFFFF4C6A);
  static const Color dangerRed = Color(0xFFE5534B);
  static const Color dangerBg = Color(0xFFFFECEC);
  static const Color chatPromptBg = Color(0xFFEFF6FF);
  static const Color avatarBg = Color(0xFFD6E4FF);

  /// 관리자 로그인 배지(방패) 원형 배경
  static const Color adminShieldBackground = Color(0xFF1A2A3A);

  /// 1:1 상담 — 답변대기(진행 중) 강조
  static const Color inquiryPendingIcon = Color(0xFFF59E0B);
  static const Color inquiryPendingBg = Color(0xFFFEF3C7);

  /// 1:1 상담 — 상담종료 강조
  static const Color inquiryCompletedIcon = Color(0xFF22C55E);
  static const Color inquiryCompletedBg = Color(0xFFDCFCE7);
}

/// 앱 테마 설정
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // 하단 네비게이션 바 테마
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 카드 테마
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.divider),
        ),
      ),

      // 텍스트 테마
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          color: AppColors.textHint,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
