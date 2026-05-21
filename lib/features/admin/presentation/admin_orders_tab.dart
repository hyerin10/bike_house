import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/widgets/app_product_search_field.dart';
import 'package:bike_house/features/admin/application/admin_order_search_providers.dart';
import 'package:bike_house/features/orders/application/orders_notifier.dart';
import 'package:bike_house/features/orders/domain/order_model.dart';
import 'package:bike_house/features/orders/presentation/widgets/order_admin_ui_helpers.dart';
import 'package:bike_house/features/orders/presentation/widgets/order_card.dart';
import 'package:bike_house/features/orders/presentation/widgets/orders_empty_view.dart';
import 'package:bike_house/features/orders/presentation/widgets/orders_error_view.dart';

/// 관리자 대시보드의 주문 내역 탭 (실데이터 [ordersProvider])
class AdminOrdersTab extends ConsumerWidget {
  const AdminOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFiltered = ref.watch(adminFilteredOrdersProvider);
    final cancellingId = ref.watch(cancellingOrderIdProvider);
    final confirmingId = ref.watch(confirmingOrderIdProvider);

    return Column(
      children: [
        AppProductSearchBar(
          hintText: '주문번호, 고객명, 연락처로 검색...',
          wrapWithBackground: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onChanged: (q) =>
              ref.read(adminOrderSearchQueryProvider.notifier).state = q,
        ),
        Expanded(
          child: asyncFiltered.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => OrdersErrorView(
              message: orderParseErrorMessage(error.toString()),
              onRetry: () => ref.read(ordersProvider.notifier).refresh(),
            ),
            data: (orders) => _AdminOrdersList(
              orders: orders,
              cancellingId: cancellingId,
              confirmingId: confirmingId,
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminOrdersList extends ConsumerWidget {
  const _AdminOrdersList({
    required this.orders,
    required this.cancellingId,
    required this.confirmingId,
  });

  final List<OrderModel> orders;
  final int? cancellingId;
  final int? confirmingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      final query = ref.watch(adminOrderSearchQueryProvider).trim();
      if (query.isEmpty) {
        return const OrdersEmptyView();
      }
      return Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            isCancelling: cancellingId == order.id,
            isConfirming: confirmingId == order.id,
            onCancel: () => _handleCancel(context, ref, order),
            onConfirmPayment: () => _handleConfirmPayment(context, ref, order),
          );
        },
      ),
    );
  }

  Future<void> _handleCancel(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    final confirmed = await showOrderAdminConfirmDialog(
      context,
      title: '주문 취소',
      content:
          '${order.orderNumber} 주문을\n정말 취소하시겠습니까?\n\n취소 시 재고가 자동으로 복원됩니다.',
      confirmLabel: '주문 취소',
      confirmColor: AppColors.accent,
    );

    if (confirmed != true || !context.mounted) return;

    await runOrderAdminMutation(
      context,
      ref,
      loadingIdProvider: cancellingOrderIdProvider,
      orderId: order.id,
      action: () => ref.read(ordersProvider.notifier).cancelOrder(order.id),
      successMessage: '주문이 취소되었습니다.',
    );
  }

  Future<void> _handleConfirmPayment(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    final confirmed = await showOrderAdminConfirmDialog(
      context,
      title: '입금 확인',
      content: '${order.orderNumber} 주문의\n입금 확인 처리를 하시겠습니까?',
      confirmLabel: '확인',
      confirmColor: AppColors.compatible,
    );

    if (confirmed != true || !context.mounted) return;

    await runOrderAdminMutation(
      context,
      ref,
      loadingIdProvider: confirmingOrderIdProvider,
      orderId: order.id,
      action: () =>
          ref.read(ordersProvider.notifier).confirmPayment(order.id),
      successMessage: '입금이 확인되었습니다.',
    );
  }
}
