import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_house/features/chat/data/chat_repository.dart';
import 'package:bike_house/features/chat/domain/chat_models.dart';
import 'package:bike_house/features/admin/presentation/admin_chat_room_screen.dart';

Future<void> acceptAdminChatAndOpenRoom(
  BuildContext context,
  WidgetRef ref,
  ChatRoom room,
) async {
  final repo = ref.read(chatRepositoryProvider);
  try {
    final accepted = await repo.acceptChat(room.id);
    if (!context.mounted) return;
    if (accepted) {
      openAdminChatRoom(context, room);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 다른 관리자가 상담을 시작했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('오류: $e')),
    );
  }
}

void openAdminChatRoom(BuildContext context, ChatRoom room) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AdminChatRoomScreen(
        roomId: room.id,
        customerName:
            room.customerName.isNotEmpty ? room.customerName : '고객',
        isCompletedInitially: room.status.isCompleted,
      ),
    ),
  );
}
