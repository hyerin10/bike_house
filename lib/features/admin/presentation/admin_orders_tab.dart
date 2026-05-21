import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 주문 검색 쿼리 상태
final adminOrderSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

String _formatKrw(int price) {
  final s = price.toString();
  final buf = StringBuffer('₩');
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ─────────────────────────────────────────────────────────────────────────────
// 샘플 주문 데이터 모델
// ─────────────────────────────────────────────────────────────────────────────

class _OrderData {
  const _OrderData({
    required this.orderId,
    required this.date,
    required this.customerName,
    required this.customerEmail,
    required this.total,
    required this.status,
    this.statusAction,
  });

  final String orderId;
  final String date;
  final String customerName;
  final String customerEmail;
  final int total;
  final String status;
  final String? statusAction;
}

const _sampleOrders = [
  _OrderData(
    orderId: 'ORD-2024-001',
    date: '2024. 3. 18.',
    customerName: '김민수',
    customerEmail: 'minsu@example.com',
    total: 234980,
    status: '완료',
  ),
  _OrderData(
    orderId: 'ORD-2024-002',
    date: '2024. 3. 17.',
    customerName: '이지영',
    customerEmail: 'jiyoung@example.com',
    total: 599990,
    status: '배송중',
    statusAction: '주문 취소',
  ),
  _OrderData(
    orderId: 'ORD-2024-003',
    date: '2024. 3. 16.',
    customerName: '박준서',
    customerEmail: 'junseo@example.com',
    total: 89900,
    status: '처리중',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// 주문 내역 탭
// ─────────────────────────────────────────────────────────────────────────────

class AdminOrdersTab extends ConsumerWidget {
  const AdminOrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(adminOrderSearchQueryProvider);

    final filtered = searchQuery.isEmpty
        ? _sampleOrders
        : _sampleOrders
            .where(
              (o) =>
                  o.orderId.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  o.customerName.contains(searchQuery),
            )
            .toList();

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            onChanged: (q) =>
                ref.read(adminOrderSearchQueryProvider.notifier).state = q,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '주문번호, 고객명으로 검색...',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textHint,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    '검색 결과가 없습니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _OrderCard(order: filtered[index]),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 주문 카드
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _OrderData order;

  Color get _statusColor {
    return switch (order.status) {
      '완료' => const Color(0xFF22C55E),
      '배송중' => AppColors.primary,
      '처리중' => const Color(0xFFF59E0B),
      _ => AppColors.textSecondary,
    };
  }

  Color get _statusBgColor {
    return switch (order.status) {
      '완료' => const Color(0xFFDCFCE7),
      '배송중' => const Color(0xFFDCEFFF),
      '처리중' => const Color(0xFFFEF3C7),
      _ => const Color(0xFFF0F1F5),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.orderId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (order.status == '완료')
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: _statusColor,
                        ),
                      ),
                    if (order.status == '배송중')
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          Icons.local_shipping_outlined,
                          size: 12,
                          color: _statusColor,
                        ),
                      ),
                    Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            order.date,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F1F5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    order.customerName[0],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
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
                    Text(
                      order.customerEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
                  Text(
                    _formatKrw(order.total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (order.statusAction != null)
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, size: 13),
                  label: Text(
                    order.statusAction!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
