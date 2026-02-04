import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// GolfCast 앱의 전체 테마 정의
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // 컬러 스킴
    colorScheme: ColorScheme.light(
      primary: AppColors.brandGreen,
      secondary: AppColors.signalGreen,
      surface: AppColors.surface,
      error: AppColors.signalRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textStrong,
    ),

    // 배경색
    scaffoldBackgroundColor: AppColors.background,

    // 텍스트 테마 (Pretendard 폰트)
    fontFamily: 'Pretendard',
    textTheme: const TextTheme().apply(
      fontFamily: 'Pretendard',
      fontFamilyFallback: const [
        '-apple-system',
        'BlinkMacSystemFont',
        'Apple SD Gothic Neo',
        'Roboto',
        'Noto Sans KR',
      ],
    ),

    // AppBar 테마
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textStrong,
      elevation: 0,
      centerTitle: false,
    ),

    // 카드 테마
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: AppColors.border,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // rounded-2xl
      ),
    ),

    // 입력 필드 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandGreen, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted),
    ),

    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Divider 테마
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // 컬러 스킴
    colorScheme: ColorScheme.dark(
      primary: AppColors.signalGreen, // 다크모드에서는 조금 더 밝은 그린 사용
      secondary: AppColors.signalGreen,
      surface: const Color(0xFF1E293B), // slate-800
      error: AppColors.signalRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF1F5F9), // slate-100
    ),

    // 배경색
    scaffoldBackgroundColor: const Color(0xFF0F172A), // slate-900
    // 텍스트 테마
    fontFamily: 'Pretendard',
    textTheme: const TextTheme().apply(
      bodyColor: const Color(0xFFF1F5F9), // slate-100
      displayColor: Colors.white,
      fontFamily: 'Pretendard',
    ),

    // AppBar 테마
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A), // slate-900 (scaffold bg)
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    // 카드 테마
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155)), // slate-700
      ),
    ),

    // 입력 필드 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.signalGreen, width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
    ),

    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Divider 테마
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
      space: 1,
    ),
  );
}
