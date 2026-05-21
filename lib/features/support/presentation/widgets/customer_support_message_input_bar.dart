import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

class CustomerSupportMessageInputBar extends StatelessWidget {
  const CustomerSupportMessageInputBar({
    super.key,
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
