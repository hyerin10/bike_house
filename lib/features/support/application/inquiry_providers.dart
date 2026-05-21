import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/features/support/data/inquiry_local_cache.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 종료된 상담 로컬 캐시 Notifier
// ─────────────────────────────────────────────────────────────────────────────

class InquiryCacheNotifier
    extends AutoDisposeAsyncNotifier<List<InquiryCacheEntry>> {
  final _cache = InquiryLocalCache();

  String get _userId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  Future<List<InquiryCacheEntry>> build() async {
    if (_userId.isEmpty) return [];
    return _cache.load(_userId);
  }

  /// 종료된 채팅방 정보를 로컬 캐시에 저장/갱신
  Future<void> upsert(InquiryCacheEntry entry) async {
    if (_userId.isEmpty) return;
    await _cache.upsert(_userId, entry);
    final current = state.valueOrNull ?? [];
    final updated = [
      ...current.where((e) => e.id != entry.id),
      entry,
    ];
    state = AsyncData(updated);
  }
}

final inquiryCacheNotifierProvider = AsyncNotifierProvider.autoDispose<
    InquiryCacheNotifier, List<InquiryCacheEntry>>(
  InquiryCacheNotifier.new,
);
