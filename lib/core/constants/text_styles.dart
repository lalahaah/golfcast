import 'package:flutter/material.dart';

/// GolfCast 디자인 시스템의 타이포그래피
/// Pretendard 폰트를 사용하여 한국어 가독성 최적화
class TextStyles {
  // Base TextStyle (Pretendard 폰트 사용)
  // Pretendard가 시스템에 없으면 -apple-system, Roboto 등으로 fallback
  static const String _fontFamily = 'Pretendard';

  static final TextStyle _baseStyle = const TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: [
      '-apple-system',
      'BlinkMacSystemFont',
      'Apple SD Gothic Neo',
      'Roboto',
      'Noto Sans KR',
    ],
  );

  // ========== Display XL (Score) ==========
  /// 64px (Bold) - 상세 화면의 골프 점수
  static TextStyle displayXL({Color? color}) => _baseStyle.copyWith(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.1,
  );

  // ========== Heading 1 ==========
  /// 24px (Bold) - 메인 타이틀
  static TextStyle heading1({Color? color}) => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.3,
  );

  // ========== Heading 2 ==========
  /// 20px (SemiBold) - 섹션 타이틀
  static TextStyle heading2({Color? color}) => _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );

  // ========== Body 1 ==========
  /// 16px (Medium) - 일반 텍스트, 검색 결과
  static TextStyle body1({Color? color}) => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.5,
  );

  // ========== Body 2 ==========
  /// 14px (Regular) - 보조 설명
  static TextStyle body2({Color? color}) => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.5,
  );

  // ========== Caption ==========
  /// 12px (Regular) - 태그, 날짜, 저작권
  static TextStyle caption({Color? color}) => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
  );
}
