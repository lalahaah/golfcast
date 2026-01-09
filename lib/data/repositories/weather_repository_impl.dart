import '../../domain/entities/weather_data.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/remote_weather_datasource.dart';
import '../models/weather_model.dart';

/// 날씨 Repository 구현체
class WeatherRepositoryImpl implements WeatherRepository {
  final RemoteWeatherDataSource dataSource;

  WeatherRepositoryImpl(this.dataSource);

  @override
  Future<WeatherData> getWeatherForecast(double lat, double lon) async {
    // 날씨와 대기질 데이터를 병렬로 요청
    final results = await Future.wait([
      dataSource.getWeatherForecast(lat, lon),
      dataSource.getAirPollution(lat, lon),
    ]);

    final weatherData = results[0] as WeatherDataModel;
    final airData = results[1] as Map<String, dynamic>;

    try {
      // 대기질 데이터 추출 (list[0].components)
      final components = airData['list'][0]['components'];
      final pm2_5 = (components['pm2_5'] as num).toDouble();
      final pm10 = (components['pm10'] as num).toDouble();

      // 현재 날씨 모델에 미세먼지 정보 병합
      final updatedCurrent = (weatherData.current as HourlyWeatherModel)
          .copyWithPollution(pm2_5: pm2_5, pm10: pm10);

      return WeatherDataModel(
        lat: weatherData.lat,
        lon: weatherData.lon,
        timezone: weatherData.timezone,
        current: updatedCurrent,
        hourly: weatherData.hourly,
        daily: weatherData.daily,
      );
    } catch (e) {
      // 대기질 데이터 파싱 실패 시 원본 날씨 데이터 반환
      return weatherData;
    }
  }
}
