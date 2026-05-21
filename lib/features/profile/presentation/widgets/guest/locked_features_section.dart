import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class LockedFeaturesSection extends StatelessWidget {
  const LockedFeaturesSection({super.key});

  static const _features = [
    _FeatureItem(
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.primary,
      title: '주문내역',
      description: '주문하신 상품의 배송 상태와 구매 이력을 확인하세요.',
    ),
    _FeatureItem(
      icon: Icons.favorite_outline,
      iconColor: AppColors.wishlistRed,
      title: '위시리스트',
      description: '관심 있는 부품을 저장하고 나중에 확인해보세요.',
    ),
    _FeatureItem(
      icon: Icons.headset_mic_outlined,
      iconColor: AppColors.textSecondary,
      title: '1:1 문의',
      description: '궁금하신 점을 남겨주시면 친절하게 상담해 드립니다.',
    ),
  ];

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
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _features.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, indent: 64, color: AppColors.divider),
                _LockedFeatureTile(item: _features[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
}

class _LockedFeatureTile extends StatelessWidget {
  const _LockedFeatureTile({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
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
                    child: const Icon(Icons.lock, color: Colors.white, size: 9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  item.description,
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
          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}
