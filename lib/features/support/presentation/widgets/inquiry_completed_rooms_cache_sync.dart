import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/chat/domain/chat_models.dart';
import 'package:bike_house/features/support/application/inquiry_providers.dart';
import 'package:bike_house/features/support/data/inquiry_local_cache.dart';

/// 종료된 방을 로컬 캐시에 반영한다. 레이아웃에는 영향 없음.
class InquiryCompletedRoomsCacheSync extends ConsumerWidget {
  const InquiryCompletedRoomsCacheSync({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(customerAllRoomsProvider, (_, next) {
      next.whenData((rooms) {
        final notifier = ref.read(inquiryCacheNotifierProvider.notifier);
        for (final room in rooms.where((r) => r.status.isCompleted)) {
          notifier.upsert(InquiryCacheEntry.fromChatRoom(room));
        }
      });
    });
    return const SizedBox.shrink();
  }
}
