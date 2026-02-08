import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/golf_course.dart';
import 'golf_course_provider.dart';

/// 골프장별 검색/방문 횟수를 저장하는 Notifier
class SearchHistoryNotifier extends StateNotifier<Map<String, int>> {
  SearchHistoryNotifier() : super({}) {
    _loadHistory();
  }

  static const _key = 'search_history_counts';

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        state = decoded.map((key, value) => MapEntry(key, value as int));
      } catch (e) {
        state = {};
      }
    }
  }

  /// 특정 골프장의 검색/방문 횟수 증가
  Future<void> incrementCount(String courseId) async {
    final newState = Map<String, int>.from(state);
    newState[courseId] = (newState[courseId] ?? 0) + 1;
    state = newState;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(state));
  }
}

/// 검색 히스토리 Provider
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, Map<String, int>>((ref) {
      return SearchHistoryNotifier();
    });

/// 자주 찾는 골프장 Top 3 Provider
final topSearchedCoursesProvider = FutureProvider<List<GolfCourse>>((
  ref,
) async {
  final history = ref.watch(searchHistoryProvider);
  if (history.isEmpty) return [];

  final repository = ref.read(golfCourseRepositoryProvider);
  final allCourses = await repository.getAllCourses();

  // 횟수 기준 내림차순 정렬
  final sortedEntries = history.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // 상위 3개 ID 추출
  final top3Ids = sortedEntries.take(3).map((e) => e.key).toSet();

  // 해당 ID를 가진 골프장 객체들을 찾아 반환
  final top3Courses = allCourses
      .where((course) => top3Ids.contains(course.id))
      .toList();

  // 정렬 순서 유지 (역순 정렬된 history 순서대로)
  top3Courses.sort((a, b) {
    final aCount = history[a.id] ?? 0;
    final bCount = history[b.id] ?? 0;
    return bCount.compareTo(aCount);
  });

  return top3Courses;
});
