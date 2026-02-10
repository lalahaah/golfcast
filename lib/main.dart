import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '2f57cf81042017c525129b9618f9e994');

  // AdMob SDK 초기화
  await AdService.initialize();

  // 디버그용: Android에서만 키해시 출력 (카카오 설정용)
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      String keyHash = await KakaoSdk.origin;
      debugPrint('📱 현재 앱 키해시: $keyHash');
      debugPrint('⚠️ 카카오 개발자 콘솔(https://developers.kakao.com)에서');
      debugPrint('   내 애플리케이션 > 앱 설정 > 플랫폼 > Android 플랫폼');
      debugPrint('   키 해시 항목에 위 값을 등록해주세요.');
    } catch (e) {
      debugPrint('키해시 가져오기 실패: $e');
    }
  }

  runApp(const ProviderScope(child: GolfCastApp()));
}

class GolfCastApp extends ConsumerWidget {
  const GolfCastApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'GolfCast',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
