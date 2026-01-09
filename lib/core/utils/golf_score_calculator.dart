import 'dart:math';

/// 골프 지수 계산 결과 모델
class GolfScoreResult {
  final int score; // 0~100점
  final String status; // 'perfect', 'good', 'soso', 'bad', 'worst'
  final String summary; // 한 줄 요약 (헤드라인)
  final String windAdvice; // 바람 조언
  final String rainAdvice; // 강수 조언
  final String tempAdvice; // 기온/체감온도 조언
  final String? fogAdvice; // 안개 조언 (없으면 null)

  const GolfScoreResult({
    required this.score,
    required this.status,
    required this.summary,
    required this.windAdvice,
    required this.rainAdvice,
    required this.tempAdvice,
    this.fogAdvice,
  });
}

/// Advanced Golf Score Calculator
/// 기획서 v1.1 반영: 체감온도, 안개, 세분화된 풍속/강수 적용
class GolfScoreCalculator {
  /// 메인 계산 함수
  /// [windSpeed]: 풍속 (m/s)
  /// [rainAmount]: 시간당 강수량 (mm)
  /// [temperature]: 기온 (°C)
  /// [humidity]: 습도 (%) - 안개 예측용
  /// [visibility]: 시정 거리 (m) - 안개 예측용 (API 제공 시)
  static GolfScoreResult calculate({
    required double windSpeed,
    required double rainAmount,
    required double temperature,
    double humidity = 50.0,
    double visibility = 10000.0,
  }) {
    // 1. 체감 온도 계산 (Jagur formula 간소화: 바람 1m/s당 약 0.7~1도 체감 하락)
    // 겨울철 골프에 매우 중요한 요소
    double sensibleTemp = temperature - (windSpeed * 0.7);

    // 2. 페널티 계산
    int windPenalty = _calculateWindPenalty(windSpeed);
    int rainPenalty = _calculateRainPenalty(rainAmount);
    int tempPenalty = _calculateTempPenalty(sensibleTemp);
    int fogPenalty = _calculateFogPenalty(humidity, visibility);

    // 3. 최종 점수 (0점 미만 방지)
    int finalScore = max(
      0,
      100 - windPenalty - rainPenalty - tempPenalty - fogPenalty,
    );

    // 4. 상태 및 멘트 생성
    String status = _determineStatus(finalScore);
    String summary = _generateSummary(
      finalScore,
      windPenalty,
      rainPenalty,
      tempPenalty,
    );

    return GolfScoreResult(
      score: finalScore,
      status: status,
      summary: summary,
      windAdvice: _getWindAdvice(windSpeed),
      rainAdvice: _getRainAdvice(rainAmount),
      tempAdvice: _getTempAdvice(sensibleTemp, temperature),
      fogAdvice: _getFogAdvice(humidity, visibility),
    );
  }

  // --- 내부 계산 로직 ---

  static String _determineStatus(int score) {
    if (score >= 90) return 'perfect';
    if (score >= 80) return 'good';
    if (score >= 60) return 'soso';
    if (score >= 40) return 'bad';
    return 'worst';
  }

  static String _generateSummary(int score, int wp, int rp, int tp) {
    if (rp >= 40) return '☔️ 우천으로 라운딩이 힘들 수 있어요.';
    if (wp >= 30) return '💨 강풍 주의! 스코어 관리가 관건입니다.';
    if (score >= 90) return '⛳️ 핑계 댈 게 없는 완벽한 날씨!';
    if (score >= 80) return '🏌️ 라베 도전하기 딱 좋은 날입니다.';
    if (score <= 40) return '🏠 오늘은 집에서 쉬는 게 이득일지도...';
    return '🙂 무난한 날씨, 전략적인 플레이가 필요해요.';
  }

  // 바람 감점 (5단계 세분화)
  static int _calculateWindPenalty(double w) {
    if (w <= 2) return 0; // 고요
    if (w <= 5) return 5; // 산들 (쾌적)
    if (w <= 8) return 15; // 흔들 (약간 방해)
    if (w <= 11) return 30; // 강풍 (방해 심함)
    return 50; // 악천후
  }

  // 강수 감점 (4단계 세분화)
  static int _calculateRainPenalty(double r) {
    if (r <= 0) return 0;
    if (r <= 1) return 10; // 이슬비
    if (r <= 4) return 25; // 보통 비
    if (r <= 9) return 40; // 꽤 오는 비
    return 60; // 호우
  }

  // 기온 감점 (체감온도 기준)
  static int _calculateTempPenalty(double t) {
    if (t >= 15 && t <= 25) return 0; // Golden Zone
    if (t >= 10 && t < 15) return 5; // 약간 쌀쌀
    if (t > 25 && t <= 30) return 5; // 약간 더움
    if (t >= 5 && t < 10) return 10; // 추움
    if (t > 30 && t <= 33) return 15; // 더움
    if (t < 5 || t > 33) return 30; // 혹한/혹서
    return 10;
  }

  // 안개 감점
  static int _calculateFogPenalty(double humidity, double visibility) {
    // 습도가 높고 시야가 좁으면 안개 가능성 높음
    if (visibility < 500 || humidity >= 95) return 15;
    if (humidity >= 85) return 5;
    return 0;
  }

  // --- 멘트 생성 로직 (상세) ---

  static String _getWindAdvice(double w) {
    if (w <= 2) return '🚩 깃대가 멈춰 있습니다. 핀을 바로 보고 쏘세요!';
    if (w <= 5) return '🍃 기분 좋은 산들바람입니다. 평소 거리대로 공략하세요.';
    if (w <= 8) return '🚩 깃발이 펄럭입니다. 맞바람 시 한 클럽 넉넉히 잡으세요.';
    if (w <= 11) return '🧢 모자 조심! 탄도를 낮게 깔아치는(펀치샷)게 유리합니다.';
    return '💨 공이 휠 정도로 바람이 셉니다. 안전에 유의하며 플레이하세요.';
  }

  static String _getRainAdvice(double r) {
    if (r <= 0) return '☀️ 비 걱정 없는 맑은 하늘입니다.';
    if (r <= 1) return '🌂 부슬비가 내립니다. 방수 모자와 여분 장갑을 챙기세요.';
    if (r <= 4) return '🌧 옷이 젖을 수 있습니다. 우비를 입고 플레이하세요.';
    if (r <= 9) return '☔️ 비가 꽤 옵니다. 그립이 미끄러우니 수건 필수!';
    return '⛈ 라운딩이 어려울 수 있습니다. 골프장 휴장 여부를 확인하세요.';
  }

  static String _getTempAdvice(double sensible, double actual) {
    if (sensible < 5) return '❄️ 체감온도 영하권! 핫팩, 귀마개, 넥워머 풀장착 필수.';
    if (sensible > 30) return '🔥 찜통 더위입니다. 얼음물과 우산으로 열사병 대비하세요.';
    if (sensible >= 15 && sensible <= 25) return '✨ 춥지도 덥지도 않은 축복받은 날씨입니다.';

    // 바람 때문에 더 춥게 느껴질 때
    if (sensible < actual - 3) return '🌬 바람 때문에 실제보다 훨씬 쌀쌀합니다. 겉옷 챙기세요.';

    return '🌡 기온에 맞는 편안한 복장을 준비하세요.';
  }

  static String? _getFogAdvice(double h, double v) {
    if (v < 200 || h >= 95) return '🌫 한 치 앞도 안 보입니다. 컬러볼 필수, 캐디 조언을 따르세요.';
    if (h >= 85) return '🌫 안개가 낄 수 있습니다. 시야 확보에 유의하세요.';
    return null;
  }
}
