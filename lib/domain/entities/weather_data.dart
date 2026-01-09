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
  final double? uvi; // UV index

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
    this.uvi,
  });
}

/// 전체 날씨 데이터
class WeatherData {
  final double lat;
  final double lon;
  final String timezone;
  final HourlyWeather current;
  final List<HourlyWeather> hourly;

  const WeatherData({
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.current,
    required this.hourly,
  });

  /// 티오프 주요 시간대 (06:00 ~ 14:00) 필터링
  List<HourlyWeather> get teeOffTimeWeather {
    final now = DateTime.now();
    return hourly.where((w) {
      final hour = w.time.hour;
      return w.time.isAfter(now) && hour >= 6 && hour <= 14;
    }).toList();
  }
}
