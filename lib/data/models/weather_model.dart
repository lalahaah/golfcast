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
    required super.visibility,
    super.uvi,
    super.pm2_5,
    super.pm10,
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
      visibility: (json['visibility'] as num?)?.toDouble() ?? 10000.0,
      uvi: (json['uvi'] as num?)?.toDouble(),
    );
  }

  /// 미세먼지 정보가 포함된 새로운 인스턴스 생성
  HourlyWeatherModel copyWithPollution({double? pm2_5, double? pm10}) {
    return HourlyWeatherModel(
      time: time,
      temperature: temperature,
      feelsLike: feelsLike,
      humidity: humidity,
      windSpeed: windSpeed,
      windDeg: windDeg,
      rainAmount: rainAmount,
      cloudiness: cloudiness,
      weatherMain: weatherMain,
      weatherDescription: weatherDescription,
      weatherIcon: weatherIcon,
      visibility: visibility,
      uvi: uvi,
      pm2_5: pm2_5 ?? this.pm2_5,
      pm10: pm10 ?? this.pm10,
    );
  }
}

/// 일별 날씨 데이터 모델
class DailyWeatherModel extends DailyWeather {
  const DailyWeatherModel({
    required super.date,
    required super.minTemp,
    required super.maxTemp,
    required super.rainProb,
    required super.rainAmount,
    required super.windSpeed,
    required super.weatherMain,
    required super.weatherDescription,
    required super.weatherIcon,
  });

  factory DailyWeatherModel.fromJson(Map<String, dynamic> json) {
    return DailyWeatherModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: (json['temp']['min'] as num).toDouble(),
      maxTemp: (json['temp']['max'] as num).toDouble(),
      rainProb: (json['pop'] as num).toDouble(),
      rainAmount: (json['rain'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['wind_speed'] as num).toDouble(),
      weatherMain: json['weather'][0]['main'] as String,
      weatherDescription: json['weather'][0]['description'] as String,
      weatherIcon: json['weather'][0]['icon'] as String,
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
    required super.daily,
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
      daily: (json['daily'] as List)
          .map((d) => DailyWeatherModel.fromJson(d))
          .toList(),
    );
  }
}
