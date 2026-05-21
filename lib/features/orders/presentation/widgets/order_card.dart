import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/order_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 공개 주문 카드 위젯 (관리자 화면 / 내 주문 화면에서 공용으로 사용)
// ─────────────────────────────────────────────────────────────────────────────

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.isCancelling = false,
    this.isConfirming = false,
    this.onCancel,
    this.onConfirmPayment,
  });

  final OrderModel order;
  final bool isCancelling;
  final bool isConfirming;

  /// null이면 취소 버튼을 표시하지 않습니다.
  final VoidCallback? onCancel;

  /// null이면 입금 확인 버튼을 표시하지 않습니다.
  final VoidCallback? onConfirmPayment;

  @override
  Widget build(BuildContext context) {
    final dateStr = order.createdAt != null
        ? orderFormatDate(order.createdAt!)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더 (주문번호 + 날짜 + 상태 배지)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                OrderStatusBadge(status: order.status),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // 고객 정보
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                OrderCustomerAvatar(name: order.customerName),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customerPhone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 주문 상품 목록
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _OrderItemList(items: order.orderItems),
          ),

          // 총 금액 + 액션 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '총 금액',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      orderFormatKrw(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onConfirmPayment != null &&
                        order.isPaymentConfirmable) ...[
                      _ConfirmPaymentButton(
                        isConfirming: isConfirming,
                        onPressed: isConfirming ? null : onConfirmPayment,
                      ),
                      if (onCancel != null && order.isCancellable)
                        const SizedBox(width: 8),
                    ],
                    if (onCancel != null && order.isCancellable)
                      _CancelButton(
                        isCancelling: isCancelling,
                        onPressed: isCancelling ? null : onCancel,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상태 배지 (한국어)
// ─────────────────────────────────────────────────────────────────────────────

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg, icon) = switch (status) {
      'pending' => (
          '결제 대기',
          const Color(0xFFFFF8E1),
          const Color(0xFFF59E0B),
          Icons.schedule,
        ),
      'paid' => (
          '결제 완료',
          const Color(0xFFE8F5E9),
          const Color(0xFF22C55E),
          Icons.check_circle_outline,
        ),
      'shipping' => (
          '배송 중',
          const Color(0xFFE8F0FF),
          AppColors.primary,
          Icons.local_shipping_outlined,
        ),
      'completed' => (
          '배송 완료',
          const Color(0xFFE8F0FF),
          AppColors.primary,
          Icons.local_shipping_outlined,
        ),
      'cancelled' => (
          '취소됨',
          const Color(0xFFFFEDED),
          AppColors.accent,
          Icons.cancel_outlined,
        ),
      _ => (
          status,
          const Color(0xFFF3F4F6),
          AppColors.textSecondary,
          Icons.info_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 고객 이름 이니셜 아바타
// ─────────────────────────────────────────────────────────────────────────────

class OrderCustomerAvatar extends StatelessWidget {
  const OrderCustomerAvatar({super.key, required this.name});

  final String name;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 주문 상품 목록
// ─────────────────────────────────────────────────────────────────────────────

class _OrderItemList extends StatelessWidget {
  const _OrderItemList({required this.items});

  final List<OrderItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상품 ${items.length}개',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${item.productName} (${item.quantity}개)',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
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
// 주문 취소 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.isCancelling,
    required this.onPressed,
  });

  final bool isCancelling;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: BorderSide(
          color: isCancelling ? AppColors.textHint : AppColors.accent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: isCancelling
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 15),
                SizedBox(width: 4),
                Text('주문 취소'),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 입금 확인 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmPaymentButton extends StatelessWidget {
  const _ConfirmPaymentButton({
    required this.isConfirming,
    required this.onPressed,
  });

  final bool isConfirming;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF22C55E),
        side: BorderSide(
          color:
              isConfirming ? AppColors.textHint : const Color(0xFF22C55E),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: isConfirming
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF22C55E),
              ),
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 15),
                SizedBox(width: 4),
                Text('입금 확인'),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 유틸 함수 (외부에서 접근 가능)
// ─────────────────────────────────────────────────────────────────────────────

String orderParseErrorMessage(String raw) {
  final colonIdx = raw.indexOf(':');
  if (colonIdx != -1 && colonIdx < raw.length - 1) {
    final after = raw.substring(colonIdx + 1).trim();
    if (after.contains(RegExp(r'[가-힣]'))) return after;
  }
  return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
}

String orderFormatDate(DateTime dt) {
  return '${dt.year}년 ${dt.month}월 ${dt.day}일';
}

String orderFormatKrw(int price) {
  final s = price.toString();
  final buf = StringBuffer('₩');
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ─────────────────────────────────────────────────────────────────────────────
// 제품 썸네일 URL 조회 (productId → is_main 이미지 우선, 없으면 첫 번째)
// ─────────────────────────────────────────────────────────────────────────────

final productThumbnailProvider =
    FutureProvider.autoDispose.family<String?, int>((ref, productId) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('product_images')
      .select('image_url, is_main')
      .eq('product_id', productId);

  final images = (response as List).cast<Map<String, dynamic>>();
  if (images.isEmpty) return null;

  final main = images.firstWhere(
    (img) => img['is_main'] == true,
    orElse: () => images.first,
  );
  return main['image_url'] as String?;
});

// ─────────────────────────────────────────────────────────────────────────────
// 고객용 주문 카드 (마이페이지 주문내역에서 사용)
// ─────────────────────────────────────────────────────────────────────────────

class MyOrderCard extends StatelessWidget {
  const MyOrderCard({
    super.key,
    required this.order,
    this.onViewDetail,
  });

  final OrderModel order;
  final VoidCallback? onViewDetail;

  @override
  Widget build(BuildContext context) {
    final dateStr = order.createdAt != null
        ? orderFormatDate(order.createdAt!)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더: 주문번호·날짜(좌) + 상태 배지(우)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주문번호: ${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                OrderStatusBadge(status: order.status),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // 상품 목록
          ...order.orderItems.map(
            (item) => _MyOrderItemRow(item: item),
          ),
          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.divider),

          // 하단: 총 금액(좌) + 상세 보기 버튼(우)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '총 금액',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      orderFormatKrw(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _ViewDetailButton(onPressed: onViewDetail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyOrderItemRow extends ConsumerWidget {
  const _MyOrderItemRow({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnailAsync = ref.watch(productThumbnailProvider(item.productId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // 상품 이미지 (로드 중·실패 시 플레이스홀더)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: thumbnailAsync.when(
              data: (url) => url != null
                  ? CachedNetworkImage(
                      imageUrl: url,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const _ImagePlaceholder(),
                      errorWidget: (_, __, ___) => const _ImagePlaceholder(),
                    )
                  : const _ImagePlaceholder(),
              loading: () => const _ImagePlaceholder(),
              error: (_, __) => const _ImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 12),

          // 상품명 + 수량
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '수량: ${item.quantity}개',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 단가
          Text(
            orderFormatKrw(item.unitPrice),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textHint,
        size: 22,
      ),
    );
  }
}

class _ViewDetailButton extends StatelessWidget {
  const _ViewDetailButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '상세 보기',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2),
          Icon(Icons.chevron_right, size: 17),
        ],
      ),
    );
  }
}
