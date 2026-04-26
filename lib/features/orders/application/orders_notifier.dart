import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/order_repository.dart';
import '../domain/order_model.dart';

final _repositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(Supabase.instance.client),
);

/// 현재 취소 처리 중인 주문 ID (null이면 없음)
final cancellingOrderIdProvider = StateProvider<int?>((ref) => null);

/// 현재 입금 확인 처리 중인 주문 ID (null이면 없음)
final confirmingOrderIdProvider = StateProvider<int?>((ref) => null);

/// 주문 목록 + Supabase Realtime 자동 갱신
class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  SupabaseClient get _client => Supabase.instance.client;
  OrderRepository get _repo => ref.read(_repositoryProvider);

  @override
  Future<List<OrderModel>> build() async {
    final orders = await _repo.fetchOrders();
    _subscribeRealtime();
    return orders;
  }

  /// orders 테이블 변경(INSERT/UPDATE/DELETE)을 실시간으로 감지합니다.
  void _subscribeRealtime() {
    final channel = _client
        .channel('public:orders:realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (_) => _silentRefresh(),
        )
        .subscribe();

    // Notifier 해제 시 채널도 함께 제거
    ref.onDispose(() => _client.removeChannel(channel));
  }

  /// 로딩 스피너 없이 데이터를 백그라운드에서 갱신합니다.
  /// Realtime 이벤트 및 cancelOrder 완료 후 사용합니다.
  Future<void> _silentRefresh() async {
    final next = await AsyncValue.guard(() => _repo.fetchOrders());
    // 에러가 아닌 경우에만 상태 교체 (기존 목록 유지)
    if (next is AsyncData<List<OrderModel>>) {
      state = next;
    }
  }

  /// 전체 로딩 표시 후 목록을 다시 불러옵니다. (pull-to-refresh 전용)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchOrders());
  }

  /// cancel_order RPC를 호출하고 목록을 즉시 갱신합니다.
  /// 실패 시 예외를 throw하여 호출 측에서 에러 처리합니다.
  Future<void> cancelOrder(int orderId) async {
    await _repo.cancelOrder(orderId);
    // Realtime이 자동 감지하지만, 즉각 반영을 위해 명시적으로 갱신
    await _silentRefresh();
  }

  /// confirm_payment RPC를 호출하고 목록을 즉시 갱신합니다.
  /// 실패 시 예외를 throw하여 호출 측에서 에러 처리합니다.
  Future<void> confirmPayment(int orderId) async {
    await _repo.confirmPayment(orderId);
    await _silentRefresh();
  }
}

final ordersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(
  OrdersNotifier.new,
);
