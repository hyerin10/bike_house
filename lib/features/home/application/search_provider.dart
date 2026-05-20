import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 화면 검색어 상태를 전역으로 관리하는 프로바이더.
///
/// - 검색바 위젯은 ref.read()로만 상태를 갱신해 불필요한 리빌드를 방지한다.
/// - 검색 결과가 필요한 위젯은 ref.watch()로 이 프로바이더를 구독한다.
final searchQueryProvider = StateProvider<String>((ref) => '');
