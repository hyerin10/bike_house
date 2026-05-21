import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/providers/auth_provider.dart';

/// 로그인 폼 UI 상태 모델
class AdminLoginState {
  const AdminLoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? errorMessage;

  AdminLoginState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminLoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 로그인 폼 컨트롤러.
///
/// UI 상태(입력값, 비밀번호 가시성, 에러 메시지)를 관리하고,
/// 실제 인증은 [AuthNotifier]에 위임합니다.
class AdminLoginController extends Notifier<AdminLoginState> {
  @override
  AdminLoginState build() => const AdminLoginState();

  void onIdChanged(String value) {
    state = state.copyWith(email: value, clearError: true);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<void> login() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: '이메일과 비밀번호를 입력해 주세요.');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref.read(authProvider.notifier).signIn(
            email: state.email,
            password: state.password,
          );
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _localizeError(e.message),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 중 오류가 발생했습니다. 다시 시도해 주세요.',
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
    return '로그인에 실패했습니다: $message';
  }
}

final adminLoginProvider =
    NotifierProvider<AdminLoginController, AdminLoginState>(
  AdminLoginController.new,
);
