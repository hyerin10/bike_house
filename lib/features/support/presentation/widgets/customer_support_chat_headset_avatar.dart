import 'package:flutter/material.dart';

import 'package:bike_house/core/theme/app_theme.dart';

/// 고객센터 앱바·수신 말풍선에 쓰이는 헤드셋 아바타입니다.
class CustomerSupportChatHeadsetAvatar extends StatelessWidget {
  const CustomerSupportChatHeadsetAvatar({super.key, required this.size});

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
