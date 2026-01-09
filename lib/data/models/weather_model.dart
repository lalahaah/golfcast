import '../../domain/entities/weather_data.dart';

/// 시간별 날씨 모델
class HourlyWeatherModel extends HourlyWeather {
  const HourlyWeatherModel({
    required super.time,
    required super.temperature,
    required super.feelsLike,
    required super.humidity,
    required super.windSpeed,
    required super.windDeg,
    required super.rainAmount,
    required super.cloudiness,
    required super.weatherMain,
    required super.weatherDescription,
    required super.weatherIcon,
    super.uvi,
  });

  /// OpenWeatherMap API 응답에서 모델 생성
  factory HourlyWeatherModel.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherModel(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['temp'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      humidity: json['humidity'] as int,
      windSpeed: (json['wind_speed'] as num).toDouble(),
      windDeg: json['wind_deg'] as int,
      rainAmount: (json['rain']?['1h'] as num?)?.toDouble() ?? 0.0,
      cloudiness: json['clouds'] as int,
      weatherMain: json['weather'][0]['main'] as String,
      weatherDescription: json['weather'][0]['description'] as String,
      weatherIcon: json['weather'][0]['icon'] as String,
      uvi: (json['uvi'] as num?)?.toDouble(),
    );
  }
}

/// 전체 날씨 데이터 모델
class WeatherDataModel extends WeatherData {
  const WeatherDataModel({
    required super.lat,
    required super.lon,
    required super.timezone,
    required super.current,
    required super.hourly,
  });

  /// OpenWeatherMap API 응답에서 모델 생성
  factory WeatherDataModel.fromJson(Map<String, dynamic> json) {
    return WeatherDataModel(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      timezone: json['timezone'] as String,
      current: HourlyWeatherModel.fromJson(json['current']),
      hourly: (json['hourly'] as List)
          .map((h) => HourlyWeatherModel.fromJson(h))
          .toList(),
    );
  }
}
