import '../entities/weather_data.dart';
import '../repositories/weather_repository.dart';

/// 날씨 예보 조회 Use Case
class GetWeatherForecast {
  final WeatherRepository repository;

  GetWeatherForecast(this.repository);

  /// 특정 골프장의 날씨 예보 조회
  Future<WeatherData> call(double lat, double lon) async {
    return await repository.getWeatherForecast(lat, lon);
  }
}
