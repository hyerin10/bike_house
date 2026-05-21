import 'package:flutter/material.dart';

/// 바이크 호환성을 강조하는 초록색 배너
class CompatibilityBanner extends StatelessWidget {
  const CompatibilityBanner({super.key, required this.bikeName});

  final String bikeName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAFAF1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '내 바이크와 호환됩니다',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF16A34A),
                    ),
              ),
              const SizedBox(height: 1),
              Text(
                bikeName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF22C55E),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
