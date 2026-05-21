import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 회원가입 폼 상태 모델
// ─────────────────────────────────────────────────────────────────────────────

class SignUpFormState {
  const SignUpFormState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.password = '',
    this.confirmPassword = '',
    this.nameTouched = false,
    this.emailTouched = false,
    this.phoneTouched = false,
    this.addressTouched = false,
    this.passwordTouched = false,
    this.confirmTouched = false,
    this.isPasswordVisible = false,
    this.isConfirmVisible = false,
    this.isLoading = false,
    this.serverError,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final String password;
  final String confirmPassword;

  final bool nameTouched;
  final bool emailTouched;
  final bool phoneTouched;
  final bool addressTouched;
  final bool passwordTouched;
  final bool confirmTouched;

  final bool isPasswordVisible;
  final bool isConfirmVisible;
  final bool isLoading;
  final String? serverError;

  // ── 정규식 ──────────────────────────────────────────────────────────────────
  static final _nameRegex  = RegExp(r'^[가-힣a-zA-Z]{2,}$');
  static final _emailRegex = RegExp(r'^[\w._%+\-]+@[\w.\-]+\.[a-zA-Z]{2,}$');
  static final _phoneRegex = RegExp(r'^0\d{1,2}[.\-]?\d{3,4}[.\-]?\d{4}$');
  static final _hasLetter  = RegExp(r'[a-zA-Z]');
  static final _hasDigit   = RegExp(r'\d');
  static final _hasSpecial = RegExp(r"[!@#$%^&*()\-_=+\[\]{};:',./<>?\\|`~]");

  // ── 유효성 검사 getter ────────────────────────────────────────────────────────

  String? get nameError {
    if (!nameTouched) return null;
    final t = name.trim();
    if (t.isEmpty) return '이름을 입력해 주세요.';
    if (!_nameRegex.hasMatch(t)) return '이름은 한글 또는 영문, 2자 이상으로 입력해 주세요.';
    return null;
  }

  String? get emailError {
    if (!emailTouched) return null;
    if (email.isEmpty) return '이메일을 입력해 주세요.';
    if (!_emailRegex.hasMatch(email)) return '올바른 이메일 형식이 아닙니다.';
    return null;
  }

  String? get phoneError {
    if (!phoneTouched) return null;
    final digits = phone.replaceAll(RegExp(r'[\s\-.]'), '');
    if (digits.isEmpty) return '전화번호를 입력해 주세요.';
    if (!_phoneRegex.hasMatch(phone.replaceAll(' ', ''))) {
      return '올바른 전화번호 형식이 아닙니다. (예: 010-1234-5678)';
    }
    return null;
  }

  String? get passwordError {
    if (!passwordTouched) return null;
    if (password.isEmpty) return '비밀번호를 입력해 주세요.';
    if (password.length < 8 ||
        !_hasLetter.hasMatch(password) ||
        !_hasDigit.hasMatch(password) ||
        !_hasSpecial.hasMatch(password)) {
      return '비밀번호는 영문, 숫자, 특수문자를 포함해 8자 이상이어야 합니다.';
    }
    return null;
  }

  String? get confirmError {
    if (!confirmTouched) return null;
    if (confirmPassword.isEmpty) return '비밀번호를 한 번 더 입력해 주세요.';
    if (confirmPassword != password) return '비밀번호가 일치하지 않습니다.';
    return null;
  }

  String? get addressError {
    if (!addressTouched) return null;
    if (address.trim().isEmpty) return '주소를 입력해 주세요.';
    return null;
  }

  bool get isFormValid {
    if (!_nameRegex.hasMatch(name.trim())) return false;
    if (!_emailRegex.hasMatch(email)) return false;
    if (!_phoneRegex.hasMatch(phone.replaceAll(' ', ''))) return false;
    if (address.trim().isEmpty) return false;
    if (password.length < 8 ||
        !_hasLetter.hasMatch(password) ||
        !_hasDigit.hasMatch(password) ||
        !_hasSpecial.hasMatch(password)) return false;
    if (confirmPassword != password) return false;
    return true;
  }

  SignUpFormState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? password,
    String? confirmPassword,
    bool? nameTouched,
    bool? emailTouched,
    bool? phoneTouched,
    bool? addressTouched,
    bool? passwordTouched,
    bool? confirmTouched,
    bool? isPasswordVisible,
    bool? isConfirmVisible,
    bool? isLoading,
    String? serverError,
    bool clearServerError = false,
  }) {
    return SignUpFormState(
      name:            name            ?? this.name,
      email:           email           ?? this.email,
      phone:           phone           ?? this.phone,
      address:         address         ?? this.address,
      password:        password        ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      nameTouched:     nameTouched     ?? this.nameTouched,
      emailTouched:    emailTouched    ?? this.emailTouched,
      phoneTouched:    phoneTouched    ?? this.phoneTouched,
      addressTouched:  addressTouched  ?? this.addressTouched,
      passwordTouched: passwordTouched ?? this.passwordTouched,
      confirmTouched:  confirmTouched  ?? this.confirmTouched,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmVisible:  isConfirmVisible  ?? this.isConfirmVisible,
      isLoading:    isLoading    ?? this.isLoading,
      serverError:  clearServerError ? null : (serverError ?? this.serverError),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 회원가입 컨트롤러
// ─────────────────────────────────────────────────────────────────────────────

class SignUpController extends AutoDisposeNotifier<SignUpFormState> {
  @override
  SignUpFormState build() => const SignUpFormState();

  void onNameChanged(String v)    => state = state.copyWith(name: v,            nameTouched: true,    clearServerError: true);
  void onEmailChanged(String v)   => state = state.copyWith(email: v,           emailTouched: true,   clearServerError: true);
  void onPhoneChanged(String v)   => state = state.copyWith(phone: v,           phoneTouched: true,   clearServerError: true);
  void onAddressChanged(String v) => state = state.copyWith(address: v,         addressTouched: true, clearServerError: true);
  void onPasswordChanged(String v) {
    state = state.copyWith(password: v, passwordTouched: true, clearServerError: true);
  }
  void onConfirmChanged(String v) => state = state.copyWith(confirmPassword: v, confirmTouched: true, clearServerError: true);

  void togglePasswordVisibility() =>
      state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  void toggleConfirmVisibility() =>
      state = state.copyWith(isConfirmVisible: !state.isConfirmVisible);

  Future<void> signUp() async {
    // 미입력 필드도 에러 표시를 위해 모두 touched 처리
    state = state.copyWith(
      nameTouched:     true,
      emailTouched:    true,
      phoneTouched:    true,
      addressTouched:  true,
      passwordTouched: true,
      confirmTouched:  true,
    );

    if (!state.isFormValid) {
      // 어느 필드가 막히는지 배너로 안내
      final firstError = state.nameError ??
          state.emailError ??
          state.phoneError ??
          state.addressError ??
          state.passwordError ??
          state.confirmError ??
          '입력값을 다시 확인해 주세요.';
      state = state.copyWith(serverError: firstError);
      return;
    }

    state = state.copyWith(isLoading: true, clearServerError: true);
    try {
      await ref.read(authProvider.notifier).signUp(
            email:    state.email.trim(),
            password: state.password,
            name:     state.name.trim(),
            phone:    state.phone.replaceAll(RegExp(r'[\s\-.]'), ''),
            address:  state.address.trim(),
          );
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, serverError: _localizeError(e.message));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        serverError: '회원가입 중 오류가 발생했습니다: $e',
      );
    }
  }

  String _localizeError(String message) {
    if (message.contains('already registered') || message.contains('already been registered')) {
      return '이미 사용 중인 이메일입니다.';
    }
    if (message.contains('Password should be')) {
      return '비밀번호는 영문, 숫자, 특수문자를 포함해 8자 이상이어야 합니다.';
    }
    return '회원가입에 실패했습니다: $message';
  }
}

final signUpProvider =
    AutoDisposeNotifierProvider<SignUpController, SignUpFormState>(
  SignUpController.new,
);
