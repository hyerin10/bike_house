import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/support/application/inquiry_providers.dart';
import 'package:bike_house/features/support/presentation/customer_support_chat_screen.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_inquiry_empty_state.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_inquiry_list_header.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_inquiry_new_chat_button.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_inquiry_room_card.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_inquiry_status_row.dart';
import 'package:bike_house/features/support/presentation/widgets/inquiry_completed_rooms_cache_sync.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1:1 상담 목록 화면
// ─────────────────────────────────────────────────────────────────────────────

class CustomerInquiryListScreen extends ConsumerWidget {
  const CustomerInquiryListScreen({super.key});

  void _openChat(BuildContext context, {String? roomId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerSupportChatScreen(initialRoomId: roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(customerInquiryListViewStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomerInquiryListHeader(
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: view.isInitialLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () async =>
                              ref.invalidate(customerAllRoomsProvider),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              const SizedBox(height: 16),
                              CustomerInquiryNewChatButton(
                                onTap: () => _openChat(context),
                              ),
                              const SizedBox(height: 16),
                              CustomerInquiryStatusRow(
                                waitingCount: view.waitingCount,
                                completedCount: view.completedCount,
                              ),
                              const SizedBox(height: 24),
                              if (view.mergedRooms.isEmpty)
                                const CustomerInquiryEmptyState()
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
                                ...view.mergedRooms.map(
                                  (room) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: CustomerInquiryRoomCard(
                                      room: room,
                                      onTap: () => _openChat(
                                        context,
                                        roomId: room.id,
                                      ),
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
            const InquiryCompletedRoomsCacheSync(),
          ],
        ),
      ),
    );
  }
}
