import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 로딩 상태의 Skeleton UI
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({super.key});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 점수 카드 스켈레톤
          _buildSkeletonCard(height: 200),
          const SizedBox(height: 24),

          // 날씨 정보 스켈레톤
          _buildSkeletonCard(height: 120),
          const SizedBox(height: 16),

          // 시간별 날씨 스켈레톤
          _buildSkeletonBox(width: 150, height: 24),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildSkeletonCard(
                  width: 100,
                  height: 140,
                  margin: const EdgeInsets.only(right: 8),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({
    double? width,
    required double height,
    EdgeInsets? margin,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            color: AppColors.skeleton.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonBox({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.skeleton.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
