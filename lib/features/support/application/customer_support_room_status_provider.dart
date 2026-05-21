import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/chat/data/chat_repository.dart';

/// 고객 채팅 화면에서 방 상담 상태를 스트림으로 구독할 때 사용합니다.
final customerSupportRoomStatusProvider =
    StreamProvider.family.autoDispose<String, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).streamRoomStatus(roomId);
});
