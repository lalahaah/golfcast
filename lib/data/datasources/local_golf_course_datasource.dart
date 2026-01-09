import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/golf_course_model.dart';

/// 로컬 JSON 파일에서 골프장 데이터를 읽어오는 데이터 소스
class LocalGolfCourseDataSource {
  /// assets/data/golf_courses.json에서 골프장 데이터 로드
  Future<List<GolfCourseModel>> loadGolfCourses() async {
    try {
      // JSON 파일 읽기
      final String jsonString = await rootBundle.loadString(
        'assets/data/golf_courses.json',
      );

      // JSON 파싱
      final List<dynamic> jsonList = json.decode(jsonString) as List;

      // 모델로 변환
      return jsonList
          .map((json) => GolfCourseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('골프장 데이터를 불러오는데 실패했습니다: $e');
    }
  }
}
