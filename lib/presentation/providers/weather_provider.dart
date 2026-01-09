import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/golf_score_calculator.dart';
import '../../data/datasources/remote_weather_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/golf_score.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/usecases/get_weather_forecast.dart';
import 'golf_course_provider.dart';

// DataSource Provider
final weatherDataSourceProvider = Provider((ref) {
  return RemoteWeatherDataSource();
});

// Repository Provider
final weatherRepositoryProvider = Provider((ref) {
  return WeatherRepositoryImpl(ref.read(weatherDataSourceProvider));
});

// Use Case Provider
final getWeatherForecastProvider = Provider((ref) {
  return GetWeatherForecast(ref.read(weatherRepositoryProvider));
});

// 날씨 데이터 Provider
final weatherDataProvider = FutureProvider.autoDispose<WeatherData>((
  ref,
) async {
  final golfCourse = ref.watch(selectedGolfCourseProvider);

  if (golfCourse == null) {
    throw Exception('골프장이 선택되지 않았습니다.');
  }

  final useCase = ref.read(getWeatherForecastProvider);
  return await useCase(golfCourse.lat, golfCourse.lon);
});

// 골프 점수 계산 Provider
final golfScoreProvider = Provider.autoDispose<GolfScore?>((ref) {
  final weatherAsync = ref.watch(weatherDataProvider);

  return weatherAsync.when(
    data: (weather) {
      final result = GolfScoreCalculator.calculate(
        windSpeed: weather.current.windSpeed,
        rainAmount: weather.current.rainAmount,
        temperature: weather.current.temperature,
      );

      return GolfScore(
        score: result.score,
        status: result.status,
        message: result.message,
        windSpeed: weather.current.windSpeed,
        rainAmount: weather.current.rainAmount,
        temperature: weather.current.temperature,
      );
    },
    loading: () => null,
    error: (error, _) => null,
  );
});
