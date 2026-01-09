import 'package:flutter/material.dart';
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

// 날짜 선택 Provider (기본값: null = 선택 안 함)
final selectedDateProvider = StateProvider.autoDispose<DateTime?>((ref) {
  return null;
});

// 시간 선택 Provider (기본값: null = 선택 안 함)
final selectedTimeProvider = StateProvider.autoDispose<TimeOfDay?>((ref) {
  return null;
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
  final selectedDate = ref.watch(selectedDateProvider);
  final selectedTime = ref.watch(selectedTimeProvider);
  final now = DateTime.now();

  return weatherAsync.when(
    data: (weather) {
      double windSpeed;
      double rainAmount;
      double temperature;

      // 날짜를 선택하지 않았거나 오늘이면 현재 날씨 사용
      if (selectedDate == null) {
        windSpeed = weather.current.windSpeed;
        rainAmount = weather.current.rainAmount;
        temperature = weather.current.temperature;
      } else {
        // 날짜를 선택한 경우
        final isToday =
            selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;

        if (isToday) {
          // 오늘인데 시간을 선택한 경우, 해당 시간대 예보 사용
          if (selectedTime != null) {
            final hourlyForToday = weather.getHourlyWeatherForDate(
              selectedDate,
            );
            // firstWhere orElse에서 타입 에러 방지를 위해 수동 체크
            final match = hourlyForToday.where(
              (h) => h.time.hour >= selectedTime.hour,
            );
            final targetHourWeather = match.isNotEmpty
                ? match.first
                : weather.current;

            windSpeed = targetHourWeather.windSpeed;
            rainAmount = targetHourWeather.rainAmount;
            temperature = targetHourWeather.temperature;
          } else {
            // 오늘이지만 시간 미선택 시 현재 날씨
            windSpeed = weather.current.windSpeed;
            rainAmount = weather.current.rainAmount;
            temperature = weather.current.temperature;
          }
        } else {
          // 미래 날짜이면 기획된 알고리즘에 따라 데이터 선택
          final hourlyForDate = weather.getHourlyWeatherForDate(selectedDate);

          if (hourlyForDate.isNotEmpty) {
            // 48시간 이내: 선택한 시간 또는 티오프 피크 시간(오전 10시) 데이터 사용
            final targetHour = selectedTime?.hour ?? 10;
            final match = hourlyForDate.where((h) => h.time.hour >= targetHour);
            final peakHourWeather = match.isNotEmpty
                ? match.first
                : hourlyForDate.first;

            windSpeed = peakHourWeather.windSpeed;
            rainAmount = peakHourWeather.rainAmount;
            temperature = peakHourWeather.temperature;
          } else {
            // 48시간 이후: 일별 요약 데이터 사용
            final daily = weather.getDailyWeatherForDate(selectedDate);
            if (daily != null) {
              windSpeed = daily.windSpeed;
              rainAmount = daily.rainAmount;
              // 일별은 최고 기온을 기준으로 보수적 판단
              temperature = daily.maxTemp;
            } else {
              return null;
            }
          }
        }
      }

      final result = GolfScoreCalculator.calculate(
        windSpeed: windSpeed,
        rainAmount: rainAmount,
        temperature: temperature,
      );

      return GolfScore(
        score: result.score,
        status: result.status,
        message: result.message,
        windSpeed: windSpeed,
        rainAmount: rainAmount,
        temperature: temperature,
      );
    },
    loading: () => null,
    error: (error, _) => null,
  );
});
