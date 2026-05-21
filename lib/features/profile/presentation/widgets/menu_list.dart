import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/orders/presentation/my_orders_screen.dart';
import 'package:bike_house/features/support/presentation/customer_inquiry_list_screen.dart';
import 'package:bike_house/features/wishlist/presentation/wishlist_screen.dart';
import 'package:bike_house/features/profile/presentation/widgets/menu_tile.dart';

class MenuList extends ConsumerWidget {
  const MenuList({super.key});

  void _handleChatTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CustomerInquiryListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUnreadCount = ref.watch(unreadAdminCountProvider);

    void showComingSoon() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('준비 중인 기능입니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          MenuTile(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primary,
            label: '주문내역',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            ),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.divider),
          MenuTile(
            icon: Icons.favorite_outline,
            iconColor: AppColors.wishlistRed,
            label: '위시리스트',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            ),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.divider),
          MenuTile(
            icon: Icons.headset_mic_outlined,
            iconColor: AppColors.textSecondary,
            label: '1:1 상담',
            count: chatUnreadCount > 0 ? chatUnreadCount : null,
            isUnreadBadge: true,
            onTap: () => _handleChatTap(context),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.divider),
          MenuTile(
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.textSecondary,
            label: '고객센터',
            onTap: showComingSoon,
          ),
        ],
      ),
    );
  }
}
