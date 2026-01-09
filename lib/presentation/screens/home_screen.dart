import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../providers/golf_course_provider.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.brandGreen,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                              '어디로 라운딩\n가시나요?',
                              style: TextStyles.heading1(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyles.body2(),
                                children: [
                                  const TextSpan(text: '골프장 날씨부터 공략법까지,\n'),
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
                                  ? AppColors.brandGreen.withValues(alpha: 0.2)
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
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.border.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: courses.take(5).map((course) {
                                return InkWell(
                                  onTap: () {
                                    ref
                                            .read(
                                              selectedGolfCourseProvider
                                                  .notifier,
                                            )
                                            .state =
                                        course;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DetailScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.border.withValues(
                                            alpha: 0.3,
                                          ),
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
                                                style: TextStyles.body1(),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 10,
                                                    color: AppColors.textMuted,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    course.fullRegion,
                                                    style: TextStyles.caption(
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textMuted,
                                          size: 16,
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

                    const SizedBox(height: 40),

                    // Idle 상태 콘텐츠
                    if (_searchController.text.isEmpty)
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: _isFocused ? 0.2 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: SingleChildScrollView(
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
                                          decoration: TextDecoration.underline,
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                  children: ['베네스트', '남촌', '이스트밸리'].map((name) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      child: OutlinedButton(
                                        onPressed: () => _handleSearch(name),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color: AppColors.border,
                                            width: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
