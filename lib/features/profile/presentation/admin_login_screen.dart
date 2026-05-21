import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/widgets/auth_form_widgets.dart';
import 'package:bike_house/features/profile/application/admin_login_controller.dart';

/// 관리자 로그인 화면
class AdminLoginScreen extends ConsumerWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Material(
      color: AppColors.background,
      child: Column(
        children: [
          _AdminLoginHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  _AdminBadge(),
                  SizedBox(height: 40),
                  _LoginFormCard(),
                  SizedBox(height: 32),
                  _SecurityFooter(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 헤더
// ─────────────────────────────────────────────────────────────────────────────

class _AdminLoginHeader extends StatelessWidget {
  const _AdminLoginHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Text(
        '관리자 로그인',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 방패 아이콘 + 타이틀 영역
// ─────────────────────────────────────────────────────────────────────────────

class _AdminBadge extends StatelessWidget {
  const _AdminBadge();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.adminShieldBackground,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bike House 관리자',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 로그인 폼 카드
// ─────────────────────────────────────────────────────────────────────────────

class _LoginFormCard extends ConsumerWidget {
  const _LoginFormCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(adminLoginProvider.notifier);
    final state = ref.watch(adminLoginProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthFieldLabel(label: '이메일'),
          const SizedBox(height: 8),
          _InputField(
            hintText: '관리자 이메일을 입력하세요',
            prefixIcon: Icons.email_outlined,
            obscureText: false,
            onChanged: controller.onIdChanged,
          ),
          const SizedBox(height: 20),
          const AuthFieldLabel(label: '비밀번호'),
          const SizedBox(height: 8),
          _PasswordField(
            hintText: '비밀번호를 입력하세요',
            isVisible: state.isPasswordVisible,
            onChanged: controller.onPasswordChanged,
            onToggleVisibility: controller.togglePasswordVisibility,
          ),
          const SizedBox(height: 28),
          _LoginButton(
            onPressed: state.isLoading ? null : controller.login,
            isLoading: state.isLoading,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 14),
            AuthErrorBanner(message: state.errorMessage!),
          ],
        ],
      ),
    );
  }
}

InputDecoration _adminLoginInputDecoration({
  required String hintText,
  required Widget prefix,
  Widget? suffix,
}) {
  const radius = 10.0;
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: AppColors.textHint,
      fontSize: 14,
    ),
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.hintText,
    required this.prefixIcon,
    required this.obscureText,
    required this.onChanged,
  });

  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: _adminLoginInputDecoration(
        hintText: hintText,
        prefix: Icon(prefixIcon, color: AppColors.textHint, size: 20),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.hintText,
    required this.isVisible,
    required this.onChanged,
    required this.onToggleVisibility,
  });

  final String hintText;
  final bool isVisible;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      obscureText: !isVisible,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: _adminLoginInputDecoration(
        hintText: hintText,
        prefix: const Icon(
          Icons.lock_outline,
          color: AppColors.textHint,
          size: 20,
        ),
        suffix: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textSecondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 보안 안내 푸터
// ─────────────────────────────────────────────────────────────────────────────

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      '보안 관리자 구역입니다. 비인가 접근은 금지되어 있습니다.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary.withValues(alpha: 0.7),
            fontSize: 12,
          ),
    );
  }
}
