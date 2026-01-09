import '../entities/weather_data.dart';

/// 날씨 데이터 저장소 인터페이스
/// Data Layer에서 구현체를 제공합니다.
abstract class WeatherRepository {
  /// 특정 좌표의 날씨 예보 조회
  /// [lat]: 위도
  /// [lon]: 경도
  /// Returns: 현재 날씨 및 시간별 예보 데이터
  Future<WeatherData> getWeatherForecast(double lat, double lon);
}
