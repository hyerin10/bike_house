import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_support_chat_headset_avatar.dart';

/// 고객 채팅 메시지 정렬(상대방 / 나)
enum CustomerSupportChatMessageDirection {
  inbound,
  outbound,
}

extension CustomerSupportChatMessageDirectionX
    on CustomerSupportChatMessageDirection {
  bool get isOutbound => this == CustomerSupportChatMessageDirection.outbound;

  /// 텍스트·이미지 버블 공통 모서리
  BorderRadius get bubbleBorderRadius => isOutbound
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
}

const double _kBubbleMaxWidthFraction = 0.65;
const double _kImageBubbleMaxHeight = 280.0;

class CustomerSupportChatStatusBanner extends StatelessWidget {
  const CustomerSupportChatStatusBanner({
    super.key,
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

class CustomerSupportChatEmptyState extends StatelessWidget {
  const CustomerSupportChatEmptyState({super.key});

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

/// 인바운드(상담원) / 아웃바운드(고객) 채팅 한 줄
class CustomerSupportChatMessageBubble extends StatelessWidget {
  const CustomerSupportChatMessageBubble({
    super.key,
    required this.direction,
    this.text,
    this.imageUrl,
    this.timestamp,
  });

  factory CustomerSupportChatMessageBubble.inbound({
    Key? key,
    String? text,
    String? imageUrl,
    String? timestamp,
  }) {
    return CustomerSupportChatMessageBubble(
      key: key,
      direction: CustomerSupportChatMessageDirection.inbound,
      text: text,
      imageUrl: imageUrl,
      timestamp: timestamp,
    );
  }

  factory CustomerSupportChatMessageBubble.outbound({
    Key? key,
    String? text,
    String? imageUrl,
    String? timestamp,
  }) {
    return CustomerSupportChatMessageBubble(
      key: key,
      direction: CustomerSupportChatMessageDirection.outbound,
      text: text,
      imageUrl: imageUrl,
      timestamp: timestamp,
    );
  }

  final CustomerSupportChatMessageDirection direction;
  final String? text;
  final String? imageUrl;
  final String? timestamp;

  @override
  Widget build(BuildContext context) {
    final column = Flexible(
      child: Column(
        crossAxisAlignment: direction.isOutbound
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            CustomerSupportChatImageBubble(
              imageUrl: imageUrl!,
              direction: direction,
            )
          else
            _CustomerSupportChatTextBubble(
              direction: direction,
              text: text ?? '',
              maxWidth: MediaQuery.sizeOf(context).width * _kBubbleMaxWidthFraction,
            ),
          if (timestamp != null) ...[
            const SizedBox(height: 4),
            _CustomerSupportChatTimestampLabel(timestamp!),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: direction.isOutbound
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!direction.isOutbound) ...[
            const CustomerSupportChatHeadsetAvatar(size: 34),
            const SizedBox(width: 8),
          ],
          column,
        ],
      ),
    );
  }
}

class _CustomerSupportChatTextBubble extends StatelessWidget {
  const _CustomerSupportChatTextBubble({
    required this.direction,
    required this.text,
    required this.maxWidth,
  });

  final CustomerSupportChatMessageDirection direction;
  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final inbound = !direction.isOutbound;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: inbound ? AppColors.surface : AppColors.primary,
        borderRadius: direction.bubbleBorderRadius,
        border: inbound ? Border.all(color: AppColors.divider) : null,
        boxShadow: [
          BoxShadow(
            color: inbound
                ? Colors.black.withValues(alpha: 0.04)
                : AppColors.primary.withValues(alpha: 0.25),
            blurRadius: inbound ? 6 : 8,
            offset: Offset(0, inbound ? 2 : 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: inbound ? AppColors.textPrimary : Colors.white,
          height: 1.55,
        ),
      ),
    );
  }
}

class _CustomerSupportChatTimestampLabel extends StatelessWidget {
  const _CustomerSupportChatTimestampLabel(this.timestamp);

  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Text(
      timestamp,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textHint,
      ),
    );
  }
}

/// 채팅 이미지 버블 (탭하면 전체화면 뷰어)
class CustomerSupportChatImageBubble extends StatelessWidget {
  const CustomerSupportChatImageBubble({
    super.key,
    required this.imageUrl,
    required this.direction,
  });

  final String imageUrl;
  final CustomerSupportChatMessageDirection direction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: ClipRRect(
        borderRadius: direction.bubbleBorderRadius,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.sizeOf(context).width * _kBubbleMaxWidthFraction,
            maxHeight: _kImageBubbleMaxHeight,
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _ChatNetworkImagePlaceholder(
                height: 150,
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (_, __, ___) => const _ChatNetworkImagePlaceholder(
              height: 120,
              child: Icon(
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
      MaterialPageRoute<void>(
        builder: (_) => CustomerSupportChatFullscreenImageViewer(
          imageUrl: imageUrl,
        ),
      ),
    );
  }
}

class _ChatNetworkImagePlaceholder extends StatelessWidget {
  const _ChatNetworkImagePlaceholder({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: height,
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class CustomerSupportChatFullscreenImageViewer extends StatelessWidget {
  const CustomerSupportChatFullscreenImageViewer({
    super.key,
    required this.imageUrl,
  });

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
