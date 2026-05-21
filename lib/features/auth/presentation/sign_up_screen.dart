import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/widgets/auth_form_widgets.dart';
import 'package:bike_house/features/auth/application/sign_up_controller.dart';
import 'package:bike_house/features/auth/presentation/login_screen.dart';

/// 회원가입 화면
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signUpProvider);
    final controller = ref.read(signUpProvider.notifier);

    ref.listen(signUpProvider, (_, next) {
      if (next.signUpSucceeded) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AuthScreenHeader(
            title: '회원가입',
            onBack: () => Navigator.of(context).pop(),
          ),
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
// 폼 카드
// ─────────────────────────────────────────────────────────────────────────────

class _SignUpFormCard extends StatelessWidget {
  const _SignUpFormCard({
    required this.state,
    required this.controller,
  });

  final SignUpFormState state;
  final SignUpController controller;

  static final _plainFieldSpecs = <({
    String label,
    String hint,
    IconData icon,
    TextInputType? keyboardType,
  })>[
    (
      label: '이름',
      hint: '이름을 입력하세요',
      icon: Icons.person_outline_rounded,
      keyboardType: null,
    ),
    (
      label: '이메일 주소',
      hint: '이메일을 입력하세요',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
    ),
    (
      label: '전화번호',
      hint: '010-1234-5678',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
    ),
    (
      label: '주소',
      hint: '배송받을 주소를 입력하세요',
      icon: Icons.location_on_outlined,
      keyboardType: null,
    ),
  ];

  String? _errorForIndex(int i) {
    return switch (i) {
      0 => state.nameError,
      1 => state.emailError,
      2 => state.phoneError,
      3 => state.addressError,
      _ => null,
    };
  }

  ValueChanged<String> _onChangedForIndex(int i) {
    return switch (i) {
      0 => controller.onNameChanged,
      1 => controller.onEmailChanged,
      2 => controller.onPhoneChanged,
      3 => controller.onAddressChanged,
      _ => (_) {},
    };
  }

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
          for (var i = 0; i < _plainFieldSpecs.length; i++) ...[
            AuthFieldLabel(label: _plainFieldSpecs[i].label),
            const SizedBox(height: 8),
            AuthTextField(
              hintText: _plainFieldSpecs[i].hint,
              prefixIcon: _plainFieldSpecs[i].icon,
              keyboardType: _plainFieldSpecs[i].keyboardType,
              onChanged: _onChangedForIndex(i),
              errorText: _errorForIndex(i),
            ),
            const SizedBox(height: 18),
          ],
          const AuthFieldLabel(label: '비밀번호'),
          const SizedBox(height: 8),
          AuthPasswordField(
            hintText: '비밀번호를 입력하세요',
            isVisible: state.isPasswordVisible,
            onChanged: controller.onPasswordChanged,
            onToggle: controller.togglePasswordVisibility,
            errorText: state.passwordError,
          ),
          const SizedBox(height: 18),
          const AuthFieldLabel(label: '비밀번호 확인'),
          const SizedBox(height: 8),
          AuthPasswordField(
            hintText: '비밀번호를 한 번 더 입력하세요',
            isVisible: state.isConfirmVisible,
            onChanged: controller.onConfirmChanged,
            onToggle: controller.toggleConfirmVisibility,
            errorText: state.confirmError,
          ),
          const SizedBox(height: 26),
          if (state.serverError != null) ...[
            AuthErrorBanner(message: state.serverError!),
            const SizedBox(height: 16),
          ],
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
