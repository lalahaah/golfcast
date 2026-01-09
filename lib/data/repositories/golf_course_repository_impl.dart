import '../../domain/entities/golf_course.dart';
import '../../domain/repositories/golf_course_repository.dart';
import '../datasources/local_golf_course_datasource.dart';
import '../models/golf_course_model.dart';

/// 골프장 Repository 구현체
class GolfCourseRepositoryImpl implements GolfCourseRepository {
  final LocalGolfCourseDataSource dataSource;

  // 캐시: 앱 실행 시 한 번만 로드
  List<GolfCourseModel>? _cachedCourses;

  GolfCourseRepositoryImpl(this.dataSource);

  /// 캐시된 골프장 데이터 가져오기 (없으면 로드)
  Future<List<GolfCourseModel>> _getCachedCourses() async {
    _cachedCourses ??= await dataSource.loadGolfCourses();
    return _cachedCourses!;
  }

  @override
  Future<List<GolfCourse>> getAllCourses() async {
    return await _getCachedCourses();
  }

  @override
  Future<List<GolfCourse>> searchCourses(String keyword) async {
    final courses = await _getCachedCourses();
    final lowerKeyword = keyword.toLowerCase();

    // 이름(한글/영문) 또는 별칭에서 부분 일치 검색
    return courses.where((course) {
      return course.nameKr.toLowerCase().contains(lowerKeyword) ||
          course.nameEn.toLowerCase().contains(lowerKeyword) ||
          course.aliases.any(
            (alias) => alias.toLowerCase().contains(lowerKeyword),
          );
    }).toList();
  }

  @override
  Future<GolfCourse?> getCourseById(String id) async {
    final courses = await _getCachedCourses();
    try {
      return courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }
}
