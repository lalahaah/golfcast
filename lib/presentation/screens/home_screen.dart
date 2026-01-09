import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../providers/golf_course_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/golf_logo.dart';
import 'detail_screen.dart';

/// 메인 검색 화면 (React 프로토타입과 동일한 디자인)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFocused = false;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(golfSearchQueryProvider.notifier).state = query;
    });
  }

  void _handleSearch(String name) {
    setState(() {
      _searchController.text = name;
      _isFocused = false;
      _isLoading = true;
    });

    // 로딩 효과 후 상세 화면 이동
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // 선택된 골프장 찾기
        ref.read(golfSearchQueryProvider.notifier).state = name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(golfSearchResultsProvider);
    final selectedCourse = ref.watch(selectedGolfCourseProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                      Row(
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
                                  style: TextStyle(color: AppColors.textStrong),
                                ),
                                TextSpan(
                                  text: 'Cast',
                                  style: TextStyle(color: AppColors.brandGreen),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // 공유 버튼
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          color: AppColors.textMuted,
                          size: 24,
                        ),
                        onPressed: () {},
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
                          // Hero 카피
                          AnimatedOpacity(
                            opacity: _isFocused ? 0.4 : 1.0,
                            duration: const Duration(milliseconds: 500),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              transform: Matrix4.translationValues(
                                0,
                                _isFocused ? -10 : 0,
                                0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '언제 어디로\n라운딩 가시나요?',
                                    style: TextStyles.heading1(),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyles.body2(),
                                      children: [
                                        const TextSpan(
                                          text: '골프장 날씨부터 공략법까지,\n',
                                        ),
                                        TextSpan(
                                          text: '골프캐스트',
                                          style: TextStyle(
                                            color: AppColors.brandGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: '가 알려드립니다.'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

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
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: _isFocused ? 20 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                autofocus: false,
                                onChanged: _onSearchChanged,
                                onTap: () => setState(() => _isFocused = true),
                                onSubmitted: (_) =>
                                    setState(() => _isFocused = false),
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
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.brandGreen,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.white,
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

                          // 자동완성 드롭다운
                          if (_searchController.text.isNotEmpty && !_isLoading)
                            searchResults.when(
                              data: (courses) {
                                if (courses.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                        onTap: () {
                                          ref
                                                  .read(
                                                    selectedGolfCourseProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              course;
                                        },
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                          style:
                                                              TextStyles.caption(
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
                          if (_searchController.text.isNotEmpty && !_isLoading)
                            searchResults.when(
                              data: (courses) {
                                final selectedCourse = ref.watch(
                                  selectedGolfCourseProvider,
                                );
                                if (selectedCourse == null || courses.isEmpty) {
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
                              opacity: _isFocused ? 0.2 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 최근 검색
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '최근 검색',
                                        style: TextStyles.body1().copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          '지우기',
                                          style: TextStyles.caption().copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  InkWell(
                                    onTap: () => _handleSearch('스카이72 골프클럽'),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.border,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Icon(
                                              Icons.access_time,
                                              color: AppColors.textMuted,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '스카이72 GC',
                                                  style: TextStyles.body1()
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  '인천 중구',
                                                  style: TextStyles.caption(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '어제',
                                              style: TextStyles.caption(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // 인기 골프장 Top 3
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber[400],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '인기 골프장 Top 3',
                                        style: TextStyles.body1().copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: ['베네스트', '남촌', '이스트밸리'].map((
                                      name,
                                    ) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: OutlinedButton(
                                          onPressed: () => _handleSearch(name),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: BorderSide(
                                              color: AppColors.border,
                                              width: 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: Text(
                                            name,
                                            style:
                                                TextStyles.body2(
                                                  color: AppColors.textBody,
                                                ).copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 32),
                          _buildAdBanner(),

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

            // 하단 결과 보기 플로팅 버튼
            _buildWeatherViewButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 32 / 9, // 세로 높이를 반으로 줄임 (기존 16:9 -> 32:9)
              child: Image.asset(
                'assets/images/premium_ad.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '필드 위에서 만나는 가장 완벽한 순간',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '프리미엄 골프 장비, 지금 확인해보세요.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTime = ref.watch(selectedTimeProvider);

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
                      ref.read(selectedTimeProvider.notifier).state = picked;
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
              ref.read(selectedTimeProvider.notifier).state = null;
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
