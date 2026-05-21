import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/constants.dart';
import 'package:bike_house/features/auth/application/login_controller.dart';
import 'package:bike_house/features/auth/presentation/sign_up_screen.dart';
import 'package:bike_house/core/widgets/auth_form_widgets.dart';

/// 일반 회원 로그인 화면
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final controller = ref.read(loginProvider.notifier);

    ref.listen(loginProvider, (_, next) {
      if (next.loginSucceeded) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AuthScreenHeader(
            title: '로그인',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // 로고 영역
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_bike_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kAppName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오토바이 부속품 주문과 배송을 조회해 보세요',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  _LoginFormCard(state: state, controller: controller),
                  const SizedBox(height: 24),
                  AuthInlineNavLink(
                    leadingText: '아직 계정이 없으신가요?  ',
                    linkText: '회원가입',
                    onLinkTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
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

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({required this.state, required this.controller});

  final LoginFormState state;
  final LoginController controller;

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
          const AuthFieldLabel(label: '이메일 주소'),
          const SizedBox(height: 8),
          AuthTextField(
            hintText: '이메일을 입력하세요',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: controller.onEmailChanged,
          ),
          const SizedBox(height: 18),
          const AuthFieldLabel(label: '비밀번호'),
          const SizedBox(height: 8),
          AuthPasswordField(
            hintText: '비밀번호를 입력하세요',
            isVisible: state.isPasswordVisible,
            onChanged: controller.onPasswordChanged,
            onToggle: controller.togglePasswordVisibility,
          ),
          const SizedBox(height: 26),

          // 서버 에러
          if (state.serverError != null) ...[
            AuthErrorBanner(message: state.serverError!),
            const SizedBox(height: 16),
          ],

          // 로그인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.canSubmit ? controller.login : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
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
                      '로그인',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
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
