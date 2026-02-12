import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 관리를 위한 서비스 클래스
class AdService {
  /// 배너 광고 단위 ID 가져오기 (테스트 ID 우선 사용)
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Android 테스트 배너 ID
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 ID
      }
    }

    // 실배포 시 실제 광고 단위 ID로 교체
    if (Platform.isAndroid) {
      return 'ca-app-pub-7835510494346254/5027928255';
    } else {
      // iOS용 ID가 따로 제공되지 않았으므로 동일한 ID를 사용하거나 필요시 업데이트
      return 'ca-app-pub-7835510494346254/5027928255';
    }
  }

  /// AdMob SDK 초기화
  static Future<void> initialize() async {
    // AdMob은 모바일(Android, iOS) 플랫폼만 지원합니다.
    // 데스크탑(macOS 등)이나 웹에서는 초기화를 건너뛰어 에러를 방지합니다.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await MobileAds.instance.initialize();
      debugPrint('AdMob SDK 초기화 완료');
    } else {
      debugPrint('AdMob SDK: 현재 플랫폼은 지원되지 않으므로 초기화를 건너뜁니다.');
    }
  }

  /// 배너 광고 위젯 생성 (간소화된 형태)
  static BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
