import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 관리자 로그인 상태 모델
class AdminLoginState {
  const AdminLoginState({
    this.adminId = '',
    this.password = '',
    this.isPasswordVisible = false,
  });

  final String adminId;
  final String password;
  final bool isPasswordVisible;

  AdminLoginState copyWith({
    String? adminId,
    String? password,
    bool? isPasswordVisible,
  }) {
    return AdminLoginState(
      adminId: adminId ?? this.adminId,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}

/// 관리자 로그인 컨트롤러
class AdminLoginController extends Notifier<AdminLoginState> {
  @override
  AdminLoginState build() => const AdminLoginState();

  void onIdChanged(String value) {
    state = state.copyWith(adminId: value);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void login() {
    debugPrint('관리자 ID: ${state.adminId}');
    debugPrint('비밀번호: ${state.password}');
  }
}

/// 관리자 로그인 프로바이더
final adminLoginProvider =
    NotifierProvider<AdminLoginController, AdminLoginState>(
  AdminLoginController.new,
);
