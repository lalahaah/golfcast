import 'dart:math';

/// 골프 지수 계산 결과 모델
class GolfScoreResult {
  final int score;
  final String status;
  final String summary;
  final String windAdvice;
  final String rainAdvice;
  final String tempAdvice;
  final String? fogAdvice;

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

/// Advanced Golf Score Calculator V2.2 (Safety First Edition)
/// 개선사항: 점수보다 '생존/안전'과 직결된 극한 날씨(혹한/폭염/폭우)를 최우선 순위로 체크하여 멘트 생성
class GolfScoreCalculator {
  static GolfScoreResult calculate({
    required double windSpeed,
    required double rainAmount,
    required double temperature,
    double humidity = 50.0,
    double visibility = 10000.0,
  }) {
    // 1. 체감 온도 계산
    double sensibleTemp = temperature - (windSpeed * 0.7);

    // 2. 페널티 계산 (혹한/폭염 페널티 강화)
    int windPenalty = _calculateWindPenalty(windSpeed);
    int rainPenalty = _calculateRainPenalty(rainAmount);
    int tempPenalty = _calculateTempPenalty(sensibleTemp);
    int fogPenalty = _calculateFogPenalty(humidity, visibility);

    // 3. 최종 점수 (최소 0점)
    int finalScore = max(
      0,
      100 - windPenalty - rainPenalty - tempPenalty - fogPenalty,
    );

    // 4. 상태 결정
    String status = _determineStatus(finalScore);

    // V2.2: Safety First 로직 적용 (점수 구간보다 극한 조건을 먼저 체크)
    String summary = _generateSafetyFirstSummary(
      score: finalScore,
      sensibleTemp: sensibleTemp,
      wp: windPenalty,
      rp: rainPenalty,
      tp: tempPenalty,
      fp: fogPenalty,
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
    if (score >= 70) return 'fair';
    if (score >= 50) return 'caution'; // 기준 조정 (55->50)
    if (score >= 30) return 'bad'; // 기준 조정 (40->30)
    return 'worst';
  }

  /// V2.2: 안전 우선 요약 멘트 생성기
  /// 로직 순서: 절대적 위험 요소(Safety Check) -> 점수 구간별 멘트(Score Check)
  static String _generateSafetyFirstSummary({
    required int score,
    required double sensibleTemp,
    required int wp,
    required int rp,
    required int tp,
    required int fp,
  }) {
    // [Priority 0] 생존/안전 경고 (점수와 무관하게 출력)
    // 아무리 바람이 안 불어도 영하 5도면 골프 치기 힘듭니다.
    if (sensibleTemp <= -5) {
      return '🥶 혹한기 경보! 부상 위험이 큽니다. 옷 단단히 입으세요.';
    }
    if (sensibleTemp >= 35) {
      return '🔥 야외 활동 자제! 살인적인 폭염입니다.';
    }
    if (rp >= 50) {
      return '⛈ 폭우가 쏟아집니다. 라운딩이 불가능해 보입니다.';
    }
    if (wp >= 40) {
      return '🌪 태풍급 강풍! 서 있기도 힘든 날씨입니다.';
    }

    // [Priority 1] 주요 방해 요소 (Bad/Caution 구간일 때 명확한 원인 지목)
    if (score < 70) {
      // 비가 올 때
      if (rp >= 20) {
        if (rp >= 40) return '🌧 비가 많이 옵니다. 우비 없으면 플레이가 힘듭니다.';
        return '☔️ 비가 변수네요. 그립과 장갑 관리가 스코어를 가릅니다.';
      }
      // 바람이 불 때
      if (wp >= 20) {
        if (wp >= 30) return '💨 강풍 주의! 공이 멋대로 날아다닐 수 있습니다.';
        return '🍃 바람이 꽤 셉니다. 한두 클럽 넉넉하게 잡으세요.';
      }
      // 안개가 꼈을 때
      if (fp >= 15) return '🌫 곰탕(짙은 안개)입니다. 캐디님 방향 지시를 믿으세요.';

      // 춥거나 더울 때 (극한까진 아니지만 힘든 날씨)
      if (tp >= 15) {
        // 페널티가 있다는 건 불편하다는 뜻
        if (sensibleTemp <= 0) return '❄️ 체감 영하권입니다. 핫팩과 귀마개 필수!';
        if (sensibleTemp <= 5) return '😨 손발이 시린 추위입니다. 보온에 신경 쓰세요.';
        if (sensibleTemp >= 30) return '☀️ 꽤 덥습니다. 얼음물 챙기시고 그늘을 찾으세요.';
      }
    }

    // [Priority 2] 무난하거나 좋은 날씨 (점수 구간별 뉘앙스)
    // 위에서 위험 요소를 다 걸러냈으므로, 여기서는 긍정/중립적 멘트 제공

    // 90점 이상
    if (score >= 90) return '⛳️ 천국 같은 날씨! 오늘 라베 못하면 날씨 탓 못해요 😉';

    // 80점 이상
    if (score >= 80) {
      if (sensibleTemp < 10) return '🏌️ 날씨는 좋은데 공기는 차갑습니다. 겉옷 챙기세요.';
      if (wp > 0) return '🏌️ 쾌적하지만 바람 계산은 필요합니다.';
      return '🏌️ 핑계 댈 것 없는 훌륭한 날씨입니다. 굿샷 하세요!';
    }

    // 70점 이상 (Fair)
    if (score >= 70) {
      if (sensibleTemp < 10) return '🌡 약간 쌀쌀하네요. 가벼운 겉옷이나 조끼 추천합니다.';
      if (sensibleTemp > 25) return '🌡 조금 덥습니다. 시원한 물 자주 마시세요.';
      if (wp > 0) return '🍃 바람이 살짝 불지만 플레이에 지장은 없습니다.';
      if (rp > 0) return '🌂 이슬비가 살짝 스칩니다. 모자만 쓰면 괜찮아요.';
      return '🙂 전반적으로 무난합니다. 평소 실력 발휘해 보세요!';
    }

    // 그 외 (혹시 모를 예외 처리)
    return '😐 날씨 변수가 조금 있습니다. 침착하게 플레이하세요.';
  }

  // --- 감점 계산 로직 (기존 대비 극한 날씨 페널티 강화) ---
  static int _calculateWindPenalty(double w) {
    if (w <= 2) return 0;
    if (w <= 5) return 5;
    if (w <= 8) return 15;
    if (w <= 11) return 30;
    return 50; // 12m/s 이상은 플레이 불가 수준
  }

  static int _calculateRainPenalty(double r) {
    if (r <= 0) return 0;
    if (r <= 1) return 10;
    if (r <= 4) return 25;
    if (r <= 9) return 40;
    return 60; // 10mm 이상은 폭우
  }

  static int _calculateTempPenalty(double t) {
    // Best Zone (18~24도)
    if (t >= 18 && t <= 24) return 0;
    // Good Zone
    if (t >= 15 && t < 18) return 5;
    if (t > 24 && t <= 28) return 5;
    // Caution Zone
    if (t >= 8 && t < 15) return 15; // 쌀쌀함 페널티 상향 (10->15)
    if (t > 28 && t <= 32) return 15; // 더움 페널티 상향 (10->15)
    // Warning Zone
    if (t >= 0 && t < 8) return 30; // 꽤 추움
    if (t > 32 && t <= 35) return 30; // 폭염 주의
    // Danger Zone (신설)
    if (t < 0 || t > 35) return 50; // 영하/살인적 더위는 50점 감점 (Fair 진입 불가)

    return 10;
  }

  static int _calculateFogPenalty(double h, double v) {
    if (v < 200 || h >= 98) return 20;
    if (h >= 90) return 10;
    return 0;
  }

  // --- Advice 로직 (동일 유지) ---
  static String _getWindAdvice(double w) {
    if (w <= 2) return '🚩 깃대가 멈춰 있습니다. 핀을 바로 보고 쏘세요!';
    if (w <= 5) return '🍃 살랑바람입니다. 평소 거리대로 편하게 치세요.';
    if (w <= 8) return '🚩 깃발이 펄럭입니다. 맞바람 땐 두 클럽까지 더 보세요.';
    if (w <= 11) return '🧢 모자 꽉 쓰세요! 낮게 깔아치는 펀치샷이 필수입니다.';
    return '🌪 서 있기도 힘든 바람! 욕심버리고 생존 골프 하세요.';
  }

  static String _getRainAdvice(double r) {
    if (r <= 0) return '☀️ 비 걱정 없는 쾌청한 하늘입니다.';
    if (r <= 1) return '🌂 이슬비가 옵니다. 방수 모자와 수건을 꼭 챙기세요.';
    if (r <= 4) return '🌧 옷이 젖는 비입니다. 우비 입고 여분 장갑 많이 챙기세요.';
    if (r <= 9) return '☔️ 비가 꽤 옵니다. 그린이 느리니 퍼팅은 과감하게 때리세요!';
    return '⛈ 라운딩이 불가능해 보입니다. 골프장에 휴장 여부 전화해보세요.';
  }

  static String _getTempAdvice(double sensible, double actual) {
    if (sensible < 0) return '❄️ 체감 영하! 핫팩, 귀마개, 넥워머 없으면 얼어 죽습니다.';
    if (sensible < 8) return '🌬 많이 춥습니다. 얇은 옷을 여러 겹 껴입으세요 (Layering).';
    if (sensible >= 8 && sensible < 15) return '🧥 쌀쌀합니다. 몸이 굳지 않게 스트레칭 필수!';
    if (sensible >= 15 && sensible <= 25) return '✨ 춥지도 덥지도 않은 축복받은 기온입니다.';
    if (sensible > 25 && sensible <= 30) {
      return '😅 땀이 좀 납니다. 얼음물 챙기시고 수분 섭취 자주 하세요.';
    }
    if (sensible > 30) return '🔥 찜통 더위! 우산으로 해 가리고 카트 그늘 이용하세요.';
    return '🌡 기온에 맞는 편안한 복장을 준비하세요.';
  }

  static String? _getFogAdvice(double h, double v) {
    if (v < 200 || h >= 95) return '🌫 한 치 앞도 안 보입니다(곰탕). 컬러볼 쓰시고 캐디 방향을 믿으세요.';
    if (h >= 85) return '🌫 안개가 낄 수 있어요. 티샷 방향 설정에 신중하세요.';
    return null;
  }
}
