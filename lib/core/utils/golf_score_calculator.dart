import 'dart:math';

/// 골프 지수 계산 결과
class GolfScoreResult {
  final int score; // 0~100점
  final String status; // 'good', 'soso', 'bad'
  final String message; // 한 줄 평가 메시지

  const GolfScoreResult({
    required this.score,
    required this.status,
    required this.message,
  });
}

/// 골프 지수 계산기
/// 기획서의 알고리즘을 구현: 100점 만점에서 감점 방식 (Deduction System)
class GolfScoreCalculator {
  /// 골프 지수 계산
  ///
  /// [windSpeed]: 풍속 (m/s)
  /// [rainAmount]: 시간당 강수량 (mm)
  /// [temperature]: 기온 (°C)
  static GolfScoreResult calculate({
    required double windSpeed,
    required double rainAmount,
    required double temperature,
  }) {
    // 바람 감점 계산
    int windPenalty = _calculateWindPenalty(windSpeed);

    // 강수 감점 계산
    int rainPenalty = _calculateRainPenalty(rainAmount);

    // 기온 감점 계산
    int tempPenalty = _calculateTempPenalty(temperature);

    // 최종 점수 계산 (최소 0점)
    int finalScore = max(0, 100 - windPenalty - rainPenalty - tempPenalty);

    // 상태 및 메시지 결정
    String status;
    String message;

    if (finalScore >= 80) {
      status = 'good';
      message = '라베 도전하기 완벽합니다! ⛳️';
    } else if (finalScore >= 50) {
      status = 'soso';
      message = '라운딩 가능하지만 주의하세요 🏌️';
    } else {
      status = 'bad';
      message = '오늘은 연습장 가시는 게... ☔️';
    }

    return GolfScoreResult(score: finalScore, status: status, message: message);
  }

  /// 바람 감점 계산
  /// 0 ~ 3m/s: 감점 없음
  /// 4 ~ 7m/s: -10점 (약간 영향)
  /// 8 ~ 11m/s: -25점 (클럽 선택 영향 큼)
  /// 12m/s 이상: -40점 (플레이 어려움)
  static int _calculateWindPenalty(double windSpeed) {
    if (windSpeed <= 3) {
      return 0;
    } else if (windSpeed <= 7) {
      return 10;
    } else if (windSpeed <= 11) {
      return 25;
    } else {
      return 40;
    }
  }

  /// 강수 감점 계산
  /// 0mm: 감점 없음
  /// 0.1 ~ 1mm (이슬비): -15점
  /// 1 ~ 5mm (보통 비): -30점
  /// 5mm 이상 (호우): -50점 (경기 중단 가능성)
  static int _calculateRainPenalty(double rainAmount) {
    if (rainAmount == 0) {
      return 0;
    } else if (rainAmount < 1) {
      return 15;
    } else if (rainAmount < 5) {
      return 30;
    } else {
      return 50;
    }
  }

  /// 기온 감점 계산
  /// 5°C ~ 28°C: 감점 없음 (골든 존)
  /// 0°C ~ 4°C 또는 29°C ~ 32°C: -10점
  /// 영하(<0°C) 또는 폭염(>33°C): -30점
  static int _calculateTempPenalty(double temperature) {
    if (temperature >= 5 && temperature <= 28) {
      return 0;
    } else if ((temperature >= 0 && temperature <= 4) ||
        (temperature >= 29 && temperature <= 32)) {
      return 10;
    } else {
      return 30;
    }
  }

  /// 바람 조언 메시지 생성
  static String getWindAdvice(double windSpeed) {
    if (windSpeed <= 3) {
      return '깃대도 안 흔들리는 무풍! 라베 찬스! 🎌';
    } else if (windSpeed <= 7) {
      return '바람을 태우세요. 핀보다 한 클럽 여유 있게 🌬️';
    } else {
      return '모자 조심! 탄도 낮게 깔아치는 펀치샷이 유리합니다 💨';
    }
  }

  /// 강수 조언 메시지 생성
  static String getRainAdvice(double rainAmount) {
    if (rainAmount == 0) {
      return '비 걱정 없습니다! ☀️';
    } else if (rainAmount < 3) {
      return '부슬비입니다. 우비 입고 강행 가능! 🌂';
    } else {
      return '취소 고민 좀 해보셔야겠는데요? 동반자와 상의하세요 ☔️';
    }
  }
}
