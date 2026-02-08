import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../providers/golf_course_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/golf_logo.dart';
import 'detail_screen.dart';
import '../../core/services/app_share_service.dart';
import 'settings_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/search_history_provider.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/entities/golf_course.dart';

/// 메인 검색 화면 (React 프로토타입과 동일한 디자인)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 이미 선택된 골프장이 있는데 텍스트가 수정되면 선택 상태 해제 (리스트 재노출)
    final selected = ref.read(selectedGolfCourseProvider);
    if (selected != null && query != selected.nameKr) {
      ref.read(selectedGolfCourseProvider.notifier).state = null;
    }

    if (query.isEmpty) {
      // 검색어가 비면 즉시 상태 초기화하여 반응성 향상
      ref.read(golfSearchQueryProvider.notifier).state = '';
      ref.read(selectedGolfCourseProvider.notifier).state = null;
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(golfSearchQueryProvider.notifier).state = query;
    });
  }

  void _resetToHome() {
    setState(() {
      _searchController.clear();
      _isFocused = false;
      _isLoading = false;
    });
    _focusNode.unfocus();
    ref.read(golfSearchQueryProvider.notifier).state = '';
    ref.read(selectedGolfCourseProvider.notifier).state = null;
  }

  void _handleSearch(String name) {
    _focusNode.unfocus();
    setState(() {
      _searchController.text = name;
      _isFocused = false;
      _isLoading = true;
    });

    // 로딩 효과 후 상세 화면 이동 (실제 데이터 연동 시에는 데이터 로드 시점 조절)
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ref.read(golfSearchQueryProvider.notifier).state = name;
      }
    });
  }

  void _selectCourse(GolfCourse course) {
    setState(() {
      _searchController.text = course.nameKr;
    });
    ref.read(selectedGolfCourseProvider.notifier).state = course;
    ref.read(searchHistoryProvider.notifier).incrementCount(course.id);
    _focusNode.unfocus();

    // 사용자가 '팝업'으로 이동을 원하므로, 바텀 시트를 띄워 날짜/시간을 바로 설정하게 함
    _showDateTimeBottomSheet(context, course);
  }

  void _showDateTimeBottomSheet(BuildContext context, GolfCourse course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.nameKr, style: TextStyles.heading2()),
                    Text(
                      course.fullRegion,
                      style: TextStyles.caption(color: AppColors.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '라운딩 일정 설정',
              style: TextStyles.body1().copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDateTimeSelector(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '날씨 확인하기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(golfSearchResultsProvider);
    final selectedCourse = ref.watch(selectedGolfCourseProvider);
    final favoritesAsync = ref.watch(favoriteCoursesProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
        if (_searchController.text.isEmpty) {
          ref.read(golfSearchQueryProvider.notifier).state = '';
          ref.read(selectedGolfCourseProvider.notifier).state = null;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: _resetToHome,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                // 로고 아이콘
                                const GolfLogo(size: 32),
                                const SizedBox(width: 8),
                                // 로고 텍스트
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Golf',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : AppColors.textStrong,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Cast',
                                        style: TextStyle(
                                          color: AppColors.brandGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 공유 버튼
                            IconButton(
                              icon: Icon(
                                Icons.share_outlined,
                                color: AppColors.textMuted,
                                size: 24,
                              ),
                              onPressed: () => AppShareService.shareApp(),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.all(4),
                              ),
                            ),
                            // 설정 버튼
                            IconButton(
                              icon: Icon(
                                Icons.settings_outlined,
                                color: AppColors.textMuted,
                                size: 24,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                              },
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.all(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 48),
                            // Hero 카피
                            AnimatedOpacity(
                              opacity:
                                  (_isFocused &&
                                      _searchController.text.isNotEmpty)
                                  ? 0.4
                                  : 1.0,
                              duration: const Duration(milliseconds: 500),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                child: Column(
                                  children: [
                                    Text(
                                      '언제 어디로\n라운딩 가시나요?',
                                      style: TextStyles.heading1(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // 검색창
                            AnimatedScale(
                              scale: _isFocused ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isFocused
                                          ? AppColors.brandGreen.withValues(
                                              alpha: 0.2,
                                            )
                                          : Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                      blurRadius: _isFocused ? 20 : 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _focusNode,
                                  autofocus: false,
                                  onChanged: _onSearchChanged,
                                  onSubmitted: (_) => _focusNode.unfocus(),
                                  decoration: InputDecoration(
                                    hintText: '골프장 이름 검색 (예: 레이크)',
                                    hintStyle: TextStyles.body1(
                                      color: AppColors.textMuted,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: _isFocused
                                          ? AppColors.brandGreen
                                          : AppColors.textMuted,
                                      size: 20,
                                    ),
                                    suffixIcon: _isLoading
                                        ? Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.brandGreen),
                                              ),
                                            ),
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: Theme.of(
                                      context,
                                    ).cardTheme.color,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: AppColors.brandGreen,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  style: TextStyles.body1(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 자동완성 드롭다운 (선택된 상태가 아닐 때만 노출)
                            if (_searchController.text.isNotEmpty &&
                                !_isLoading &&
                                selectedCourse == null)
                              searchResults.when(
                                data: (courses) {
                                  if (courses.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardTheme.color,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: AppColors.border.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      children: courses.take(5).map((course) {
                                        final selectedCourse = ref.watch(
                                          selectedGolfCourseProvider,
                                        );
                                        final isSelected =
                                            selectedCourse?.id == course.id;

                                        return InkWell(
                                          onTap: () => _selectCourse(course),
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.brandGreen
                                                        .withValues(alpha: 0.1)
                                                  : Colors.white,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: AppColors.border
                                                      .withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        course.nameKr,
                                                        style:
                                                            TextStyles.body1(
                                                              color: isSelected
                                                                  ? AppColors
                                                                        .brandGreen
                                                                  : AppColors
                                                                        .textStrong,
                                                            ).copyWith(
                                                              fontWeight:
                                                                  isSelected
                                                                  ? FontWeight
                                                                        .bold
                                                                  : FontWeight
                                                                        .normal,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            size: 10,
                                                            color: AppColors
                                                                .textMuted,
                                                          ),
                                                          const SizedBox(
                                                            width: 2,
                                                          ),
                                                          Text(
                                                            course.fullRegion,
                                                            style: TextStyles.caption(
                                                              color: AppColors
                                                                  .textMuted,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  isSelected
                                                      ? Icons.check_circle
                                                      : Icons.chevron_right,
                                                  color: isSelected
                                                      ? AppColors.brandGreen
                                                      : AppColors.textMuted,
                                                  size: isSelected ? 20 : 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (error, _) => const SizedBox.shrink(),
                              ),

                            // 골프장 선택 후 날짜/시간 선택 UI
                            if (_searchController.text.isNotEmpty &&
                                !_isLoading)
                              searchResults.when(
                                data: (courses) {
                                  final selectedCourse = ref.watch(
                                    selectedGolfCourseProvider,
                                  );
                                  if (selectedCourse == null ||
                                      courses.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      _buildDateTimeSelector(),
                                    ],
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (error, _) => const SizedBox.shrink(),
                              ),

                            const SizedBox(height: 32),

                            const SizedBox(height: 20),

                            // Idle 상태 콘텐츠
                            if (_searchController.text.isEmpty)
                              AnimatedOpacity(
                                opacity:
                                    (_isFocused &&
                                        _searchController.text.isNotEmpty)
                                    ? 0.2
                                    : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 즐겨찾기
                                    Text(
                                      '즐겨찾기',
                                      style: TextStyles.body1().copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    favoritesAsync.when(
                                      data: (favorites) {
                                        if (favorites.isEmpty) {
                                          return Container(
                                            padding: const EdgeInsets.all(24),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).cardTheme.color,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).dividerTheme.color!,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.star_border,
                                                  color: AppColors.textMuted
                                                      .withValues(alpha: 0.3),
                                                  size: 32,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '즐겨찾기한 골프장이 없습니다.\n상세 화면에서 별을 눌러보세요!',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyles.caption(
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        return Column(
                                          children: favorites.map((course) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: InkWell(
                                                onTap: () =>
                                                    _selectCourse(course),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).cardTheme.color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color: Theme.of(
                                                        context,
                                                      ).dividerTheme.color!,
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.03,
                                                            ),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .background,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.star,
                                                          color:
                                                              Colors.amber[400],
                                                          size: 18,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              course.nameKr,
                                                              style: TextStyles.body1()
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                            ),
                                                            Text(
                                                              course.fullRegion,
                                                              style:
                                                                  TextStyles.caption(),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.chevron_right,
                                                        color:
                                                            AppColors.textMuted,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      error: (error, _) =>
                                          const SizedBox.shrink(),
                                    ),
                                    const SizedBox(height: 32),

                                    // 자주 찾는 골프장 Top 3
                                    ref
                                        .watch(topSearchedCoursesProvider)
                                        .when(
                                          data: (topCourses) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.history,
                                                      size: 14,
                                                      color:
                                                          AppColors.brandGreen,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '자주 찾는 골프장 Top 3',
                                                      style: TextStyles.body1()
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                if (topCourses.isEmpty)
                                                  Text(
                                                    '검색 이력이 없습니다. 골프장을 검색하고 방문해 보세요!',
                                                    style: TextStyles.caption(
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                                  )
                                                else
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: topCourses.map((
                                                        course,
                                                      ) {
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                right: 12,
                                                              ),
                                                          child: OutlinedButton(
                                                            onPressed: () =>
                                                                _selectCourse(
                                                                  course,
                                                                ),
                                                            style: OutlinedButton.styleFrom(
                                                              backgroundColor:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .cardTheme
                                                                      .color,
                                                              side: BorderSide(
                                                                color: Theme.of(
                                                                  context,
                                                                ).dividerTheme.color!,
                                                                width: 1,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      20,
                                                                    ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical: 8,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              course.nameKr,
                                                              style:
                                                                  TextStyles.body2(
                                                                    color: AppColors
                                                                        .textBody,
                                                                  ).copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                          loading: () =>
                                              const SizedBox.shrink(),
                                          error: (err, stack) =>
                                              const SizedBox.shrink(),
                                        ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 32),
                            // _buildAdBanner(), // 임시로 광고 영역 숨김 (심사용)

                            // 하단 버튼이 고정되어 있으므로 스크롤 시 마지막 요소가 가려지지 않게 여백 추가
                            if (selectedCourse != null)
                              const SizedBox(
                                height: 120,
                              ) // 광고가 추가되었으므로 여백을 조금 더 늘림
                            else
                              const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              _buildWeatherViewButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimes = ref.watch(selectedTimesProvider);
    final dateKey = selectedDate != null
        ? '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'
        : null;
    final selectedTime = dateKey != null ? selectedTimes[dateKey] : null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              debugPrint('날짜 선택 버튼 클릭됨'); // 디버그용
              debugPrint("공유 데이터가 비어있습니다 (Weather or Score null)");
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 7)),
                locale: const Locale('ko', 'KR'),
              );
              if (picked != null) {
                debugPrint('선택된 날짜: $picked'); // 디버그용
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
            icon: Icon(
              Icons.calendar_today,
              size: 16,
              color: selectedDate != null
                  ? AppColors.brandGreen
                  : AppColors.textMuted,
            ),
            label: Text(
              selectedDate != null
                  ? DateFormat('M월 d일 (E)', 'ko_KR').format(selectedDate)
                  : '날짜 선택',
              style: TextStyles.body2(
                color: selectedDate != null
                    ? AppColors.brandGreen
                    : AppColors.textBody,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: selectedDate != null
                  ? AppColors.brandGreen.withValues(alpha: 0.1)
                  : Colors.white,
              side: BorderSide(
                color: selectedDate != null
                    ? AppColors.brandGreen
                    : AppColors.border,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: selectedDate == null
                ? null
                : () async {
                    debugPrint('시간 선택 버튼 클릭됨'); // 디버그용
                    final now = TimeOfDay.now();
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? now,
                    );
                    if (picked != null) {
                      debugPrint('선택된 시간: $picked'); // 디버그용
                      if (dateKey != null) {
                        final newTimes = Map<String, TimeOfDay>.from(
                          selectedTimes,
                        );
                        newTimes[dateKey] = picked;
                        ref.read(selectedTimesProvider.notifier).state =
                            newTimes;
                      }
                    }
                  },
            icon: Icon(
              Icons.access_time,
              size: 16,
              color: selectedTime != null
                  ? AppColors.brandGreen
                  : (selectedDate == null
                        ? AppColors.textMuted.withValues(alpha: 0.3)
                        : AppColors.textMuted),
            ),
            label: Text(
              selectedTime != null ? selectedTime.format(context) : '시간 선택',
              style: TextStyles.body2(
                color: selectedTime != null
                    ? AppColors.brandGreen
                    : (selectedDate == null
                          ? AppColors.textMuted.withValues(alpha: 0.3)
                          : AppColors.textBody),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: selectedTime != null
                  ? AppColors.brandGreen.withValues(alpha: 0.1)
                  : Colors.white,
              side: BorderSide(
                color: selectedTime != null
                    ? AppColors.brandGreen
                    : AppColors.border,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (selectedDate != null || selectedTime != null)
          IconButton(
            icon: Icon(Icons.close, size: 20, color: AppColors.textMuted),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = null;
              if (dateKey != null) {
                final newTimes = Map<String, TimeOfDay>.from(selectedTimes);
                newTimes.remove(dateKey);
                ref.read(selectedTimesProvider.notifier).state = newTimes;
              }
            },
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
      ],
    );
  }

  Widget _buildWeatherViewButton() {
    final selectedCourse = ref.watch(selectedGolfCourseProvider);

    if (selectedCourse == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DetailScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wb_sunny, size: 20),
              const SizedBox(width: 8),
              Text(
                // The instruction placed debugPrint inside the Text widget's content.
                // To maintain syntactic correctness, it's placed before the Text widget.
                // If 'targetCourse' is intended to be 'selectedCourse', please clarify.
                // debugPrint("공유 시작: ${targetCourse.nameKr}"); // Original instruction placement was syntactically incorrect.
                '${selectedCourse.nameKr} 날씨 보기',
                style: TextStyles.body1(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
