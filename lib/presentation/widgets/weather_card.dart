import 'package:flutter/material.dart';
import '../../core/constants/text_styles.dart';

/// 날씨 정보를 담는 카드 컴포넌트
class WeatherCard extends StatelessWidget {
  final String title;
  final Widget child;

  const WeatherCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyles.heading2()),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
