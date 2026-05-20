import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../orders/application/local_orders_notifier.dart';
import '../../orders/presentation/my_orders_screen.dart';

/// 마이페이지 화면 — 사용자 프로필, 주문·위시리스트 현황, 메뉴 모음
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(localOrdersProvider);
    final orderCount = ordersAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 페이지 타이틀 ──────────────────────────────────────────
            Text('마이페이지', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 2),
            Text('내 차고 관리', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            // ─── 프로필 카드 ────────────────────────────────────────────
            const _ProfileCard(),
            const SizedBox(height: 20),

            // ─── 대시보드 통계 행 ────────────────────────────────────────
            _DashboardRow(orderCount: orderCount),
            const SizedBox(height: 20),

            // ─── 메뉴 리스트 ────────────────────────────────────────────
            _MenuList(orderCount: orderCount),
            const SizedBox(height: 20),

            // ─── 로그아웃 버튼 ───────────────────────────────────────────
            const _LogoutButton(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 프로필 카드
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 원형 아바타
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFD6E4FF),
              shape: BoxShape.circle,
            ),
            child: Text(
              '홍',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 16),

          // 이름 · 이메일
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('홍길동', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  'hong@example.com',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // 설정 아이콘
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 대시보드 통계 (3열)
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardRow extends StatelessWidget {
  const _DashboardRow({required this.orderCount});

  final int orderCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primary,
            count: '$orderCount',
            label: '주문내역',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_outline,
            iconColor: const Color(0xFFFF4C6A),
            count: '2',
            label: '위시리스트',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.headset_mic_outlined,
            iconColor: AppColors.textSecondary,
            count: '0',
            label: '문의/상담',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 8),
          Text(
            count,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 메뉴 리스트
// ─────────────────────────────────────────────────────────────────────────────

class _MenuList extends StatelessWidget {
  const _MenuList({required this.orderCount});

  final int orderCount;

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.primary,
            label: '주문내역',
            count: orderCount,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            ),
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 0,
            color: AppColors.divider,
          ),
          _MenuTile(
            icon: Icons.favorite_outline,
            iconColor: const Color(0xFFFF4C6A),
            label: '위시리스트',
            count: 2,
            onTap: showComingSoon,
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 0,
            color: AppColors.divider,
          ),
          _MenuTile(
            icon: Icons.headset_mic_outlined,
            iconColor: AppColors.textSecondary,
            label: '1:1 상담',
            count: 0,
            onTap: showComingSoon,
          ),
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 0,
            color: AppColors.divider,
          ),
          _MenuTile(
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

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.count,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 아이콘 컨테이너
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),

            // 메뉴 라벨
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            // 카운트 배지 (값이 있을 경우만 표시)
            if (count != null) ...[
              Text(
                '$count',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(width: 4),
            ],

            // 화살표
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 로그아웃 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  static const Color _logoutRed = Color(0xFFE5534B);
  static const Color _logoutBg = Color(0xFFFFECEC);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _logoutBg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            // 로그아웃 로직 연결 예정
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: _logoutRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  '로그아웃',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _logoutRed,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
