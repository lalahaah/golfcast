import '../entities/golf_course.dart';

/// 골프장 데이터 저장소 인터페이스
/// Data Layer에서 구현체를 제공합니다.
abstract class GolfCourseRepository {
  /// 모든 골프장 목록 조회
  Future<List<GolfCourse>> getAllCourses();

  /// 키워드로 골프장 검색 (부분 일치)
  /// [keyword]를 이름(한글/영문) 또는 별칭에서 검색
  Future<List<GolfCourse>> searchCourses(String keyword);

  /// ID로 특정 골프장 조회
  Future<GolfCourse?> getCourseById(String id);
}
