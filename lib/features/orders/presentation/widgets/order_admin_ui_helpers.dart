import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/orders/presentation/widgets/order_card.dart';

/// 관리자 주문 화면용 확인 다이얼로그.
Future<bool?> showOrderAdminConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmLabel,
  required Color confirmColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text(
            '아니요',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(
            confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

void showOrderAdminSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(message),
        ],
      ),
      backgroundColor: const Color(0xFF323232),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

void showOrderAdminErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

/// 로딩용 `StateProvider<int?>`를 설정한 뒤 액션을 실행하고 스낵바로 결과를 알립니다.
Future<void> runOrderAdminMutation(
  BuildContext context,
  WidgetRef ref, {
  required StateProvider<int?> loadingIdProvider,
  required int orderId,
  required Future<void> Function() action,
  required String successMessage,
}) async {
  ref.read(loadingIdProvider.notifier).state = orderId;
  try {
    await action();
    if (context.mounted) {
      showOrderAdminSuccessSnackBar(context, successMessage);
    }
  } catch (e) {
    if (context.mounted) {
      showOrderAdminErrorSnackBar(
        context,
        orderParseErrorMessage(e.toString()),
      );
    }
  } finally {
    ref.read(loadingIdProvider.notifier).state = null;
  }
}
