import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/constants.dart';
import 'package:bike_house/features/auth/presentation/root_screen.dart';
import 'package:bike_house/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  _setupErrorHandlers();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL/SUPABASE_ANON_KEY is missing. '
      'Run with --dart-define-from-file=.env.development or .env.production',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  _setupCrashlyticsUserSync();

  runZonedGuarded(
    () => runApp(const ProviderScope(child: BikeHouseApp())),
    (error, stack) {
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
    },
  );
}

/// FlutterError(UI/프레임워크) + PlatformDispatcher(비동기/플랫폼) 에러를
/// 한 곳에서 가로채는 전역 파이프라인.
///
/// - kDebugMode: 로컬 콘솔에 출력 (Crashlytics 전송 없음)
/// - 릴리즈 모드: Crashlytics로만 전송
void _setupErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack));
    } else {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };
}

/// Supabase 세션 상태(로그인/로그아웃)를 감지하여
/// Crashlytics의 userIdentifier를 자동으로 동기화한다.
///
/// - 앱 시작 시 이미 세션이 있으면 즉시 반영
/// - 이후 로그인 → UUID 설정, 로그아웃 → 식별자 초기화
void _setupCrashlyticsUserSync() {
  final auth = Supabase.instance.client.auth;

  final initialUserId = auth.currentUser?.id;
  if (initialUserId != null) {
    FirebaseCrashlytics.instance.setUserIdentifier(initialUserId);
  }

  auth.onAuthStateChange.listen((data) {
    final userId = data.session?.user.id;
    FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  });
}

class BikeHouseApp extends StatelessWidget {
  const BikeHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RootScreen(),
    );
  }
}
