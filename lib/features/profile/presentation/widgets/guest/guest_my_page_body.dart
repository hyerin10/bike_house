import 'package:flutter/material.dart';

import 'package:bike_house/features/profile/presentation/widgets/guest/login_prompt_card.dart';
import 'package:bike_house/features/profile/presentation/widgets/guest/locked_features_section.dart';

class GuestMyPageBody extends StatelessWidget {
  const GuestMyPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('마이페이지', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            '오토바이 부속품 주문과 배송을 조회해 보세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const LoginPromptCard(),
          const SizedBox(height: 28),
          const LockedFeaturesSection(),
        ],
      ),
    );
  }
}
