import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/auth_guard.dart';
import 'package:bike_house/core/widgets/app_floating_snackbar.dart';
import 'package:bike_house/features/product/application/product_detail_notifier.dart';
import 'package:bike_house/features/product/presentation/widgets/circle_icon_button.dart';
import 'package:bike_house/features/wishlist/application/wishlist_notifier.dart';

class ProductDetailAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ProductDetailAppBar({super.key, required this.productId});

  final int productId;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(
      wishlistProvider.select(
        (async) => async.valueOrNull?.any((p) => p.id == productId) ?? false,
      ),
    );
    final product = ref.read(productDetailProvider(productId)).valueOrNull;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: CircleIconButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        CircleIconButton(
          icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
          iconColor:
              isWishlisted ? const Color(0xFFFF4C6A) : AppColors.textPrimary,
          onTap: () {
            if (product != null) {
              requireAuth(context, ref,
                  () => ref.read(wishlistProvider.notifier).toggle(product));
            }
          },
        ),
        const SizedBox(width: 8),
        CircleIconButton(
          icon: Icons.share_outlined,
          onTap: () => showAppFloatingSnackBar(
            context,
            '공유 기능은 준비 중입니다.',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
