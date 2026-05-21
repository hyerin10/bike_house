import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/chat/domain/chat_models.dart';
import 'package:bike_house/features/support/application/customer_support_room_status_provider.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_support_chat_message_widgets.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_support_message_input_bar.dart';

/// `roomId`가 확정된 뒤 메시지 목록·입력 영역을 표시합니다.
class CustomerSupportChatBody extends ConsumerStatefulWidget {
  const CustomerSupportChatBody({
    super.key,
    required this.roomId,
    required this.scrollController,
    required this.inputController,
    required this.focusNode,
    required this.onSend,
    required this.onScrollToBottom,
    required this.onImagePick,
  });

  final String roomId;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onScrollToBottom;
  final VoidCallback onImagePick;

  @override
  ConsumerState<CustomerSupportChatBody> createState() =>
      _CustomerSupportChatBodyState();
}

class _CustomerSupportChatBodyState extends ConsumerState<CustomerSupportChatBody> {
  ProviderSubscription<AsyncValue<List<ChatMessage>>>? _messagesSubscription;

  void _markAsRead() {
    ref.read(chatLastViewedAtProvider.notifier).state = DateTime.now();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markAsRead();
    });
    _messagesSubscription = ref.listenManual(
      chatMessagesProvider(widget.roomId),
      (previous, next) {
        next.whenData((_) {
          _markAsRead();
          widget.onScrollToBottom();
        });
      },
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomId));
    final roomStatusAsync =
        ref.watch(customerSupportRoomStatusProvider(widget.roomId));

    final myUid = Supabase.instance.client.auth.currentUser?.id ?? '';
    final statusLabel = roomStatusAsync.valueOrNull ?? 'WAITING';
    final isCompleted = statusLabel == 'COMPLETED';

    return SafeArea(
      child: Column(
        children: [
          if (statusLabel == 'WAITING')
            const CustomerSupportChatStatusBanner(
              color: Color(0xFFFEF3C7),
              icon: Icons.schedule_rounded,
              iconColor: Color(0xFFD97706),
              text: '상담원 연결을 기다리고 있습니다...',
            )
          else if (isCompleted)
            const CustomerSupportChatStatusBanner(
              color: Color(0xFFF3F4F6),
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.textSecondary,
              text: '상담이 종료되었습니다.',
            ),
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '메시지를 불러오지 못했습니다.\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const CustomerSupportChatEmptyState();
                }
                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == myUid;
                    return isMe
                        ? CustomerSupportChatMessageBubble.outbound(
                            text: msg.isImage ? null : msg.message,
                            imageUrl: msg.imageUrl,
                            timestamp: msg.timeLabel,
                          )
                        : CustomerSupportChatMessageBubble.inbound(
                            text: msg.isImage ? null : msg.message,
                            imageUrl: msg.imageUrl,
                            timestamp: msg.timeLabel,
                          );
                  },
                );
              },
            ),
          ),
          CustomerSupportMessageInputBar(
            controller: widget.inputController,
            focusNode: widget.focusNode,
            onSend: isCompleted ? null : widget.onSend,
            onImagePick: isCompleted ? null : widget.onImagePick,
            disabled: isCompleted,
          ),
        ],
      ),
    );
  }
}
