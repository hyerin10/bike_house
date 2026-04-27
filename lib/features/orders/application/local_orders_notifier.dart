import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/order_model.dart';

const _localOrdersStorageKey = 'local_orders_v1';

class LocalOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<OrderModel>> build() async {
    _subscribeRealtime();
    final localOrders = await _loadOrders();
    final synced = await _syncStatuses(localOrders);
    return synced;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadOrders);
  }

  Future<void> addOrder(OrderModel order) async {
    final current = state.valueOrNull ?? await _loadOrders();
    final next = [order, ...current];
    await _persistOrders(next);
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
    final current = state.valueOrNull ?? await _loadOrders();
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

    if (hasChanges) {
      await _persistOrders(merged);
    }
    return merged;
  }

  Future<List<OrderModel>> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localOrdersStorageKey);
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

  Future<void> _persistOrders(List<OrderModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(orders.map((e) => e.toJson()).toList());
    await prefs.setString(_localOrdersStorageKey, encoded);
  }
}

final localOrdersProvider =
    AsyncNotifierProvider<LocalOrdersNotifier, List<OrderModel>>(
  LocalOrdersNotifier.new,
);
