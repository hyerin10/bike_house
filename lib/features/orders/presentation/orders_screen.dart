import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/orders/application/orders_notifier.dart';
import 'package:bike_house/features/orders/domain/order_model.dart';
import 'package:bike_house/features/orders/presentation/widgets/order_admin_ui_helpers.dart';
import 'package:bike_house/features/orders/presentation/widgets/order_card.dart';
import 'package:bike_house/features/orders/presentation/widgets/orders_empty_view.dart';
import 'package:bike_house/features/orders/presentation/widgets/orders_error_view.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrders = ref.watch(ordersProvider);
    final cancellingId = ref.watch(cancellingOrderIdProvider);
    final confirmingId = ref.watch(confirmingOrderIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('주문 관리'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: asyncOrders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => OrdersErrorView(
          message: orderParseErrorMessage(error.toString()),
          onRetry: () => ref.read(ordersProvider.notifier).refresh(),
        ),
        data: (orders) {
          if (orders.isEmpty) return const OrdersEmptyView();

          return RefreshIndicator(
            onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  isCancelling: cancellingId == order.id,
                  isConfirming: confirmingId == order.id,
                  onCancel: () => _handleCancel(context, ref, order),
                  onConfirmPayment: () =>
                      _handleConfirmPayment(context, ref, order),
                );
              },
            ),
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
