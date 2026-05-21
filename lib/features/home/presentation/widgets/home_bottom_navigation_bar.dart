import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/constants.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.isAdmin,
    required this.onTap,
  });

  final int selectedIndex;
  final bool isAdmin;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: '홈'),
    (
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: '장바구니'
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: '마이페이지'
    ),
    (
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings,
      label: '관리자'
    ),
  ];

  bool _isDisabled(int index) =>
      isAdmin && (index == NavIndex.cart || index == NavIndex.myPage);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = selectedIndex == index;
              final disabled = _isDisabled(index);

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Opacity(
                    opacity: disabled ? 0.30 : 1.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
