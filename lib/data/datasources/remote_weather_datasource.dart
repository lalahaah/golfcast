import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// OpenWeatherMap API를 호출하는 데이터 소스
class RemoteWeatherDataSource {
  // OpenWeatherMap API 키 (One Call API 3.0 구독)
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
    if (_apiKey == 'YOUR_API_KEY_HERE') {
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
          'API 키가 유효하지 않거나 One Call 3.0 구독이 필요합니다. (401 Unauthorized)\n메시지: ${response.body}',
        );
      } else if (response.statusCode == 429) {
        throw Exception('API 호출 한도를 초과했습니다. (429 Too Many Requests)');
      } else if (response.statusCode == 403) {
        throw Exception('API 3.0은 유료입니다. 2.5 버전을 사용해주세요. (403 Forbidden)');
      } else {
        throw Exception(
          '날씨 데이터를 가져오는데 실패했습니다.\nStatus: ${response.statusCode}\nBody: ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('기상청 연결 상태가 좋지 않습니다. 잠시 후 다시 시도해주세요.\n오류: $e');
    }
  }
}
