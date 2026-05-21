import 'package:bike_house/features/chat/domain/chat_models.dart';
import 'package:bike_house/features/support/data/inquiry_local_cache.dart';

/// 1:1 상담 목록용: 활성 방 앞, 종료된 방 뒤 (종료는 오래된 순 = 맨 밑).
List<ChatRoom> mergeCustomerInquiryRooms(
  List<ChatRoom> liveRooms,
  List<InquiryCacheEntry> cachedEntries,
) {
  final active = liveRooms
      .where((r) => !r.status.isCompleted)
      .toList()
    ..sort(
      (a, b) => (b.lastMessageAt ?? b.createdAt)
          .compareTo(a.lastMessageAt ?? a.createdAt),
    );

  final liveCompleted = liveRooms.where((r) => r.status.isCompleted).toList();
  final liveIds = {for (final r in liveCompleted) r.id};

  // 캐시에만 남은 항목 (Supabase에서 더 이상 조회 안 될 때 폴백)
  final cachedOnly = cachedEntries
      .where((e) => !liveIds.contains(e.id))
      .map((e) => e.toChatRoom())
      .toList();

  final allCompleted = [...liveCompleted, ...cachedOnly]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return [...active, ...allCompleted];
}

/// [mergeCustomerInquiryRooms] 결과에 대한 집계.
({int waitingCount, int completedCount}) countInquiryRoomStatuses(
  List<ChatRoom> rooms,
) {
  final waitingCount =
      rooms.where((r) => r.status.isWaiting || r.status.isActive).length;
  final completedCount = rooms.where((r) => r.status.isCompleted).length;
  return (waitingCount: waitingCount, completedCount: completedCount);
}

/// 상담 목록 화면에서 사용하는 파생 UI 상태.
class CustomerInquiryListViewState {
  const CustomerInquiryListViewState({
    required this.isInitialLoading,
    required this.mergedRooms,
    required this.waitingCount,
    required this.completedCount,
  });

  /// 라이브 스트림 첫 로딩이고 아직 방이 없을 때만 true.
  final bool isInitialLoading;
  final List<ChatRoom> mergedRooms;
  final int waitingCount;
  final int completedCount;
}
