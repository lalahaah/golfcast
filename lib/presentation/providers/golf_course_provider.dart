import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_golf_course_datasource.dart';
import '../../data/repositories/golf_course_repository_impl.dart';
import '../../domain/entities/golf_course.dart';
import '../../domain/usecases/search_golf_courses.dart';

// DataSource Provider
final golfCourseDataSourceProvider = Provider((ref) {
  return LocalGolfCourseDataSource();
});

// Repository Provider
final golfCourseRepositoryProvider = Provider((ref) {
  return GolfCourseRepositoryImpl(ref.read(golfCourseDataSourceProvider));
});

// Use Case Provider
final searchGolfCoursesProvider = Provider((ref) {
  return SearchGolfCourses(ref.read(golfCourseRepositoryProvider));
});

// 검색 결과 상태 Provider
final golfSearchQueryProvider = StateProvider<String>((ref) => '');

final golfSearchResultsProvider = FutureProvider<List<GolfCourse>>((ref) async {
  final query = ref.watch(golfSearchQueryProvider);

  if (query.trim().isEmpty) {
    return [];
  }

  final searchUseCase = ref.read(searchGolfCoursesProvider);
  return await searchUseCase(query);
});

// 선택된 골프장 Provider
final selectedGolfCourseProvider = StateProvider<GolfCourse?>((ref) => null);
