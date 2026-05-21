import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/chat/domain/chat_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 관리자 1:1 상담 채팅 화면
// ─────────────────────────────────────────────────────────────────────────────

class AdminChatRoomScreen extends ConsumerStatefulWidget {
  const AdminChatRoomScreen({
    super.key,
    required this.roomId,
    this.customerName = '고객',
    this.productImageUrl,
    this.isCompletedInitially = false,
  });

  final String roomId;
  final String customerName;
  final String? productImageUrl;
  /// 목록에서 넘겨주는 초기 완료 여부 — 스트림 로딩 전 버튼 깜빡임 방지용
  final bool isCompletedInitially;

  @override
  ConsumerState<AdminChatRoomScreen> createState() =>
      _AdminChatRoomScreenState();
}

class _AdminChatRoomScreenState extends ConsumerState<AdminChatRoomScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(widget.roomId, text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전송 실패: $e')),
      );
    }
  }

  Future<void> _sendImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return;
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendImageMessage(widget.roomId, file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 전송 실패: $e')),
      );
    }
  }

  void _showImageSourceSheet() {
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
                  backgroundColor: Color(0xFFF0F1F5),
                  child: Icon(Icons.photo_library_outlined,
                      color: AppColors.textPrimary),
                ),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _sendImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF0F1F5),
                  child: Icon(Icons.camera_alt_outlined,
                      color: AppColors.textPrimary),
                ),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _sendImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _showEndSessionDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '상담 종료',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          '상담을 종료하시겠습니까?\n종료 후에는 메시지를 보낼 수 없습니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '종료',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(chatRepositoryProvider).endChat(widget.roomId);
        if (mounted) Navigator.maybePop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('종료 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(chatMessagesProvider(widget.roomId));
    final statusAsync = ref.watch(_adminRoomStatusProvider(widget.roomId));
    // 스트림 로딩 중에는 초기값(isCompletedInitially) 사용 → 버튼 깜빡임 없음
    final isCompleted = statusAsync.when(
      data: (s) => s == 'COMPLETED',
      loading: () => widget.isCompletedInitially,
      error: (_, __) => widget.isCompletedInitially,
    );

    // 새 메시지 도착 시 스크롤 아래로
    ref.listen(chatMessagesProvider(widget.roomId), (_, next) {
      next.whenData((_) => _scrollToBottom());
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(isCompleted: isCompleted),
      body: Column(
        children: [
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
              data: (messages) => _buildChatBody(messages),
            ),
          ),
          _BottomInputBar(
            controller: _inputController,
            onSend: _sendMessage,
            onImagePick: _showImageSourceSheet,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({required bool isCompleted}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: _CircleIconButton(
          onTap: () => Navigator.maybePop(context),
          backgroundColor: const Color(0xFFF2F3F5),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.customerName}님과 상담 중',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 1),
          const Text(
            '바이크하우스 고객센터',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        if (!isCompleted)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showEndSessionDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8523A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '상담 종료',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatBody(List<ChatMessage> messages) {
    final myUid = Supabase.instance.client.auth.currentUser?.id ?? '';

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = msg.senderId == myUid;
        return isMe
            ? _AdminMessageBubble(
                text: msg.isImage ? null : msg.message,
                imageUrl: msg.imageUrl,
                time: msg.timeLabel,
              )
            : _CustomerMessageBubble(
                text: msg.isImage ? null : msg.message,
                imageUrl: msg.imageUrl,
                time: msg.timeLabel,
              );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 채팅 말풍선 위젯들
// ─────────────────────────────────────────────────────────────────────────────

class _CustomerMessageBubble extends StatelessWidget {
  const _CustomerMessageBubble({this.text, this.imageUrl, this.time});

  final String? text;
  final String? imageUrl;
  final String? time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, bottom: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.textHint,
              size: 18,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  _AdminChatImageBubble(imageUrl: imageUrl!, isAdmin: false)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      text ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                if (time != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    time!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _AdminMessageBubble extends StatelessWidget {
  const _AdminMessageBubble({this.text, this.imageUrl, this.time});

  final String? text;
  final String? imageUrl;
  final String? time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 48),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (imageUrl != null)
                _AdminChatImageBubble(imageUrl: imageUrl!, isAdmin: true)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    text ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              if (time != null) ...[
                const SizedBox(height: 4),
                Text(
                  time!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminChatImageBubble extends StatelessWidget {
  const _AdminChatImageBubble({
    required this.imageUrl,
    required this.isAdmin,
  });

  final String imageUrl;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final radius = isAdmin
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _AdminFullscreenImageViewer(imageUrl: imageUrl),
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.6,
            maxHeight: 260,
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                width: 180,
                height: 140,
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
              width: 180,
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
}

class _AdminFullscreenImageViewer extends StatelessWidget {
  const _AdminFullscreenImageViewer({required this.imageUrl});

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

// ─────────────────────────────────────────────────────────────────────────────
// 하단 입력 바
// ─────────────────────────────────────────────────────────────────────────────

class _BottomInputBar extends StatelessWidget {
  const _BottomInputBar({
    required this.controller,
    required this.onSend,
    this.onImagePick,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onImagePick;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomPadding),
      child: Row(
        children: [
          // 이미지 첨부 버튼
          GestureDetector(
            onTap: onImagePick,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F1F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider, width: 1.2),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            onTap: onSend,
            backgroundColor: AppColors.textPrimary,
            child: const Icon(
              Icons.send_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 공통 원형 아이콘 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final Widget child;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

// 관리자 채팅 화면에서 방 상태 구독용 (COMPLETED 감지)
final _adminRoomStatusProvider =
    StreamProvider.family.autoDispose<String, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).streamRoomStatus(roomId);
});
