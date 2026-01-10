import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavService {
  /// 티맵 길 안내 (앱 호출)
  static Future<void> launchTmap({
    required String name,
    required double lat,
    required double lon,
  }) async {
    // Tmap 명세: tmap://route?goalx={lon}&goaly={lat}&goalname={name}
    final String url =
        'tmap://route?goalx=$lon&goaly=$lat&goalname=${Uri.encodeComponent(name)}';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // 앱이 없는 경우 스토어 이동 또는 안내
      debugPrint('Tmap 앱이 설치되어 있지 않습니다.');
      throw 'Tmap 앱이 설치되어 있지 않습니다.';
    }
  }

  /// 카카오맵 길 안내 (앱 호출 후 실패 시 웹Fallback)
  static Future<void> launchKakaoMap({
    required String name,
    required double lat,
    required double lon,
  }) async {
    // KakaoMap 앱 호출: kakaomap://route?ep={lat},{lon}&by=CAR
    final String appUrl = 'kakaomap://route?ep=$lat,$lon&by=CAR';
    final Uri appUri = Uri.parse(appUrl);

    // 웹 Fallback: https://map.kakao.com/link/to/{NAME},{LAT},{LON}
    final String webUrl =
        'https://map.kakao.com/link/to/${Uri.encodeComponent(name)},$lat,$lon';
    final Uri webUri = Uri.parse(webUrl);

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      debugPrint('KakaoMap 앱이 없어 웹으로 연결합니다.');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
