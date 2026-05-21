import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/wishlist/application/wishlist_notifier.dart';
import 'package:bike_house/features/wishlist/presentation/widgets/wishlist_app_bar.dart';
import 'package:bike_house/features/wishlist/presentation/widgets/wishlist_empty_view.dart';
import 'package:bike_house/features/wishlist/presentation/widgets/wishlist_error_view.dart';
import 'package:bike_house/features/wishlist/presentation/widgets/wishlist_item_card.dart';

/// 위시리스트 목록 화면
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);
    final itemCount = ref.watch(wishlistCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildWishlistAppBar(context, itemCount: itemCount),
      body: wishlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => WishlistErrorView(
          onRetry: () => ref.read(wishlistProvider.notifier).build(),
        ),
        data: (items) => items.isEmpty
            ? WishlistEmptyView(onBrowse: () => Navigator.of(context).pop())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    WishlistItemCard(product: items[index]),
              ),
      ),
    );
  }
}
