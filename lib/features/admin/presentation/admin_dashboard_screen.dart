import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/product/application/product_notifier.dart';
import '../../../features/product/data/product_model.dart';
import '../../../providers/auth_provider.dart';
import 'add_product_screen.dart';
import 'admin_chat_room_screen.dart';
import 'edit_product_screen.dart';

/// 관리자 대시보드 탭 인덱스
enum _AdminTab { chat, orders, products }

/// 관리자 대시보드 내 현재 탭 상태
final _adminTabProvider = StateProvider.autoDispose<_AdminTab>(
  (ref) => _AdminTab.products,
);

/// 상품 검색 쿼리 상태
final _adminSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// 주문 검색 쿼리 상태
final _orderSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// 원화 형식 포맷 (예: ₩89,900)
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
// 관리자 대시보드 메인 화면
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(_adminTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        _DashboardHeader(
          onLogout: () => ref.read(authProvider.notifier).signOut(),
        ),
        // 탭 버튼 영역
        _TabBar(
          currentTab: currentTab,
          onTabChanged: (tab) {
            ref.read(_adminTabProvider.notifier).state = tab;
          },
        ),
        // 탭 콘텐츠
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: switch (currentTab) {
              _AdminTab.products => const _ProductsTabContent(
                  key: ValueKey('products'),
                ),
              _AdminTab.orders => const _OrdersTabContent(
                  key: ValueKey('orders'),
                ),
              _AdminTab.chat => const _ChatTabContent(
                  key: ValueKey('chat'),
                ),
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 대시보드 헤더
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '관리자 대시보드',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '상품을 등록하고 관리하세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_outlined, size: 16),
            label: const Text('로그아웃'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: const TextStyle(fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 탭 버튼 행
// ─────────────────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.currentTab, required this.onTabChanged});

  final _AdminTab currentTab;
  final ValueChanged<_AdminTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TabButton(
              label: '상담 관리',
              icon: Icons.chat_bubble_outline,
              isSelected: currentTab == _AdminTab.chat,
              badgeCount: 2,
              onTap: () => onTabChanged(_AdminTab.chat),
            ),
            const SizedBox(width: 8),
            _TabButton(
              label: '주문 내역',
              icon: Icons.receipt_long_outlined,
              isSelected: currentTab == _AdminTab.orders,
              onTap: () => onTabChanged(_AdminTab.orders),
            ),
            const SizedBox(width: 8),
            _TabButton(
              label: '상품 관리',
              icon: Icons.inventory_2_outlined,
              isSelected: currentTab == _AdminTab.products,
              onTap: () => onTabChanged(_AdminTab.products),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1A2A3A)
                : const Color(0xFFF0F1F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              // 인라인 캡슐 뱃지
              if (badgeCount != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEF4444).withValues(alpha: 0.9)
                        : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 관리 탭 콘텐츠
// ─────────────────────────────────────────────────────────────────────────────

class _ProductsTabContent extends ConsumerWidget {
  const _ProductsTabContent({super.key});

  void _handleEdit(BuildContext context, ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
    );
  }

  void _handleDelete(
    BuildContext context,
    WidgetRef ref,
    ProductModel product,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '상품 삭제',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '\'${product.name}\'\n을(를) 삭제하시겠습니까?',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(productProvider.notifier).deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('삭제되었습니다.'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text(
              '삭제',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productProvider);
    final searchQuery = ref.watch(_adminSearchQueryProvider);

    return Column(
      children: [
        // 배경 + 검색바 + 상품 등록 버튼
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // 검색바
              _ProductSearchBar(
                onChanged: (q) =>
                    ref.read(_adminSearchQueryProvider.notifier).state = q,
              ),
              const SizedBox(height: 12),
              // 상품 등록 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    '상품 등록',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 테이블 헤더
        const _ProductTableHeader(),

        // 상품 목록
        Expanded(
          child: asyncProducts.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '상품을 불러오지 못했습니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(productProvider.notifier).refresh(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
            data: (products) {
              final filtered = searchQuery.isEmpty
                  ? products
                  : products
                      .where((p) => p.name
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) return const _EmptyProductView();

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  return _ProductRow(
                    product: product,
                    onEdit: () => _handleEdit(context, product),
                    onDelete: () => _handleDelete(context, ref, product),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 검색바
// ─────────────────────────────────────────────────────────────────────────────

class _ProductSearchBar extends StatelessWidget {
  const _ProductSearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '상품명으로 검색...',
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 테이블 헤더
// ─────────────────────────────────────────────────────────────────────────────

class _ProductTableHeader extends StatelessWidget {
  const _ProductTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 40),
          SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              '상품명',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '가격',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '재고',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 56,
            child: Text(
              '수정/삭제',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상품 목록 행
// ─────────────────────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final stock = product.stock ?? 0;
    final isOutOfStock = stock == 0;
    final isLowStock = stock > 0 && stock <= 5;
    final thumbnailUrl = product.thumbnailUrl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 상품 아바타 (이미지 있으면 이미지, 없으면 박스 아이콘)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 40,
              child: thumbnailUrl != null
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _BoxIconAvatar(),
                    )
                  : const _BoxIconAvatar(),
            ),
          ),

          const SizedBox(width: 10),

          // 상품명
          Expanded(
            flex: 4,
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 가격
          SizedBox(
            width: 70,
            child: Text(
              _formatKrw(product.price),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 재고 배지
          SizedBox(
            width: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? const Color(0xFFFFEDED)
                    : isLowStock
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$stock',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isOutOfStock
                      ? AppColors.accent
                      : isLowStock
                          ? const Color(0xFFE65100)
                          : const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 수정 / 삭제 아이콘
          SizedBox(
            width: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 박스 아이콘 플레이스홀더 아바타
class _BoxIconAvatar extends StatelessWidget {
  const _BoxIconAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F1F5),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textHint,
        size: 20,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 빈 상품 목록 뷰
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyProductView extends StatelessWidget {
  const _EmptyProductView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 14),
          Text(
            '등록된 상품이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '위의 \'상품 등록\' 버튼으로 상품을 추가해 보세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 주문 내역 탭 콘텐츠
// ─────────────────────────────────────────────────────────────────────────────

/// 샘플 주문 데이터 모델
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

class _OrdersTabContent extends ConsumerWidget {
  const _OrdersTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(_orderSearchQueryProvider);

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
        // 검색바
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            onChanged: (q) =>
                ref.read(_orderSearchQueryProvider.notifier).state = q,
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

        // 주문 카드 목록
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
          // 주문 ID + 날짜 + 상태 배지
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

          // 고객 정보
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

          // 총 금액 + 액션 버튼
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

// ─────────────────────────────────────────────────────────────────────────────
// 상담 관리 탭 콘텐츠
// ─────────────────────────────────────────────────────────────────────────────

/// 샘플 상담 데이터 모델
class _ChatData {
  const _ChatData({
    required this.name,
    required this.previewText,
    required this.timeAgo,
    this.email = '',
    this.productTitle = '',
    this.badgeCount,
    this.isActive = false,
    this.showChatButton = false,
  });

  final String name;
  final String previewText;
  final String timeAgo;
  final String email;
  final String productTitle;
  final int? badgeCount;
  final bool isActive;
  final bool showChatButton;
}

const _sampleChats = [
  _ChatData(
    name: '홍길동',
    previewText: '혼다 PCX 2019년식 윈드스크...',
    timeAgo: '2분 전',
    email: 'hong@example.com',
    productTitle: '혼다 PCX 2019년식 윈도우 ...',
    badgeCount: 2,
    isActive: true,
    showChatButton: true,
  ),
  _ChatData(
    name: '김철수',
    previewText: '주문한 브레이크 패드 배송 언제...',
    timeAgo: '15분 전',
    email: 'kimcs@example.com',
    productTitle: '브레이크 패드 세트',
    badgeCount: 1,
    isActive: true,
  ),
  _ChatData(
    name: '이영희',
    previewText: '엔진오일 교환 주기 문의드립니다',
    timeAgo: '1시간 전',
    email: 'leeyh@example.com',
    productTitle: '엔진오일 교환 서비스',
  ),
  _ChatData(
    name: '최민준',
    previewText: '타이어 교체 비용 견적 요청합니다',
    timeAgo: '3시간 전',
    email: 'choimj@example.com',
    productTitle: '타이어 교체 서비스',
  ),
];

class _ChatTabContent extends StatelessWidget {
  const _ChatTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        // 카운터 카드 영역
        Row(
          children: [
            Expanded(
              child: _StatusCountCard(
                label: '대기중',
                count: 2,
                dotColor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusCountCard(
                label: '상담중',
                count: 1,
                dotColor: const Color(0xFF22C55E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 고객 상담 카드 목록
        ..._sampleChats
            .map((chat) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ChatCard(chat: chat),
                )),
      ],
    );
  }
}

class _StatusCountCard extends StatelessWidget {
  const _StatusCountCard({
    required this.label,
    required this.count,
    required this.dotColor,
  });

  final String label;
  final int count;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({required this.chat});

  final _ChatData chat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 아바타
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F1F5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 22,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              if (chat.isActive)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // 이름 + 미리보기 (유연하게 나머지 공간 차지)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      chat.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (chat.badgeCount != null)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${chat.badgeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      chat.timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  chat.previewText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 상담하기 버튼 — 아바타/텍스트와 같은 행, 우측 정렬
          if (chat.showChatButton) ...[
            const SizedBox(width: 10),
            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminChatRoomScreen(
                        customerName: chat.name,
                        customerEmail: chat.email,
                        productTitle: chat.productTitle,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2A3A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '상담하기',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
