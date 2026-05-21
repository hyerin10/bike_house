import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/utils/constants.dart';

/// 하단 네비게이션의 현재 선택된 탭 인덱스
final selectedNavIndexProvider = StateProvider<int>((ref) => NavIndex.home);
