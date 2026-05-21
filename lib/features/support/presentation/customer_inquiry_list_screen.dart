import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/chat/domain/chat_models.dart';
import 'package:bike_house/features/support/application/inquiry_providers.dart';
import 'package:bike_house/features/support/data/inquiry_local_cache.dart';
import 'package:bike_house/features/support/presentation/customer_support_chat_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1:1 상담 목록 화면
// ─────────────────────────────────────────────────────────────────────────────

class CustomerInquiryListScreen extends ConsumerWidget {
  const CustomerInquiryListScreen({super.key});

  /// 활성 방 앞, 종료된 방 뒤 (종료는 오래된 순 = 맨 밑)
  static List<ChatRoom> _merge(
    List<ChatRoom> liveRooms,
    List<InquiryCacheEntry> cachedEntries,
  ) {
    final active = liveRooms
        .where((r) => !r.status.isCompleted)
        .toList()
      ..sort(
        (a, b) => (b.lastMessageAt ?? b.createdAt)
            .compareTo(a.lastMessageAt ?? a.createdAt),
      );

    final liveCompleted =
        liveRooms.where((r) => r.status.isCompleted).toList();
    final liveIds = {for (final r in liveCompleted) r.id};

    // 캐시에만 남은 항목 (Supabase에서 더 이상 조회 안 될 때 폴백)
    final cachedOnly = cachedEntries
        .where((e) => !liveIds.contains(e.id))
        .map((e) => e.toChatRoom())
        .toList();

    final allCompleted = [...liveCompleted, ...cachedOnly]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신이 위·오래된 게 맨 아래

    return [...active, ...allCompleted];
  }

  void _openChat(BuildContext context, {String? roomId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerSupportChatScreen(initialRoomId: roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(customerAllRoomsProvider);
    final cacheAsync = ref.watch(inquiryCacheNotifierProvider);

    // 종료된 방을 로컬 캐시에 자동 저장
    ref.listen(customerAllRoomsProvider, (_, next) {
      next.whenData((rooms) {
        for (final room in rooms.where((r) => r.status.isCompleted)) {
          ref
              .read(inquiryCacheNotifierProvider.notifier)
              .upsert(InquiryCacheEntry.fromChatRoom(room));
        }
      });
    });

    final liveRooms = liveAsync.valueOrNull ?? [];
    final cached = cacheAsync.valueOrNull ?? [];
    final allRooms = _merge(liveRooms, cached);

    final waitingCount =
        allRooms.where((r) => r.status.isWaiting || r.status.isActive).length;
    final completedCount =
        allRooms.where((r) => r.status.isCompleted).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: liveAsync.isLoading && liveRooms.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(customerAllRoomsProvider),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          const SizedBox(height: 16),
                          _NewChatButton(
                            onTap: () => _openChat(context),
                          ),
                          const SizedBox(height: 16),
                          _StatusRow(
                            waitingCount: waitingCount,
                            completedCount: completedCount,
                          ),
                          const SizedBox(height: 24),
                          if (allRooms.isEmpty)
                            const _EmptyState()
                          else ...[
                            const Text(
                              '상담 내역',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...allRooms.map(
                              (room) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _InquiryCard(
                                  room: room,
                                  onTap: () =>
                                      _openChat(context, roomId: room.id),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 헤더
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: onBack,
          ),
          const SizedBox(width: 2),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1:1 상담',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '문의 내역을 확인하세요',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
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
// 새 상담하기 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _NewChatButton extends StatelessWidget {
  const _NewChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          '새 상담하기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 상태 요약 Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.waitingCount,
    required this.completedCount,
  });

  final int waitingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFFEF3C7),
            count: waitingCount,
            label: '답변대기',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF22C55E),
            iconBgColor: const Color(0xFFDCFCE7),
            count: completedCount,
            label: '상담종료',
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
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
// 상담 카드
// ─────────────────────────────────────────────────────────────────────────────

class _InquiryCard extends StatelessWidget {
  const _InquiryCard({required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  static const _amberColor = Color(0xFFF59E0B);
  static const _amberBg = Color(0xFFFEF3C7);
  static const _greenColor = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFDCFCE7);

  @override
  Widget build(BuildContext context) {
    final isCompleted = room.status.isCompleted;

    final statusColor = isCompleted ? _greenColor : _amberColor;
    final statusBg = isCompleted ? _greenBg : _amberBg;
    final statusLabel = isCompleted ? '상담종료' : '답변대기';
    final iconData = isCompleted
        ? Icons.check_circle_outline_rounded
        : Icons.access_time_rounded;

    final dateTime = room.lastMessageAt ?? room.createdAt;
    final dateStr =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';

    final preview = room.lastMessage ?? '';
    final title = preview.isNotEmpty ? preview : '바이크하우스';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 상태 아이콘
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),

                // 제목·미리보기·날짜
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 상태 배지
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview.isEmpty ? '바이크하우스 1:1 상담' : preview,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 빈 상태
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 56,
              color: AppColors.textHint,
            ),
            SizedBox(height: 14),
            Text(
              '상담 내역이 없습니다.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '위 버튼을 눌러 새 상담을 시작해보세요.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
