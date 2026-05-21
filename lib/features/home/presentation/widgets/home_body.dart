import 'package:flutter/material.dart';

import 'package:bike_house/features/home/presentation/widgets/home_banner_section.dart';
import 'package:bike_house/features/home/presentation/widgets/home_popular_parts_section.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          HomeBannerSection(),
          SizedBox(height: 24),
          HomePopularPartsSection(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
