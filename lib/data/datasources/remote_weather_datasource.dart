import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// OpenWeatherMap API를 호출하는 데이터 소스
class RemoteWeatherDataSource {
  // OpenWeatherMap API 키 (One Call API 3.0 구독 대상)
  static const String _apiKey = 'b607e5c50e40765c5e425d9d1dd2fd27';
  // One Call API 3.0
  static const String _baseUrl =
      'https://api.openweathermap.org/data/3.0/onecall';

  final http.Client client;

  RemoteWeatherDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// 특정 좌표의 날씨 예보 조회
  /// [lat]: 위도
  /// [lon]: 경도
  Future<WeatherDataModel> getWeatherForecast(double lat, double lon) async {
    // API 키 확인
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') {
      throw Exception('OpenWeatherMap API 키가 설정되지 않았습니다.');
    }

    // API URL 구성
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'exclude': 'minutely,daily,alerts',
        'units': 'metric',
        'lang': 'kr',
        'appid': _apiKey,
      },
    );

    try {
      // API 호출
      final response = await client.get(uri);

      // 응답 확인
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return WeatherDataModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception(
          'API 키가 유효하지 않거나 One Call 3.0 구독이 필요합니다. (401 Unauthorized)\n'
          'OpenWeatherMap 계정에서 One Call 3.0 구독 상태를 확인해주세요.',
        );
      } else if (response.statusCode == 429) {
        throw Exception('API 호출 한도를 초과했습니다. (429 Too Many Requests)');
      } else if (response.statusCode == 403) {
        throw Exception(
          '해당 서비스에 대한 권한이 없습니다. (403 Forbidden)\n'
          'One Call 3.0 요금제 가입 여부를 확인해주세요.',
        );
      } else {
        throw Exception(
          '날씨 데이터를 가져오는데 실패했습니다.\n'
          'Status: ${response.statusCode}\nBody: ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('OpenWeatherMap 서버 연결 실패: $e');
    }
  }
}
