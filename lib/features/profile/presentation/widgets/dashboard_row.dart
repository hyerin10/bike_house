import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/orders/application/local_orders_notifier.dart';
import 'package:bike_house/features/wishlist/application/wishlist_notifier.dart';
import 'package:bike_house/features/profile/presentation/widgets/stat_card.dart';

class DashboardRow extends ConsumerWidget {
  const DashboardRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderCount = ref.watch(localOrdersProvider).valueOrNull?.length ?? 0;
    final wishlistCount = ref.watch(wishlistCountProvider);
    final chatUnreadCount = ref.watch(unreadAdminCountProvider);

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primary,
            count: '$orderCount',
            label: '주문내역',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.favorite_outline,
            iconColor: AppColors.wishlistRed,
            count: '$wishlistCount',
            label: '위시리스트',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.headset_mic_outlined,
            iconColor: AppColors.textSecondary,
            count: chatUnreadCount > 0 ? '1' : '0',
            label: '문의/상담',
          ),
        ),
      ],
    );
  }
}
