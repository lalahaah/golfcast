import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'golf_course_provider.dart';
import '../../domain/entities/golf_course.dart';

/// 즐겨찾기 골프장 ID 목록을 관리하는 Provider
final favoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsNotifier, List<String>>(() {
      return FavoriteIdsNotifier();
    });

class FavoriteIdsNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'favorite_golf_courses';

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// 즐겨찾기 토글 (추가/삭제)
  Future<void> toggleFavorite(String id) async {
    final currentIds = state.value ?? [];
    final updatedIds = List<String>.from(currentIds);

    if (updatedIds.contains(id)) {
      updatedIds.remove(id);
    } else {
      updatedIds.add(id);
    }

    state = AsyncValue.data(updatedIds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updatedIds);
  }
}

/// 즐겨찾기된 골프장 객체 목록을 제공하는 Provider
final favoriteCoursesProvider = FutureProvider<List<GolfCourse>>((ref) async {
  final favoriteIdsAsync = ref.watch(favoriteIdsProvider);

  return favoriteIdsAsync.when(
    data: (ids) async {
      if (ids.isEmpty) return [];

      final repository = ref.read(golfCourseRepositoryProvider);
      final allCourses = await repository.getAllCourses();

      // 저장된 ID 순서대로 정렬하여 반환
      final Map<String, GolfCourse> courseMap = {
        for (var course in allCourses) course.id: course,
      };

      return ids
          .map((id) => courseMap[id])
          .whereType<GolfCourse>()
          .toList()
          .reversed // 최근에 추가한 것이 앞으로 오게 함 (선택 사항)
          .toList();
    },
    loading: () => [],
    error: (error, _) => [],
  );
});

/// 특정 골프장의 즐겨찾기 여부를 확인하는 Provider
final isFavoriteProvider = Provider.family<bool, String>((ref, id) {
  final favoriteIds = ref.watch(favoriteIdsProvider).value ?? [];
  return favoriteIds.contains(id);
});
