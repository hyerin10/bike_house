import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/auth/application/sign_up_controller.dart';
import 'package:bike_house/features/auth/presentation/login_screen.dart';
import 'package:bike_house/core/widgets/auth_form_widgets.dart';

/// 회원가입 화면
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signUpProvider);
    final controller = ref.read(signUpProvider.notifier);

    // 회원가입 성공 시 화면 닫기
    ref.listen(signUpProvider, (prev, next) {
      if (!next.isLoading && next.serverError == null && prev?.isLoading == true) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _SignUpHeader(onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _SignUpFormCard(state: state, controller: controller),
                  const SizedBox(height: 24),
                  AuthInlineNavLink(
                    leadingText: '이미 계정이 있으신가요?  ',
                    linkText: '로그인',
                    onLinkTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
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
// 상단 헤더
// ─────────────────────────────────────────────────────────────────────────────

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(4, top + 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '회원가입',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 폼 카드
// ─────────────────────────────────────────────────────────────────────────────

class _SignUpFormCard extends StatelessWidget {
  const _SignUpFormCard({
    required this.state,
    required this.controller,
  });

  final SignUpFormState state;
  final SignUpController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 안내 문구 ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '가입하시면 오토바이 부속품 주문과 배송 조회를 한곳에서 편리하게 이용하실 수 있어요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    height: 1.5,
                  ),
            ),
          ),
          const SizedBox(height: 22),

          // ── 이름 ─────────────────────────────────────────────────────────────
          const AuthFieldLabel(label: '이름'),
          const SizedBox(height: 8),
          _InputField(
            hintText: '이름을 입력하세요',
            prefixIcon: Icons.person_outline_rounded,
            onChanged: controller.onNameChanged,
            errorText: state.nameError,
          ),
          const SizedBox(height: 18),

          // ── 이메일 ───────────────────────────────────────────────────────────
          const AuthFieldLabel(label: '이메일 주소'),
          const SizedBox(height: 8),
          _InputField(
            hintText: '이메일을 입력하세요',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: controller.onEmailChanged,
            errorText: state.emailError,
          ),
          const SizedBox(height: 18),

          // ── 전화번호 ─────────────────────────────────────────────────────────
          const AuthFieldLabel(label: '전화번호'),
          const SizedBox(height: 8),
          _InputField(
            hintText: '010-1234-5678',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onChanged: controller.onPhoneChanged,
            errorText: state.phoneError,
          ),
          const SizedBox(height: 18),

          // ── 주소 ─────────────────────────────────────────────────────────────
          const AuthFieldLabel(label: '주소'),
          const SizedBox(height: 8),
          _InputField(
            hintText: '배송받을 주소를 입력하세요',
            prefixIcon: Icons.location_on_outlined,
            onChanged: controller.onAddressChanged,
            errorText: state.addressError,
          ),
          const SizedBox(height: 18),

          // ── 비밀번호 ─────────────────────────────────────────────────────────
          const AuthFieldLabel(label: '비밀번호'),
          const SizedBox(height: 8),
          _PasswordField(
            hintText: '비밀번호를 입력하세요',
            isVisible: state.isPasswordVisible,
            onChanged: controller.onPasswordChanged,
            onToggle: controller.togglePasswordVisibility,
            errorText: state.passwordError,
          ),
          const SizedBox(height: 18),

          // ── 비밀번호 확인 ─────────────────────────────────────────────────────
          const AuthFieldLabel(label: '비밀번호 확인'),
          const SizedBox(height: 8),
          _PasswordField(
            hintText: '비밀번호를 한 번 더 입력하세요',
            isVisible: state.isConfirmVisible,
            onChanged: controller.onConfirmChanged,
            onToggle: controller.toggleConfirmVisibility,
            errorText: state.confirmError,
          ),
          const SizedBox(height: 26),

          // ── 서버 에러 메시지 ──────────────────────────────────────────────────
          if (state.serverError != null) ...[
            AuthErrorBanner(message: state.serverError!),
            const SizedBox(height: 16),
          ],

          // ── 회원가입 버튼 ─────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isFormValid && !state.isLoading
                  ? controller.signUp
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '회원가입',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: state.isFormValid
                                    ? Colors.white
                                    : AppColors.primary.withValues(alpha: 0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 입력 필드
// ─────────────────────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
    this.keyboardType,
    this.errorText,
  });

  final String hintText;
  final IconData prefixIcon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: authTextFieldDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            hasError: hasError,
          ),
        ),
        if (hasError) AuthFieldErrorText(message: errorText!),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.hintText,
    required this.isVisible,
    required this.onChanged,
    required this.onToggle,
    this.errorText,
  });

  final String hintText;
  final bool isVisible;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onChanged,
          obscureText: !isVisible,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: authTextFieldDecoration(
            hintText: hintText,
            prefixIcon: Icons.lock_outline_rounded,
            hasError: hasError,
            suffix: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
          ),
        ),
        if (hasError) AuthFieldErrorText(message: errorText!),
      ],
    );
  }
}
