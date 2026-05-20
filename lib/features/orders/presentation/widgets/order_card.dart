import 'package:flutter/material.dart';

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
          const Color(0xFFF3F4F6),
          AppColors.textSecondary,
          Icons.done_all,
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
  return '${dt.year}. ${dt.month}. ${dt.day}.';
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
