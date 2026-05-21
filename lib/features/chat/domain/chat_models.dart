/// 채팅방 상태
enum ChatRoomStatus { waiting, active, completed }

extension ChatRoomStatusX on ChatRoomStatus {
  static ChatRoomStatus fromString(String value) => switch (value) {
        'WAITING' => ChatRoomStatus.waiting,
        'ACTIVE' => ChatRoomStatus.active,
        _ => ChatRoomStatus.completed,
      };

  String get value => switch (this) {
        ChatRoomStatus.waiting => 'WAITING',
        ChatRoomStatus.active => 'ACTIVE',
        ChatRoomStatus.completed => 'COMPLETED',
      };

  bool get isWaiting => this == ChatRoomStatus.waiting;
  bool get isActive => this == ChatRoomStatus.active;
  bool get isCompleted => this == ChatRoomStatus.completed;
}

/// 관리자 대시보드용 채팅방 요약 모델
class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.customerId,
    required this.customerName,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final ChatRoomStatus status;
  final DateTime createdAt;
  final String customerId;
  final String customerName;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      status: ChatRoomStatusX.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '고객',
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
    );
  }

  /// 마지막 메시지 시간을 "n분 전" 형태로 표시
  String get timeAgoLabel {
    if (lastMessageAt == null) return '';
    final diff = DateTime.now().toUtc().difference(lastMessageAt!.toUtc());
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

/// 개별 채팅 메시지 모델
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  /// 이미지 메시지인 경우 Supabase Storage URL
  final String? imageUrl;

  bool get isImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
    );
  }

  /// HH:MM (오전/오후) 형태의 시간 레이블
  String get timeLabel {
    final local = createdAt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$period $h:$minute';
  }
}
