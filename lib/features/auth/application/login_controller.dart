import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 로그인 폼 상태 모델
// ─────────────────────────────────────────────────────────────────────────────

class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.serverError,
    this.loginSucceeded = false,
  });

  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? serverError;
  /// [login]이 서버까지 성공한 뒤 true (화면에서 pop 트리거용)
  final bool loginSucceeded;

  bool get canSubmit => email.isNotEmpty && password.isNotEmpty && !isLoading;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    String? serverError,
    bool? loginSucceeded,
    bool clearError = false,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      serverError: clearError ? null : (serverError ?? this.serverError),
      loginSucceeded: loginSucceeded ?? this.loginSucceeded,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 로그인 컨트롤러
// ─────────────────────────────────────────────────────────────────────────────

class LoginController extends AutoDisposeNotifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void onEmailChanged(String value) =>
      state = state.copyWith(email: value, clearError: true);

  void onPasswordChanged(String value) =>
      state = state.copyWith(password: value, clearError: true);

  void togglePasswordVisibility() =>
      state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);

  Future<void> login() async {
    if (!state.canSubmit) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      loginSucceeded: false,
    );
    try {
      await ref.read(authProvider.notifier).signIn(
            email: state.email.trim(),
            password: state.password,
          );
      state = state.copyWith(isLoading: false, loginSucceeded: true);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        serverError: _localizeError(e.message),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        serverError: '로그인 중 오류가 발생했습니다. 다시 시도해 주세요.',
      );
    }
  }

  String _localizeError(String message) {
    if (message.contains('Invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
    if (message.contains('Email not confirmed')) {
      return '이메일 인증이 필요합니다. 받은 메일함을 확인해 주세요.';
    }
    if (message.contains('too many requests')) {
      return '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.';
    }
    return '로그인에 실패했습니다: $message';
  }
}

final loginProvider =
    AutoDisposeNotifierProvider<LoginController, LoginFormState>(
  LoginController.new,
);
