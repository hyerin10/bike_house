import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';
import 'package:bike_house/features/support/presentation/widgets/customer_support_chat_headset_avatar.dart';

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

class CustomerSupportChatInboundBubble extends StatelessWidget {
  const CustomerSupportChatInboundBubble({
    super.key,
    this.text,
    this.imageUrl,
    this.timestamp,
  });

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
          const CustomerSupportChatHeadsetAvatar(size: 34),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  CustomerSupportChatImageBubble(
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

class CustomerSupportChatOutboundBubble extends StatelessWidget {
  const CustomerSupportChatOutboundBubble({
    super.key,
    this.text,
    this.imageUrl,
    this.timestamp,
  });

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
                  CustomerSupportChatImageBubble(
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

/// 채팅 이미지 버블 (탭하면 전체화면 뷰어)
class CustomerSupportChatImageBubble extends StatelessWidget {
  const CustomerSupportChatImageBubble({
    super.key,
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
      MaterialPageRoute<void>(
        builder: (_) => CustomerSupportChatFullscreenImageViewer(
          imageUrl: imageUrl,
        ),
      ),
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
