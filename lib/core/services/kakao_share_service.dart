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
    // 1. 카카오톡 설치 여부 확인
    bool isKakaoTalkSharingAvailable = await ShareClient.instance
        .isKakaoTalkSharingAvailable();

    // 2. 메시지 템플릿 생성 (Feed Template)
    final FeedTemplate template = FeedTemplate(
      content: Content(
        title: '${golfCourse.nameKr} 라운딩 지수: ${golfScore.score}점',
        description: golfScore.summary,
        imageUrl: Uri.parse(
          imageUrl ??
              'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?q=80&w=1000&auto=format&fit=crop', // 기본 골프장 이미지
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
      try {
        Uri uri = await ShareClient.instance.shareDefault(template: template);
        await ShareClient.instance.launchKakaoTalk(uri);
      } catch (error) {
        debugPrint('카카오톡 공유 실패: $error');
      }
    } else {
      try {
        Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(
          template: template,
        );
        await launchBrowserTab(shareUrl);
      } catch (error) {
        debugPrint('카카오톡 웹 공유 실패: $error');
      }
    }
  }
}
