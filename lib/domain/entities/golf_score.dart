/// 계산된 골프 점수 및 상태
class GolfScore {
  final int score; // 0~100점
  final String status; // 'good', 'soso', 'bad'
  final String message; // 한 줄 평가 메시지
  final double windSpeed;
  final double rainAmount;
  final double temperature;

  const GolfScore({
    required this.score,
    required this.status,
    required this.message,
    required this.windSpeed,
    required this.rainAmount,
    required this.temperature,
  });

  /// 점수가 좋은가? (80점 이상)
  bool get isGood => score >= 80;

  /// 점수가 보통인가? (50~79점)
  bool get isSoso => score >= 50 && score < 80;

  /// 점수가 나쁜가? (49점 이하)
  bool get isBad => score < 50;
}
