import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
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
            mobileWebUrl: Uri.parse('https://developers.kakao.com'),
            webUrl: Uri.parse('https://developers.kakao.com'),
          ),
        ),
        buttons: [
          Button(
            title: '앱에서 보기',
            link: Link(
              mobileWebUrl: Uri.parse('https://developers.kakao.com'),
              webUrl: Uri.parse('https://developers.kakao.com'),
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
      debugPrint('❌ 카카오 공유 실패: $error');
      rethrow; // 에러를 호출자에게 전달
    }
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
            mobileWebUrl: Uri.parse('https://golfcast.app'),
            webUrl: Uri.parse('https://golfcast.app'),
          ),
        ),
        buttons: [
          Button(
            title: '앱 내려받기',
            link: Link(
              mobileWebUrl: Uri.parse('https://golfcast.app'),
              webUrl: Uri.parse('https://golfcast.app'),
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
