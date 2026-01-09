import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../domain/entities/golf_score.dart';

/// 골프 점수 표시 위젯
/// Count-up 애니메이션 포함
class ScoreDisplay extends StatefulWidget {
  final GolfScore score;

  const ScoreDisplay({super.key, required this.score});

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 설정 (1.5초)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 0에서 실제 점수까지 카운트업
    _animation = IntTween(
      begin: 0,
      end: widget.score.score,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 점수에 따른 색상
    Color scoreColor;
    String statusEmoji;

    if (widget.score.isGood) {
      scoreColor = AppColors.signalGreen;
      statusEmoji = '⛳️';
    } else if (widget.score.isSoso) {
      scoreColor = AppColors.signalYellow;
      statusEmoji = '🏌️';
    } else {
      scoreColor = AppColors.signalRed;
      statusEmoji = '☔️';
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 이모지 아이콘
            Text(statusEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),

            // 점수 (애니메이션)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '${_animation.value}',
                  style: TextStyles.displayXL(color: scoreColor),
                );
              },
            ),
            const SizedBox(height: 8),

            // 메시지
            Text(
              widget.score.message,
              style: TextStyles.heading2(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
