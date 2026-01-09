/// 계산된 골프 점수 및 상태
class GolfScore {
  final int score; // 0~100점
  final String status; // 'perfect', 'good', 'soso', 'bad', 'worst'
  final String summary; // 한 줄 요약 (헤드라인)
  final String windAdvice; // 바람 조언
  final String rainAdvice; // 강수 조언
  final String tempAdvice; // 기온/체감온도 조언
  final String? fogAdvice; // 안개 조언 (없으면 null)
  final double windSpeed;
  final double rainAmount;
  final double temperature;

  const GolfScore({
    required this.score,
    required this.status,
    required this.summary,
    required this.windAdvice,
    required this.rainAdvice,
    required this.tempAdvice,
    this.fogAdvice,
    required this.windSpeed,
    required this.rainAmount,
    required this.temperature,
  });

  /// 점수가 아주 좋은가? (90점 이상)
  bool get isPerfect => status == 'perfect';

  /// 점수가 좋은가? (80점 이상)
  bool get isGood => status == 'good' || status == 'perfect';

  /// 점수가 보통인가? (60~79점)
  bool get isSoso => status == 'soso';

  /// 점수가 나쁜가? (59점 이하)
  bool get isBad => status == 'bad' || status == 'worst';
}
