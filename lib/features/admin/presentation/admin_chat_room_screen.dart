import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 채팅 메시지 모델
// ─────────────────────────────────────────────────────────────────────────────

enum _MessageType { system, customer, admin }

class _ChatMessage {
  const _ChatMessage({
    required this.type,
    required this.text,
    this.time,
  });

  final _MessageType type;
  final String text;
  final String? time;
}

// ─────────────────────────────────────────────────────────────────────────────
// 관리자 1:1 상담 채팅 화면
// ─────────────────────────────────────────────────────────────────────────────

class AdminChatRoomScreen extends StatefulWidget {
  const AdminChatRoomScreen({
    super.key,
    this.customerName = '홍길동',
    this.customerEmail = 'hong@example.com',
    this.productTitle = '혼다 PCX 2019년식 윈도우 ...',
    this.productImageUrl,
  });

  final String customerName;
  final String customerEmail;
  final String productTitle;
  final String? productImageUrl;

  @override
  State<AdminChatRoomScreen> createState() => _AdminChatRoomScreenState();
}

class _AdminChatRoomScreenState extends State<AdminChatRoomScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      type: _MessageType.system,
      text: '상담이 시작되었습니다.',
    ),
    _ChatMessage(
      type: _MessageType.customer,
      text: '안녕하세요, 혼다 PCX 2019년식에 맞는 윈도우 스크린 재고가 있나요?',
      time: '오전 12:06',
    ),
    _ChatMessage(
      type: _MessageType.customer,
      text: '가능하면 스모크 틴트 제품으로 부탁드립니다.',
      time: '오전 12:07',
    ),
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showEndSessionDialog() {
    showDialog<void>(
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
          '상담을 종료하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.maybePop(context);
            },
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _InquiryInfoBar(
            productTitle: widget.productTitle,
            productImageUrl: widget.productImageUrl,
          ),
          Expanded(child: _buildChatBody()),
          _BottomInputBar(controller: _inputController),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
          Text(
            widget.customerEmail,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _showEndSessionDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildChatBody() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return switch (msg.type) {
          _MessageType.system => _SystemMessageBubble(text: msg.text),
          _MessageType.customer => _CustomerMessageBubble(
              text: msg.text,
              time: msg.time,
            ),
          _MessageType.admin => _AdminMessageBubble(
              text: msg.text,
              time: msg.time,
            ),
        };
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 문의 상품 정보 바
// ─────────────────────────────────────────────────────────────────────────────

class _InquiryInfoBar extends StatelessWidget {
  const _InquiryInfoBar({
    required this.productTitle,
    this.productImageUrl,
  });

  final String productTitle;
  final String? productImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: productImageUrl != null
                ? Image.network(
                    productImageUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ProductImagePlaceholder(),
                  )
                : _ProductImagePlaceholder(),
          ),
          const SizedBox(width: 10),
          // 상품 정보
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '문의 상품',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    productTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 전화 버튼
          _CircleIconButton(
            onTap: () {},
            backgroundColor: AppColors.textPrimary,
            size: 36,
            child: const Icon(
              Icons.headset_mic_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.directions_bike_rounded,
        color: AppColors.textHint,
        size: 22,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 채팅 말풍선 위젯들
// ─────────────────────────────────────────────────────────────────────────────

class _SystemMessageBubble extends StatelessWidget {
  const _SystemMessageBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerMessageBubble extends StatelessWidget {
  const _CustomerMessageBubble({required this.text, this.time});

  final String text;
  final String? time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 프로필 아바타
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
          // 말풍선 + 시간
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
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
  const _AdminMessageBubble({required this.text, this.time});

  final String text;
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
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

// ─────────────────────────────────────────────────────────────────────────────
// 하단 입력 바
// ─────────────────────────────────────────────────────────────────────────────

class _BottomInputBar extends StatelessWidget {
  const _BottomInputBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomPadding),
      child: Row(
        children: [
          // 첨부 버튼
          _CircleIconButton(
            onTap: () {},
            backgroundColor: const Color(0xFFF2F3F5),
            size: 40,
            child: const Icon(
              Icons.attach_file_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          // 이미지 버튼
          _CircleIconButton(
            onTap: () {},
            backgroundColor: const Color(0xFFF2F3F5),
            size: 40,
            child: const Icon(
              Icons.image_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          // 텍스트 입력 필드
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
          // 전송 버튼
          _CircleIconButton(
            onTap: () {},
            backgroundColor: const Color(0xFFF2F3F5),
            size: 40,
            child: const Icon(
              Icons.send_rounded,
              size: 20,
              color: AppColors.textSecondary,
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
    this.size = 36,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}
