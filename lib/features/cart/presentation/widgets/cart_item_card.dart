import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/core/utils/format_krw.dart';
import 'package:bike_house/features/cart/application/cart_controller.dart';

void _showStockLimitSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('재고가 부족합니다.'),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade700,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

class CartItemCard extends ConsumerWidget {
  const CartItemCard({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(cartProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const _CartImagePlaceholder(),
                      errorWidget: (_, __, ___) =>
                          const _CartImagePlaceholder(),
                    )
                  : const _CartImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatKrw(item.price),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => controller.removeItem(item.id),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onTap: () =>
                        controller.updateQuantity(item.id, item.quantity - 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    isDisabled: item.isAtStockLimit,
                    onTap: () {
                      final success = controller.updateQuantity(
                        item.id,
                        item.quantity + 1,
                      );
                      if (!success) {
                        _showStockLimitSnackBar(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.background : null,
          border: Border.all(
            color: isDisabled
                ? AppColors.divider.withValues(alpha: 0.4)
                : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDisabled ? AppColors.textHint : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CartImagePlaceholder extends StatelessWidget {
  const _CartImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 32,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
