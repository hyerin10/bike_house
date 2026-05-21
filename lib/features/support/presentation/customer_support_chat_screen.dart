import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 고객 채팅 화면
// ─────────────────────────────────────────────────────────────────────────────

class CustomerSupportChatScreen extends ConsumerStatefulWidget {
  const CustomerSupportChatScreen({super.key});

  @override
  ConsumerState<CustomerSupportChatScreen> createState() =>
      _CustomerSupportChatScreenState();
}

class _CustomerSupportChatScreenState
    extends ConsumerState<CustomerSupportChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String roomId) async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    try {
      await ref.read(chatRepositoryProvider).sendMessage(roomId, text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전송 실패: $e')),
      );
    }
  }

  Future<void> _sendImage(String roomId, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return;
    try {
      await ref.read(chatRepositoryProvider).sendImageMessage(roomId, file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 전송 실패: $e')),
      );
    }
  }

  void _showImageSourceSheet(String roomId) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.photo_library_outlined,
                      color: AppColors.primary),
                ),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _sendImage(roomId, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary),
                ),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _sendImage(roomId, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(customerRoomIdProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: _buildAppBar(context),
      body: roomAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 12),
              Text(
                '채팅방을 불러오지 못했습니다.\n$e',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(customerRoomIdProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (roomId) {
          if (roomId == null) {
            return const Center(child: Text('채팅방을 생성할 수 없습니다.'));
          }
          return _ChatBody(
            roomId: roomId,
            scrollController: _scrollController,
            inputController: _inputController,
            focusNode: _focusNode,
            onSend: () => _sendMessage(roomId),
            onScrollToBottom: _scrollToBottom,
            onImagePick: () => _showImageSourceSheet(roomId),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                _AppBarIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 4),
                const _HeadsetAvatar(size: 38),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '바이크하우스 고객센터',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          _OnlineDot(),
                          SizedBox(width: 4),
                          Text(
                            '온라인',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _AppBarIconButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 실제 채팅 바디 (roomId 확정 후 렌더)
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBody extends ConsumerStatefulWidget {
  const _ChatBody({
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
  ConsumerState<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends ConsumerState<_ChatBody> {
  void _markAsRead() {
    ref.read(chatLastViewedAtProvider.notifier).state = DateTime.now();
  }

  @override
  void initState() {
    super.initState();
    // 채팅 화면 진입 시 읽음 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomId));
    final roomStatusAsync = ref.watch(_roomStatusProvider(widget.roomId));

    // 새 메시지 도착 시 읽음 처리 + 스크롤
    ref.listen(chatMessagesProvider(widget.roomId), (_, next) {
      next.whenData((_) {
        _markAsRead();
        widget.onScrollToBottom();
      });
    });

    final myUid = Supabase.instance.client.auth.currentUser?.id ?? '';
    final statusLabel = roomStatusAsync.valueOrNull ?? 'WAITING';
    final isCompleted = statusLabel == 'COMPLETED';

    return SafeArea(
      child: Column(
        children: [
          // 상태 배너 (대기 중 / 상담 종료)
          if (statusLabel == 'WAITING')
            const _StatusBanner(
              color: Color(0xFFFEF3C7),
              icon: Icons.schedule_rounded,
              iconColor: Color(0xFFD97706),
              text: '상담원 연결을 기다리고 있습니다...',
            )
          else if (isCompleted)
            const _StatusBanner(
              color: Color(0xFFF3F4F6),
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.textSecondary,
              text: '상담이 종료되었습니다.',
            ),

          // 메시지 목록
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '메시지를 불러오지 못했습니다.\n$e',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const _EmptyChat();
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
                        ? _OutboundBubble(
                            text: msg.isImage ? null : msg.message,
                            imageUrl: msg.imageUrl,
                            timestamp: msg.timeLabel,
                          )
                        : _InboundBubble(
                            text: msg.isImage ? null : msg.message,
                            imageUrl: msg.imageUrl,
                            timestamp: msg.timeLabel,
                          );
                  },
                );
              },
            ),
          ),

          // 입력 바 (종료된 경우 비활성)
          _MessageInputBar(
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

// ─────────────────────────────────────────────────────────────────────────────
// 방 상태 스트림 Provider (고객 전용)
// ─────────────────────────────────────────────────────────────────────────────

final _roomStatusProvider =
    StreamProvider.family.autoDispose<String, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).streamRoomStatus(roomId);
});

// ─────────────────────────────────────────────────────────────────────────────
// 서브 위젯들
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: AppColors.textHint,
          ),
          SizedBox(height: 12),
          Text(
            '궁금한 점을 자유롭게 문의하세요.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _HeadsetAvatar extends StatelessWidget {
  const _HeadsetAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFDCEAFF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.headset_mic_rounded,
        size: size * 0.52,
        color: AppColors.primary,
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _InboundBubble extends StatelessWidget {
  const _InboundBubble({this.text, this.imageUrl, this.timestamp});

  final String? text;
  final String? imageUrl;
  final String? timestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _HeadsetAvatar(size: 34),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  _ChatImageBubble(
                    imageUrl: imageUrl!,
                    isOutbound: false,
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.65,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      text ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                        height: 1.55,
                      ),
                    ),
                  ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    timestamp!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB0B7C3),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutboundBubble extends StatelessWidget {
  const _OutboundBubble({this.text, this.imageUrl, this.timestamp});

  final String? text;
  final String? imageUrl;
  final String? timestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (imageUrl != null)
                  _ChatImageBubble(
                    imageUrl: imageUrl!,
                    isOutbound: true,
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.65,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      text ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.55,
                      ),
                    ),
                  ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    timestamp!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB0B7C3),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 채팅 이미지 버블 (탭하면 전체화면 뷰어)
class _ChatImageBubble extends StatelessWidget {
  const _ChatImageBubble({
    required this.imageUrl,
    required this.isOutbound,
  });

  final String imageUrl;
  final bool isOutbound;

  @override
  Widget build(BuildContext context) {
    final radius = isOutbound
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: ClipRRect(
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.65,
            maxHeight: 280,
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                width: 200,
                height: 150,
                color: const Color(0xFFF3F4F6),
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              width: 200,
              height: 120,
              color: const Color(0xFFF3F4F6),
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_outlined,
                color: AppColors.textHint,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }
}

class _FullscreenImageViewer extends StatelessWidget {
  const _FullscreenImageViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.onImagePick,
    this.disabled = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onSend;
  final VoidCallback? onImagePick;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.paddingOf(context).bottom + 10,
      ),
      child: Row(
        children: [
          // 이미지 첨부 버튼
          GestureDetector(
            onTap: disabled ? null : onImagePick,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: disabled
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_outlined,
                size: 20,
                color: disabled ? AppColors.textHint : AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: disabled
                    ? const Color(0xFFF9FAFB)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !disabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend?.call(),
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: disabled ? '상담이 종료되었습니다.' : '메시지를 입력하세요...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0B7C3),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: disabled ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: disabled
                    ? const Color(0xFFD1D5DB)
                    : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: disabled
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
