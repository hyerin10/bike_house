import 'package:flutter/material.dart';

class HomeBannerSection extends StatelessWidget {
  const HomeBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A6BFF), Color(0xFF4D8FFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bike_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              '오늘도 안전하게, 즐거운 라이딩 하세요!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
