import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/constants.dart';
import 'package:bike_house/features/home/presentation/widgets/home_search_bar.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Size get preferredSize {
    final bottomHeight =
        selectedIndex == NavIndex.home ? 84.0 : 1.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kAppName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            kAppSlogan,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
      actions: const [],
      bottom: selectedIndex == NavIndex.home
          ? const PreferredSize(
              preferredSize: Size.fromHeight(84),
              child: HomeSearchBar(),
            )
          : const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.divider),
            ),
    );
  }
}
