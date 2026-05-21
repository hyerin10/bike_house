import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/chat/data/chat_repository.dart';
import '../../../features/chat/domain/chat_models.dart';
import '../../../providers/auth_provider.dart';
import 'admin_chat_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_products_tab.dart';

/// 관리자 대시보드 탭 인덱스
enum _AdminTab { chat, orders, products }

/// 관리자 대시보드 내 현재 탭 상태
final _adminTabProvider = StateProvider.autoDispose<_AdminTab>(
  (ref) => _AdminTab.products,
);

// ─────────────────────────────────────────────────────────────────────────────
// 관리자 대시보드 메인 화면
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(_adminTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardHeader(
          onLogout: () => ref.read(authProvider.notifier).signOut(),
        ),
        _TabBar(
          currentTab: currentTab,
          onTabChanged: (tab) {
            ref.read(_adminTabProvider.notifier).state = tab;
          },
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: switch (currentTab) {
              _AdminTab.products => const AdminProductsTab(
                  key: ValueKey('products'),
                ),
              _AdminTab.orders => const AdminOrdersTab(
                  key: ValueKey('orders'),
                ),
              _AdminTab.chat => const AdminChatTab(
                  key: ValueKey('chat'),
                ),
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 대시보드 헤더
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '관리자 대시보드',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '상품을 등록하고 관리하세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_outlined, size: 16),
            label: const Text('로그아웃'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: const TextStyle(fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 탭 버튼 행
// ─────────────────────────────────────────────────────────────────────────────

class _TabBar extends ConsumerWidget {
  const _TabBar({required this.currentTab, required this.onTabChanged});

  final _AdminTab currentTab;
  final ValueChanged<_AdminTab> onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(adminChatRoomsProvider).valueOrNull ?? [];
    final waitingCount = rooms.where((r) => r.status.isWaiting).length;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TabButton(
              label: '상담 관리',
              icon: Icons.chat_bubble_outline,
              isSelected: currentTab == _AdminTab.chat,
              badgeCount: waitingCount > 0 ? waitingCount : null,
              onTap: () => onTabChanged(_AdminTab.chat),
            ),
            const SizedBox(width: 8),
            _TabButton(
              label: '주문 내역',
              icon: Icons.receipt_long_outlined,
              isSelected: currentTab == _AdminTab.orders,
              onTap: () => onTabChanged(_AdminTab.orders),
            ),
            const SizedBox(width: 8),
            _TabButton(
              label: '상품 관리',
              icon: Icons.inventory_2_outlined,
              isSelected: currentTab == _AdminTab.products,
              onTap: () => onTabChanged(_AdminTab.products),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1A2A3A)
                : const Color(0xFFF0F1F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (badgeCount != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEF4444).withValues(alpha: 0.9)
                        : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
