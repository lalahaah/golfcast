import 'package:flutter/material.dart';

/// GolfCast 디자인 시스템의 컬러 팔레트
/// 기획서의 "The Green Code" 디자인 시스템을 따릅니다.
class AppColors {
  // ========== Brand & Functional Colors (The Traffic Light) ==========

  /// Primary - Brand Green (green-700)
  /// 로고, GNB 헤더, 주요 버튼에 사용
  static const Color brandGreen = Color(0xFF15803D);

  /// Positive - Signal Green (emerald-500)
  /// 80점 이상 (Good), 맑음, 추천
  static const Color signalGreen = Color(0xFF10B981);

  /// Caution - Signal Yellow (amber-400)
  /// 50~79점 (So-so), 흐림, 주의
  static const Color signalYellow = Color(0xFFFBBF24);

  /// Negative - Signal Red (rose-500)
  /// 49점 이하 (Bad), 비/눈, 경고
  static const Color signalRed = Color(0xFFF43F5E);

  /// Info - Sky Blue (sky-500)
  /// 일반 정보, 링크, 바람(약)
  static const Color skyBlue = Color(0xFF0EA5E9);

  // ========== Neutral Colors (Text & Background) ==========

  /// Background (slate-50)
  /// 앱 전체 배경
  static const Color background = Color(0xFFF8FAFC);

  /// Surface (white)
  /// 카드(Card) 배경
  static const Color surface = Color(0xFFFFFFFF);

  /// Text Strong (slate-900)
  /// 제목, 핵심 데이터 (점수 등)
  static const Color textStrong = Color(0xFF0F172A);

  /// Text Body (slate-600)
  /// 본문, 설명 텍스트
  static const Color textBody = Color(0xFF475569);

  /// Text Muted (slate-400)
  /// 부가 정보, 플레이스홀더
  static const Color textMuted = Color(0xFF94A3B8);

  /// Border (slate-200)
  /// 카드 테두리, 디바이더
  static const Color border = Color(0xFFE2E8F0);

  // ========== 점수 구간별 배경 컬러 ==========

  /// 80~100점: 좋음 (Good)
  static const Color bgGood = Color(0xFFF0FDF4); // emerald-50

  /// 50~79점: 보통 (So-so)
  static const Color bgSoso = Color(0xFFFFFBEB); // amber-50

  /// 0~49점: 나쁨 (Bad)
  static const Color bgBad = Color(0xFFFFF1F2); // rose-50

  // ========== Skeleton Loading ==========

  /// Skeleton UI 색상
  static const Color skeleton = Color(0xFFE2E8F0); // slate-200
}
