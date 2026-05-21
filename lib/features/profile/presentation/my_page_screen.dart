import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/sign_up_screen.dart';
import '../../orders/application/local_orders_notifier.dart';
import '../../orders/presentation/my_orders_screen.dart';
import '../../wishlist/application/wishlist_notifier.dart';
import '../../wishlist/presentation/wishlist_screen.dart';
import 'edit_profile_screen.dart';

/// 마이페이지 화면 — 로그인 상태에 따라 분기
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: _GuestMyPageBody(),
      );
    }

    final ordersAsync = ref.watch(localOrdersProvider);
    final orderCount = ordersAsync.valueOrNull?.length ?? 0;
    final wishlistCount = ref.watch(wishlistCountProvider);

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
            Text(
              '오토바이 부속품 주문·배송 조회',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // ─── 프로필 카드 ────────────────────────────────────────────
            const _ProfileCard(),
            const SizedBox(height: 20),

            // ─── 대시보드 통계 행 ────────────────────────────────────────
            _DashboardRow(orderCount: orderCount, wishlistCount: wishlistCount),
            const SizedBox(height: 20),

            // ─── 메뉴 리스트 ────────────────────────────────────────────
            _MenuList(orderCount: orderCount, wishlistCount: wishlistCount),
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
// 비로그인 상태 전체 바디
// ─────────────────────────────────────────────────────────────────────────────

class _GuestMyPageBody extends StatelessWidget {
  const _GuestMyPageBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 페이지 타이틀 ──────────────────────────────────────────
          Text('마이페이지', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            '오토바이 부속품 주문과 배송을 조회해 보세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // ─── 로그인 유도 카드 ────────────────────────────────────────
          const _LoginPromptCard(),
          const SizedBox(height: 28),

          // ─── 기능 안내 섹션 ──────────────────────────────────────────
          const _LockedFeaturesSection(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 로그인 유도 카드
// ─────────────────────────────────────────────────────────────────────────────

class _LoginPromptCard extends StatelessWidget {
  const _LoginPromptCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 오토바이 아이콘 원형 배경
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bike_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // 환영 문구
          Text(
            '환영합니다!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 10),

          // 서브 문구
          Text(
            '로그인 또는 회원가입 후 오토바이 부속품 주문과\n배송 조회, 다양한 혜택을 이용해 보세요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 24),

          // 로그인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                '로그인',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 회원가입 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.divider, width: 1.5),
              ),
              child: Text(
                '회원가입',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 기능 안내 섹션 (잠금 아이템 목록)
// ─────────────────────────────────────────────────────────────────────────────

class _LockedFeaturesSection extends StatelessWidget {
  const _LockedFeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '로그인 후 이용 가능한 기능',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            children: [
              _LockedFeatureTile(
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.primary,
                title: '주문내역',
                description: '주문하신 상품의 배송 상태와 구매 이력을 확인하세요.',
              ),
              Divider(height: 1, indent: 64, color: AppColors.divider),
              _LockedFeatureTile(
                icon: Icons.favorite_outline,
                iconColor: Color(0xFFFF4C6A),
                title: '위시리스트',
                description: '관심 있는 부품을 저장하고 나중에 확인해보세요.',
              ),
              Divider(height: 1, indent: 64, color: AppColors.divider),
              _LockedFeatureTile(
                icon: Icons.headset_mic_outlined,
                iconColor: AppColors.textSecondary,
                title: '1:1 문의',
                description: '궁금하신 점을 남겨주시면 친절하게 상담해 드립니다.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LockedFeatureTile extends StatelessWidget {
  const _LockedFeatureTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 아이콘 + 자물쇠 오버레이
          SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                // 자물쇠 배지 (우측 하단)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 화살표
          const Icon(
            Icons.chevron_right,
            color: AppColors.textHint,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 프로필 카드
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final meta = user?.userMetadata ?? {};
    final name = (meta['name'] as String? ?? '').trim();
    final email = user?.email ?? '';
    // 이름이 없으면 이메일 앞부분, 둘 다 없으면 '사용자'
    final displayName = name.isNotEmpty ? name : (email.split('@').first);
    final avatarLetter =
        displayName.isNotEmpty ? displayName.characters.first.toUpperCase() : '?';

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
          // 원형 아바타 (이름 첫 글자)
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFD6E4FF),
              shape: BoxShape.circle,
            ),
            child: Text(
              avatarLetter,
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
                Text(displayName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // 설정 아이콘
          IconButton(
            onPressed: () => _navigateToEditProfile(context),
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
  const _DashboardRow({
    required this.orderCount,
    required this.wishlistCount,
  });

  final int orderCount;
  final int wishlistCount;

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
            count: '$wishlistCount',
            label: '위시리스트',
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
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
  const _MenuList({
    required this.orderCount,
    required this.wishlistCount,
  });

  final int orderCount;
  final int wishlistCount;

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
            count: wishlistCount,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            ),
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

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  static const Color _logoutRed = Color(0xFFE5534B);
  static const Color _logoutBg = Color(0xFFFFECEC);

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '로그아웃',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          '정말 로그아웃 하시겠어요?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _logoutRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _logoutBg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _confirmLogout(context, ref),
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
