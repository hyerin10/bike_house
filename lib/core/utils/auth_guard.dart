import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/auth/presentation/login_screen.dart';
import 'package:bike_house/providers/auth_provider.dart';

/// 로그인 여부를 확인하고, 비로그인 시 AlertDialog를 표시합니다.
///
/// - **로그인 상태**: [onAuthenticated] 콜백을 즉시 실행합니다.
/// - **비로그인 상태**: "로그인이 필요합니다" 다이얼로그를 표시합니다.
///   [확인]을 누르면 [LoginScreen]으로 이동하고, [취소]를 누르면 그대로 닫힙니다.
///
/// ### 사용 예시
/// ```dart
/// onPressed: () => requireAuth(context, ref, () {
///   // 로그인된 경우에만 실행될 로직
///   Navigator.of(context).push(...);
/// }),
/// ```
Future<void> requireAuth(
  BuildContext context,
  WidgetRef ref,
  VoidCallback onAuthenticated,
) async {
  final user = ref.read(authProvider);

  if (user != null) {
    onAuthenticated();
    return;
  }

  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('로그인 필요'),
      content: const Text('로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('확인'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
