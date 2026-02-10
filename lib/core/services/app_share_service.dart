import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class AppShareService {
  static const String appLink =
      'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast';
  static const String shareMessage =
      'GolfCast - 스마트한 골프 날씨 파트너\n전국 골프장의 실시간 날씨와 라운딩 지수를 확인하고, 최적의 티오프 시간을 찾아보세요!\n\n$appLink';

  /// 앱 홍보 및 링크 공유 (시스템 공유 시트 사용)
  static Future<void> shareApp() async {
    try {
      debugPrint('=== 시스템 앱 공유 시작 ===');
      await Share.share(shareMessage, subject: 'GolfCast 앱 추천');
      debugPrint('=== 시스템 앱 공유 완료 ===');
    } catch (e) {
      debugPrint('❌ 앱 링크 공유 실패: $e');
      rethrow;
    }
  }
}
