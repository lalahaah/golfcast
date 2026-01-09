import '../../domain/entities/weather_data.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/remote_weather_datasource.dart';

/// 날씨 Repository 구현체
class WeatherRepositoryImpl implements WeatherRepository {
  final RemoteWeatherDataSource dataSource;

  WeatherRepositoryImpl(this.dataSource);

  @override
  Future<WeatherData> getWeatherForecast(double lat, double lon) async {
    return await dataSource.getWeatherForecast(lat, lon);
  }
}
