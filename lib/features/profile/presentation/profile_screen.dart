import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/profile_controller.dart';

/// 마이페이지 화면
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // 헤더
          const _ProfilePageHeader(),

          const SizedBox(height: 16),

          // 프로필 카드
          _ProfileCard(user: profile.user),

          const SizedBox(height: 20),

          // 내 차고 섹션
          _GarageSection(bikes: profile.bikes),

          const SizedBox(height: 16),

          // 통계 그리드
          _StatsGrid(stats: profile.stats),

          const SizedBox(height: 24),

          // 로그아웃 버튼
          _LogoutButton(
            onLogout: () => ref.read(profileProvider.notifier).logout(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 헤더
// ─────────────────────────────────────────────────────────────────────────────

class _ProfilePageHeader extends StatelessWidget {
  const _ProfilePageHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('마이페이지', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 2),
          Text('내 차고 관리', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 프로필 카드 (아바타 + 이름 + 이메일 + 설정)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // 이니셜 아바타
            _InitialsAvatar(initials: user.initials),

            const SizedBox(width: 14),

            // 이름 + 이메일
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // 설정 아이콘
            IconButton(
              onPressed: () {
                // 추후 설정 화면으로 이동
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textHint,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 이니셜 아바타 위젯
class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내 차고 섹션
// ─────────────────────────────────────────────────────────────────────────────

class _GarageSection extends StatelessWidget {
  const _GarageSection({required this.bikes});

  final List<BikeInfo> bikes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 섹션 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('내 차고', style: Theme.of(context).textTheme.headlineMedium),
              GestureDetector(
                onTap: () {
                  // 추후 바이크 추가 화면으로 이동
                },
                child: Row(
                  children: [
                    const Icon(Icons.add, color: AppColors.primary, size: 16),
                    Text(
                      '바이크 추가',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 바이크 목록
          ...bikes.map((bike) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BikeCard(bike: bike),
              )),
        ],
      ),
    );
  }
}

/// 바이크 카드 위젯
class _BikeCard extends StatelessWidget {
  const _BikeCard({required this.bike});

  final BikeInfo bike;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // 바이크 아이콘
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.two_wheeler,
              color: AppColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bike.model, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(bike.year, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 22),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 통계 그리드 (주문 / 찜 / 쿠폰)
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.inventory_2_outlined,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryLight,
              count: stats.orderCount,
              label: '주문',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatItem(
              icon: Icons.favorite_outline,
              iconColor: const Color(0xFFEF4444),
              iconBgColor: const Color(0xFFFFEBEB),
              count: stats.wishlistCount,
              label: '찜',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatItem(
              icon: Icons.local_offer_outlined,
              iconColor: const Color(0xFF22C55E),
              iconBgColor: const Color(0xFFEAFAF1),
              count: stats.couponCount,
              label: '쿠폰',
            ),
          ),
        ],
      ),
    );
  }
}

/// 통계 아이템 위젯
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 로그아웃 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onLogout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '로그아웃',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFEF4444),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
