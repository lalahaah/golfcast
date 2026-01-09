/// 시간별 날씨 데이터
class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final double rainAmount; // mm
  final int cloudiness; // %
  final String weatherMain; // Clear, Clouds, Rain 등
  final String weatherDescription;
  final String weatherIcon;
  final double visibility; // 시정 거리 (m)
  final double? uvi; // UV index
  final double? pm2_5;
  final double? pm10;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.rainAmount,
    required this.cloudiness,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.visibility,
    this.uvi,
    this.pm2_5,
    this.pm10,
  });
}

/// 일별 날씨 데이터 (요약)
class DailyWeather {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double rainProb; // 강수 확률 (0.0 ~ 1.0)
  final double rainAmount; // mm
  final double windSpeed; // m/s
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;

  const DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.rainProb,
    required this.rainAmount,
    required this.windSpeed,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
  });
}

/// 전체 날씨 데이터
class WeatherData {
  final double lat;
  final double lon;
  final String timezone;
  final HourlyWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  const WeatherData({
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  /// 티오프 주요 시간대 (06:00 ~ 14:00) 필터링
  List<HourlyWeather> get teeOffTimeWeather {
    final now = DateTime.now();
    return hourly.where((w) {
      final hour = w.time.hour;
      return w.time.isAfter(now) && hour >= 6 && hour <= 14;
    }).toList();
  }

  /// 특정 날짜의 시간별 예보 필터링
  List<HourlyWeather> getHourlyWeatherForDate(DateTime date) {
    return hourly.where((w) {
      return w.time.year == date.year &&
          w.time.month == date.month &&
          w.time.day == date.day;
    }).toList();
  }

  /// 특정 날짜의 일별 요약 정보 가져오기
  DailyWeather? getDailyWeatherForDate(DateTime date) {
    try {
      return daily.firstWhere((d) {
        return d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day;
      });
    } catch (_) {
      return null;
    }
  }
}
