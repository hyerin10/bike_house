import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 인증 상태를 관리하는 Notifier.
///
/// [build]는 앱 시작 시 현재 세션의 유저를 반환합니다 (자동 로그인 지원).
/// [signIn]과 [signOut]으로 상태를 갱신합니다.
class AuthNotifier extends Notifier<User?> {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  User? build() => _client.auth.currentUser;

  /// 이메일/비밀번호로 Supabase 로그인.
  ///
  /// 실패 시 [AuthException]을 던집니다.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    state = response.user;
  }

  /// 이름·전화번호를 user_metadata에 저장합니다.
  ///
  /// [phone]은 하이픈을 제거한 순수 숫자로 저장됩니다.
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final cleanPhone = phone.replaceAll('-', '');
    final response = await _client.auth.updateUser(
      UserAttributes(
        data: {
          'name': name,
          'phone': cleanPhone,
        },
      ),
    );
    state = response.user;
  }

  /// 로그아웃 후 상태를 null로 초기화합니다.
  Future<void> signOut() async {
    await _client.auth.signOut();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
