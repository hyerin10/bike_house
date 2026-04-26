import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 관리자 로그인 상태 모델
class AdminLoginState {
  const AdminLoginState({
    this.adminId = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isLoggedIn = false,
    this.errorMessage,
  });

  final String adminId;
  final String password;
  final bool isPasswordVisible;
  final bool isLoggedIn;
  final String? errorMessage;

  AdminLoginState copyWith({
    String? adminId,
    String? password,
    bool? isPasswordVisible,
    bool? isLoggedIn,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminLoginState(
      adminId: adminId ?? this.adminId,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 관리자 로그인 컨트롤러
///
/// 현재는 하드코딩된 자격증명으로 인증합니다.
/// Supabase Auth 연동 시 [login] 메서드 내부만 교체하면 됩니다.
class AdminLoginController extends Notifier<AdminLoginState> {
  static const String _validId = 'admin';
  static const String _validPassword = 'bikehouse2024';

  @override
  AdminLoginState build() => const AdminLoginState();

  void onIdChanged(String value) {
    state = state.copyWith(adminId: value, clearError: true);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void login() {
    if (state.adminId.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: '아이디와 비밀번호를 입력해 주세요.');
      return;
    }

    if (state.adminId == _validId && state.password == _validPassword) {
      state = state.copyWith(isLoggedIn: true, clearError: true);
    } else {
      state = state.copyWith(errorMessage: '아이디 또는 비밀번호가 올바르지 않습니다.');
    }
  }

  void logout() {
    state = const AdminLoginState();
  }
}

/// 관리자 로그인 프로바이더
final adminLoginProvider =
    NotifierProvider<AdminLoginController, AdminLoginState>(
  AdminLoginController.new,
);
