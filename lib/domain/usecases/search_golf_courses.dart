import '../entities/golf_course.dart';
import '../repositories/golf_course_repository.dart';

/// 골프장 검색 Use Case
class SearchGolfCourses {
  final GolfCourseRepository repository;

  SearchGolfCourses(this.repository);

  /// 키워드로 골프장 검색
  /// Debounce는 Presentation Layer에서 처리
  Future<List<GolfCourse>> call(String keyword) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    return await repository.searchCourses(keyword);
  }
}
