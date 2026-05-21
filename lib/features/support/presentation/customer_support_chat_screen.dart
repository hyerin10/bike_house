import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_support_chat_app_bar.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_support_chat_body.dart';

/// 고객 채팅 화면
class CustomerSupportChatScreen extends ConsumerStatefulWidget {
  const CustomerSupportChatScreen({super.key, this.initialRoomId});

  /// 특정 방을 바로 열 때 사용 (상담 목록에서 진입). null 이면 getOrCreateRoom() 호출.
  final String? initialRoomId;

  @override
  ConsumerState<CustomerSupportChatScreen> createState() =>
      _CustomerSupportChatScreenState();
}

class _CustomerSupportChatScreenState
    extends ConsumerState<CustomerSupportChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static const Color _scaffoldBackground = Color(0xFFF3F4F6);

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
      builder: (sheetContext) => SafeArea(
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
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _sendImage(roomId, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _sendImage(roomId, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.initialRoomId != null) {
      final roomId = widget.initialRoomId!;
      return CustomerSupportChatBody(
        roomId: roomId,
        scrollController: _scrollController,
        inputController: _inputController,
        focusNode: _focusNode,
        onSend: () => _sendMessage(roomId),
        onScrollToBottom: _scrollToBottom,
        onImagePick: () => _showImageSourceSheet(roomId),
      );
    }

    final roomAsync = ref.watch(customerRoomIdProvider);
    return roomAsync.when(
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
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(customerRoomIdProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
      data: (roomId) {
        if (roomId == null) {
          return const Center(child: Text('채팅방을 생성할 수 없습니다.'));
        }
        return CustomerSupportChatBody(
          roomId: roomId,
          scrollController: _scrollController,
          inputController: _inputController,
          focusNode: _focusNode,
          onSend: () => _sendMessage(roomId),
          onScrollToBottom: _scrollToBottom,
          onImagePick: () => _showImageSourceSheet(roomId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBackground,
      appBar: const CustomerSupportChatAppBar(),
      body: _buildBody(),
    );
  }
}
