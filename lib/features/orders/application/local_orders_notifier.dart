import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/features/orders/domain/order_model.dart';
import 'package:bike_house/providers/auth_provider.dart';

/// 유저별로 분리된 로컬 캐시 키 (계정 간 데이터 혼용 방지)
String _storageKey(String userId) => 'local_orders_v1_$userId';

class LocalOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<OrderModel>> build() async {
    // authProvider를 watch → 유저가 바뀌면 build()가 자동으로 재실행됨
    final user = ref.watch(authProvider);

    if (user == null) {
      // 로그아웃 시 즉시 빈 목록 반환 (이전 유저 데이터 노출 차단)
      return [];
    }

    _subscribeRealtime();
    final localOrders = await _loadOrders(user.id);
    final synced = await _syncStatuses(localOrders);
    return synced;
  }

  Future<void> refresh() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadOrders(userId));
  }

  Future<void> addOrder(OrderModel order) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final current = state.valueOrNull ?? await _loadOrders(userId);
    final next = [order, ...current];
    await _persistOrders(userId, next);
    state = AsyncValue.data(next);
    await _syncFromServerAndUpdateState();
  }

  void _subscribeRealtime() {
    final channel = _client
        .channel('public:my-orders:realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          callback: (_) => _syncFromServerAndUpdateState(),
        )
        .subscribe();

    ref.onDispose(() => _client.removeChannel(channel));
  }

  Future<void> _syncFromServerAndUpdateState() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final current = state.valueOrNull ?? await _loadOrders(userId);
    if (current.isEmpty) return;

    final synced = await _syncStatuses(current);
    state = AsyncValue.data(synced);
  }

  Future<List<OrderModel>> _syncStatuses(List<OrderModel> localOrders) async {
    if (localOrders.isEmpty) return localOrders;

    final ids = localOrders.map((e) => e.id).toSet().toList()..sort();

    final response = await _client
        .from('orders')
        .select('id, status, created_at')
        .inFilter('id', ids);

    final rows = (response as List).cast<Map<String, dynamic>>();
    final byId = <int, Map<String, dynamic>>{
      for (final row in rows) (row['id'] as int): row,
    };

    final userId = _client.auth.currentUser?.id;
    var hasChanges = false;
    final merged = localOrders.map((order) {
      final remote = byId[order.id];
      if (remote == null) return order;

      final remoteStatus = remote['status'] as String? ?? order.status;
      final remoteCreatedAt =
          DateTime.tryParse(remote['created_at'] as String? ?? '');
      final next = order.copyWith(
        status: remoteStatus,
        createdAt: remoteCreatedAt ?? order.createdAt,
      );
      if (next != order) {
        hasChanges = true;
      }
      return next;
    }).toList();

    if (hasChanges && userId != null) {
      await _persistOrders(userId, merged);
    }
    return merged;
  }

  Future<List<OrderModel>> _loadOrders(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(userId));
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _persistOrders(String userId, List<OrderModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(orders.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey(userId), encoded);
  }
}

final localOrdersProvider =
    AsyncNotifierProvider<LocalOrdersNotifier, List<OrderModel>>(
  LocalOrdersNotifier.new,
);
