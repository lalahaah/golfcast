import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/golf_course.dart';
import '../../domain/entities/golf_score.dart';

class KakaoShareService {
  static Future<void> shareGolfWeather({
    required GolfCourse golfCourse,
    required GolfScore golfScore,
    String? imageUrl,
  }) async {
    try {
      debugPrint('=== 카카오 공유 시작 ===');
      debugPrint('골프장: ${golfCourse.nameKr}');
      debugPrint('점수: ${golfScore.score}');

      // 1. 카카오톡 설치 여부 확인
      bool isKakaoTalkSharingAvailable = await ShareClient.instance
          .isKakaoTalkSharingAvailable();

      debugPrint('카카오톡 설치 여부: $isKakaoTalkSharingAvailable');

      // 2. 메시지 템플릿 생성 (Feed Template)
      final FeedTemplate template = FeedTemplate(
        content: Content(
          title: '${golfCourse.nameKr} 라운딩 지수: ${golfScore.score}점',
          description: golfScore.summary,
          imageUrl: Uri.parse(
            imageUrl ??
                'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?q=80&w=1000&auto=format&fit=crop',
          ),
          link: Link(
            mobileWebUrl: Uri.parse(
              'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast',
            ),
            webUrl: Uri.parse(
              'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast',
            ),
          ),
        ),
        buttons: [
          Button(
            title: '날씨 확인하러 가기',
            link: Link(
              mobileWebUrl: Uri.parse(
                'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast',
              ),
              webUrl: Uri.parse(
                'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast',
              ),
            ),
          ),
        ],
      );

      // 3. 카카오톡 공유 실행
      if (isKakaoTalkSharingAvailable) {
        debugPrint('카카오톡 앱으로 공유 시도...');
        Uri uri = await ShareClient.instance.shareDefault(template: template);
        await ShareClient.instance.launchKakaoTalk(uri);
        debugPrint('카카오톡 공유 완료');
      } else {
        debugPrint('웹 공유로 fallback...');
        Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(
          template: template,
        );
        await launchBrowserTab(shareUrl);
        debugPrint('웹 공유 완료');
      }
    } catch (error) {
      // 사용자가 취소한 경우는 에러로 처리하지 않음
      if (error is PlatformException && error.code == 'CANCELED') {
        debugPrint('⚠️ 사용자가 공유를 취소했습니다.');
        return;
      }

      debugPrint('❌ 카카오 공유 실패: $error');
      debugPrint('ℹ️ 출시 버전이라면 카카오 개발자 콘솔에 릴리즈 키 해시가 등록되었는지 확인이 필요합니다.');

      // 카카오 공유 실패 시 시스템 기본 공유로 fallback 시도
      try {
        debugPrint('🔄 시스템 기본 공유로 전환합니다...');
        await shareViaSystem(golfCourse: golfCourse, golfScore: golfScore);
      } catch (systemError) {
        debugPrint('❌ 시스템 공유까지 실패: $systemError');
        rethrow; // 최종적으로 에러 전달
      }
    }
  }

  /// 시스템 기본 공유 (카카오톡 공유가 불가능하거나 실패할 경우 사용)
  static Future<void> shareViaSystem({
    required GolfCourse golfCourse,
    required GolfScore golfScore,
  }) async {
    final String message =
        '${golfCourse.nameKr} 라운딩 지수: ${golfScore.score}점\n'
        '${golfScore.summary}\n\n'
        '🏌️ 더 자세한 골프장 날씨는 GolfCast 앱에서 확인하세요!\n'
        'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast';

    await Share.share(message, subject: '${golfCourse.nameKr} 라운딩 지수 공유');
  }

  /// 앱 홍보 링크 공유
  static Future<void> shareAppLink() async {
    try {
      debugPrint('=== 앱 링크 공유 시작 ===');

      bool isKakaoTalkSharingAvailable = await ShareClient.instance
          .isKakaoTalkSharingAvailable();

      final FeedTemplate template = FeedTemplate(
        content: Content(
          title: 'GolfCast - 스마트한 골프 날씨 파트너',
          description: '전국 골프장의 실시간 날씨와 라운딩 지수를 확인하고, 최적의 티오프 시간을 찾아보세요!',
          imageUrl: Uri.parse(
            'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?q=80&w=1000&auto=format&fit=crop',
          ),
          link: Link(
            mobileWebUrl: Uri.parse(
              'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast',
            ),
            webUrl: Uri.parse(
              'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast',
            ),
          ),
        ),
        buttons: [
          Button(
            title: '앱 내려받기',
            link: Link(
              mobileWebUrl: Uri.parse(
                'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast',
              ),
              webUrl: Uri.parse(
                'https://play.google.com/store/apps/details?id=com.nextidealab.golfcast',
              ),
            ),
          ),
        ],
      );

      if (isKakaoTalkSharingAvailable) {
        Uri uri = await ShareClient.instance.shareDefault(template: template);
        await ShareClient.instance.launchKakaoTalk(uri);
      } else {
        Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(
          template: template,
        );
        await launchBrowserTab(shareUrl);
      }
    } catch (error) {
      debugPrint('❌ 앱 링크 공유 실패: $error');
      rethrow;
    }
  }
}
