import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 관리자 상담 탭 전용 UI 토큰 (색, 공통 버튼 스타일)
abstract final class AdminChatUi {
  AdminChatUi._();

  static const Color waitingDot = Color(0xFFF59E0B);

  static const Color waitingBadgeBackground = Color(0xFFFEF3C7);
  static const Color waitingBadgeForeground = Color(0xFFD97706);

  static const Color avatarPlaceholderBackground = Color(0xFFF0F1F5);

  /// 상담중 표시(점, 입장 버튼 등) — 앱 호환 색과 동일 톤
  static const Color activeAccent = AppColors.compatible;

  /// 상담종료 표시 색상
  static const Color completedDot = Color(0xFF9CA3AF);
  static const Color completedBadgeBackground = Color(0xFFF3F4F6);
  static const Color completedBadgeForeground = Color(0xFF6B7280);

  static ButtonStyle compactElevatedButton(Color background) {
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    );
  }

  static const TextStyle compactElevatedLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
