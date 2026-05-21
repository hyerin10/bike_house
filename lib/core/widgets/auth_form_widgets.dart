import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 폼 필드 위 라벨 (로그인·회원가입 공통)
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

/// 서버·폼 오류 메시지 배너
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.dangerRed,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 인라인 필드 검증 오류 (배너와 구분되는 한 줄 텍스트)
class AuthFieldErrorText extends StatelessWidget {
  const AuthFieldErrorText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.dangerRed,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

InputDecoration authTextFieldDecoration({
  required String hintText,
  required IconData prefixIcon,
  Widget? suffix,
  bool hasError = false,
}) {
  final borderColor = hasError ? AppColors.dangerRed : AppColors.divider;
  final focusBorderColor = hasError ? AppColors.dangerRed : AppColors.primary;

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    prefixIcon: Icon(prefixIcon, color: AppColors.textHint, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: focusBorderColor, width: 1.5),
    ),
  );
}

/// "앞 문구 + 탭 가능 링크" 한 줄. [TapGestureRecognizer]를 dispose한다.
class AuthInlineNavLink extends StatefulWidget {
  const AuthInlineNavLink({
    super.key,
    required this.leadingText,
    required this.linkText,
    required this.onLinkTap,
  });

  final String leadingText;
  final String linkText;
  final VoidCallback onLinkTap;

  @override
  State<AuthInlineNavLink> createState() => _AuthInlineNavLinkState();
}

class _AuthInlineNavLinkState extends State<AuthInlineNavLink> {
  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = widget.onLinkTap;
  }

  @override
  void didUpdateWidget(AuthInlineNavLink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onLinkTap != widget.onLinkTap) {
      _recognizer.onTap = widget.onLinkTap;
    }
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return Text.rich(
      TextSpan(
        text: widget.leadingText,
        style: baseStyle,
        children: [
          TextSpan(
            text: widget.linkText,
            style: baseStyle?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            recognizer: _recognizer,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
