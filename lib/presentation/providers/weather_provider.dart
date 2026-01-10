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

// 날짜별 선택한 시간 (날짜 키: YYYY-MM-DD 형식)
final selectedTimesProvider = StateProvider.autoDispose<Map<String, TimeOfDay>>(
  (ref) {
    return {};
  },
);

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

/// Helper: 정확한 시간 또는 가장 가까운 시간의 시간별 날씨 데이터 찾기
HourlyWeather _findClosestHourlyWeather(
  List<HourlyWeather> hourlyList,
  int targetHour,
) {
  if (hourlyList.isEmpty) {
    throw Exception('hourlyList is empty');
  }

  // 1. 정확한 시간 매칭 시도
  final exactMatch = hourlyList.where((h) => h.time.hour == targetHour);
  if (exactMatch.isNotEmpty) return exactMatch.first;

  // 2. 가장 가까운 시간 찾기
  return hourlyList.reduce((a, b) {
    final aDiff = (a.time.hour - targetHour).abs();
    final bDiff = (b.time.hour - targetHour).abs();
    return aDiff < bDiff ? a : b;
  });
}

// 골프 점수 계산 Provider
final golfScoreProvider = Provider.autoDispose<GolfScore?>((ref) {
  final weatherAsync = ref.watch(weatherDataProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final selectedTimes = ref.watch(selectedTimesProvider);
  final dateKey = selectedDate != null
      ? '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'
      : null;
  final selectedTime = dateKey != null ? selectedTimes[dateKey] : null;
  final now = DateTime.now();

  return weatherAsync.when(
    data: (weather) {
      double windSpeed;
      double rainAmount;
      double temperature;
      double humidity;
      double visibility;
      double? uvi;

      // 날짜를 선택하지 않았거나 오늘이면 현재 날씨 사용
      if (selectedDate == null) {
        windSpeed = weather.current.windSpeed;
        rainAmount = weather.current.rainAmount;
        temperature = weather.current.temperature;
        humidity = weather.current.humidity.toDouble();
        visibility = weather.current.visibility;
        uvi = weather.current.uvi;
      } else {
        // 날짜를 선택한 경우
        final isToday =
            selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;

        if (isToday && selectedTime == null) {
          // 오늘이지만 시간 미선택 → 현재 날씨
          windSpeed = weather.current.windSpeed;
          rainAmount = weather.current.rainAmount;
          temperature = weather.current.temperature;
          humidity = weather.current.humidity.toDouble();
          visibility = weather.current.visibility;
          uvi = weather.current.uvi;
        } else {
          // 오늘+시간선택 또는 미래날짜
          final hourlyForDate = weather.getHourlyWeatherForDate(selectedDate);

          if (hourlyForDate.isNotEmpty) {
            // 48시간 이내: 정확한 시간 또는 가장 가까운 시간 사용
            final targetHour = selectedTime?.hour ?? 10; // 기본값: 오전 10시
            final targetWeather = _findClosestHourlyWeather(
              hourlyForDate,
              targetHour,
            );

            windSpeed = targetWeather.windSpeed;
            rainAmount = targetWeather.rainAmount;
            temperature = targetWeather.temperature;
            humidity = targetWeather.humidity.toDouble();
            visibility = targetWeather.visibility;
            uvi = targetWeather.uvi;
          } else {
            // 48시간 이후: 일별 요약 데이터 사용
            final daily = weather.getDailyWeatherForDate(selectedDate);
            if (daily != null) {
              windSpeed = daily.windSpeed;
              rainAmount = daily.rainAmount;
              // 일별은 평균 기온 사용 (최저+최고)/2
              temperature = (daily.minTemp + daily.maxTemp) / 2;
              humidity = 50.0; // 일별 요약에는 습도가 없으므로 기본값
              visibility = 10000.0; // 기본값
              uvi = null; // 일별 데이터에는 UVI가 없음
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
        humidity: humidity,
        visibility: visibility,
      );

      return GolfScore(
        score: result.score,
        status: result.status,
        summary: result.summary,
        windAdvice: result.windAdvice,
        rainAdvice: result.rainAdvice,
        tempAdvice: result.tempAdvice,
        fogAdvice: result.fogAdvice,
        windSpeed: windSpeed,
        rainAmount: rainAmount,
        temperature: temperature,
        // **[복구 및 수정]** 상세 분석용 데이터 직접 할당
        // 체감온도 계산 (V2.2 로직과 일치: temp - (wind * 0.7))
        feelsLike: temperature - (windSpeed * 0.7),
        humidity: humidity.toInt(),
        uvi: uvi,
      );
    },
    loading: () => null,
    error: (error, _) => null,
  );
});
