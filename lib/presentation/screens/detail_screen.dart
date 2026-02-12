import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../domain/entities/golf_score.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/entities/golf_course.dart';
import '../providers/golf_course_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../../core/services/kakao_share_service.dart';
import '../../core/services/nav_service.dart';

import 'settings_screen.dart';
import '../providers/theme_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/ad_service.dart';

/// 날씨 상세 화면 (React 프로토타입과 동일한 디자인)
class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // 모바일 플랫폼(Android, iOS)인 경우에만 광고를 로드합니다.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _bannerAd = AdService.createBannerAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $error');
        },
      )..load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final golfCourse = ref.watch(selectedGolfCourseProvider);
    final weatherAsync = ref.watch(weatherDataProvider);
    final golfScore = ref.watch(golfScoreProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (golfCourse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('골프장 날씨')),
        body: const Center(child: Text('골프장 정보가 없습니다.')),
      );
    }

    final isFavorite = ref.watch(isFavoriteProvider(golfCourse.id));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _isBannerAdLoaded ? _buildAdBanner() : null,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: 0.9),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 24),
                      color: AppColors.textBody,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    golfCourse.nameKr,
                    style: TextStyles.heading2(),
                    textAlign: TextAlign.center,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            size: 24,
                          ),
                          color: isFavorite
                              ? Colors.amber
                              : AppColors.textMuted,
                          onPressed: () {
                            ref
                                .read(favoriteIdsProvider.notifier)
                                .toggleFavorite(golfCourse.id);
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            size: 24,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
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
                  ),
                ],
              ),
            ),

            // Date Picker Bar
            _buildDateSelector(context, ref, selectedDate, isDarkMode),

            // Content
            Expanded(
              child: weatherAsync.when(
                data: (weather) => _buildContent(
                  context,
                  ref,
                  weather,
                  golfScore,
                  selectedDate,
                  golfCourse,
                  isDarkMode,
                ),
                loading: () => const SkeletonLoader(),
                error: (error, stack) => _buildError(context, ref, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime? selectedDate,
    bool isDarkMode,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final displayDate = selectedDate ?? today;
    final dates = List.generate(8, (index) => today.add(Duration(days: index)));

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              date.year == displayDate.year &&
              date.month == displayDate.month &&
              date.day == displayDate.day;

          final dayFormat = DateFormat('E', 'ko_KR');
          final dayStr = index == 0 ? '오늘' : dayFormat.format(date);
          final dateStr = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = date;
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayStr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode
                                ? const Color(0xFF94A3B8)
                                : AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode ? Colors.white : AppColors.textStrong),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    WeatherData weather,
    GolfScore? golfScore,
    DateTime? selectedDate,
    GolfCourse golfCourse,
    bool isDarkMode,
  ) {
    // 점수에 따른 색상 및 텍스트
    Color scoreColor;
    Color scoreBgColor;
    Color scoreBorderColor;
    String statusEmoji;
    String statusText;

    if (golfScore != null) {
      if (golfScore.score >= 80) {
        scoreColor = const Color(0xFF059669); // emerald-600
        scoreBgColor = const Color(0xFFECFDF5); // emerald-50
        scoreBorderColor = const Color(0xFFD1FAE5); // emerald-100
        statusEmoji = '😄';
        statusText = 'VERY GOOD';
      } else if (golfScore.score >= 50) {
        scoreColor = const Color(0xFFF59E0B); // amber-500
        scoreBgColor = const Color(0xFFFFFBEB); // amber-50
        scoreBorderColor = const Color(0xFFFEF3C7); // amber-100
        statusEmoji = '😐';
        statusText = 'SO-SO';
      } else {
        scoreColor = AppColors.signalRed;
        scoreBgColor = AppColors.bgBad;
        scoreBorderColor = const Color(0xFFFECDD3); // rose-100
        statusEmoji = '☔️';
        statusText = 'BAD';
      }
    } else {
      scoreColor = AppColors.textBody;
      scoreBgColor = AppColors.background;
      scoreBorderColor = AppColors.border;
      statusEmoji = '🏌️';
      statusText = 'LOADING';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 날짜 미선택 시 향후 24시간 예보 표시, 선택 시 해당 날짜 예보 표시
    final List<HourlyWeather> hourlyForDate;
    // 선택한 날짜에 대한 시간 가져오기
    final selectedTimes = ref.watch(selectedTimesProvider);
    final dateKey = selectedDate != null
        ? '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}'
        : null;
    final selectedTime = dateKey != null ? selectedTimes[dateKey] : null;

    if (selectedDate == null) {
      // 날짜 미선택: 현재 시간 기준 향후 24시간
      final nowLimit = now.add(const Duration(hours: 24));
      hourlyForDate = weather.hourly
          .where(
            (h) =>
                h.time.isAfter(now.subtract(const Duration(minutes: 60))) &&
                h.time.isBefore(nowLimit),
          )
          .toList();
    } else {
      // 날짜 선택: 해당 날짜의 모든 시간별 예보 표시
      hourlyForDate = weather.getHourlyWeatherForDate(selectedDate);

      // 디버그: hourlyForDate에 실제로 어떤 날짜들이 포함되어 있는지 확인
      if (hourlyForDate.isNotEmpty) {
        debugPrint(
          '📅 선택한 날짜: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
        );
        debugPrint('📊 hourlyForDate 첫번째: ${hourlyForDate.first.time}');
        debugPrint('📊 hourlyForDate 마지막: ${hourlyForDate.last.time}');
        debugPrint('📊 총 ${hourlyForDate.length}개');
      }
    }

    final dailyForDate = weather.getDailyWeatherForDate(selectedDate ?? today);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Card (Traffic Light System)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Theme.of(context).cardTheme.color
                  : scoreBgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode
                    ? Theme.of(context).dividerTheme.color!
                    : scoreBorderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${golfScore?.score ?? 0}',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                        height: 1,
                        letterSpacing: -2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: scoreColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$statusEmoji $statusText',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${golfScore?.summary ?? '데이터 보완 중...'}"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: scoreColor.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 시간별 예보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hourlyForDate.isNotEmpty ? '시간별 예보' : '오늘의 예보 요약',
                style: TextStyles.body1().copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textStrong,
                ),
              ),
              if (selectedDate == null)
                Text(
                  '향후 24시간',
                  style: TextStyles.caption(color: AppColors.brandGreen),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hourlyForDate.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyForDate.length,
                itemBuilder: (context, index) {
                  final hourly = hourlyForDate[index];
                  final isNextDay = hourly.time.day != now.day;
                  final timeFormat = DateFormat(isNextDay ? 'd일 HH시' : 'HH:00');

                  // 선택한 시간이 있으면 그 시간을 하이라이트, 없으면 현재 시간을 하이라이트
                  final bool isHighlighted;
                  if (selectedTime != null && selectedDate != null) {
                    final selectedDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    isHighlighted =
                        hourly.time.year == selectedDateTime.year &&
                        hourly.time.month == selectedDateTime.month &&
                        hourly.time.day == selectedDateTime.day &&
                        hourly.time.hour == selectedDateTime.hour;
                  } else {
                    isHighlighted =
                        hourly.time.hour == now.hour &&
                        hourly.time.day == now.day;
                  }

                  return Container(
                    width: isNextDay ? 90 : 80,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? AppColors.brandGreen
                          : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHighlighted
                            ? AppColors.brandGreen
                            : AppColors.border.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: isHighlighted
                          ? [
                              BoxShadow(
                                color: AppColors.brandGreen.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          timeFormat.format(hourly.time),
                          style: TextStyle(
                            fontSize: 10,
                            color: isHighlighted
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppColors.textMuted,
                          ),
                        ),
                        Icon(
                          _getWeatherIcon(hourly.weatherMain),
                          size: 24,
                          color: isHighlighted
                              ? Colors.white
                              : _getWeatherIconColor(hourly.weatherMain),
                        ),
                        Text(
                          '${hourly.temperature.toStringAsFixed(0)}°',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isHighlighted
                                ? Colors.white
                                : (isDarkMode
                                      ? Colors.white
                                      : AppColors.textStrong),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else if (dailyForDate != null)
            _buildDailySummaryCard(context, dailyForDate)
          else
            const Center(child: Text('해당 날짜의 예보 정보가 존재하지 않습니다.')),

          const SizedBox(height: 24),

          // 상세 분석 (4-Factor Grid)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '상세 분석',
                style: TextStyles.body1().copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textStrong,
                ),
              ),
              Text(
                'OpenWeatherMap 제공',
                style: TextStyles.caption(color: AppColors.brandGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1, // 높이를 조금 더 확보하여 오버플로 방지
            children: [
              _buildAnalysisCard(
                context,
                icon: Icons.air,
                iconColor: Colors.blue[500]!,
                label: '바람',
                value:
                    '${golfScore?.windSpeed.toStringAsFixed(1) ?? '0.0'} m/s',
                onTap: () => _showHourlyDetail(context, 'wind', hourlyForDate),
              ),
              _buildAnalysisCard(
                context,
                icon: Icons.thermostat,
                iconColor: Colors.orange[500]!,
                label: '기온/체감',
                value:
                    '${golfScore?.temperature.toStringAsFixed(0) ?? weather.current.temperature.toStringAsFixed(0)}° / ${golfScore?.feelsLike.toStringAsFixed(0) ?? weather.current.feelsLike.toStringAsFixed(0)}°',
                onTap: () => _showHourlyDetail(context, 'temp', hourlyForDate),
              ),
              _buildAnalysisCard(
                context,
                icon: Icons.umbrella,
                iconColor: Colors.teal[500]!,
                label: '강수/습도',
                value:
                    '${golfScore?.rainAmount.toStringAsFixed(1) ?? weather.current.rainAmount.toStringAsFixed(1)}mm / ${golfScore?.humidity ?? weather.current.humidity}%',
                onTap: () => _showHourlyDetail(context, 'rain', hourlyForDate),
              ),
              _buildAnalysisCard(
                context,
                icon: Icons.wb_sunny_outlined,
                iconColor: Colors.red[400]!,
                label: '자외선',
                value:
                    (golfScore?.uvi ?? weather.current.uvi)?.toStringAsFixed(
                      1,
                    ) ??
                    '0.0',
                onTap: () => _showHourlyDetail(context, 'uvi', hourlyForDate),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // AI Caddie's Tip
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B), // slate-800
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.tips_and_updates_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Color(0xFF4ADE80),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "CADDIE'S TIP",
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF4ADE80), // green-400
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAdviceRow(
                      Icons.air_rounded,
                      golfScore?.windAdvice ?? '바람 정보를 불러오는 중...',
                    ),
                    const SizedBox(height: 12),
                    _buildAdviceRow(
                      Icons.umbrella_rounded,
                      golfScore?.rainAdvice ?? '강수 정보를 불러오는 중...',
                    ),
                    const SizedBox(height: 12),
                    _buildAdviceRow(
                      Icons.thermostat_rounded,
                      golfScore?.tempAdvice ?? '기온 정보를 불러오는 중...',
                    ),
                    if (golfScore?.fogAdvice != null) ...[
                      const SizedBox(height: 12),
                      _buildAdviceRow(
                        Icons.cloud_queue_rounded,
                        golfScore!.fogAdvice!,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 골프장으로 출발하기 섹션
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.navigation_outlined,
                    size: 18,
                    color: AppColors.textStrong,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '골프장으로 출발하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textStrong,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // 티맵 버튼
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        try {
                          await NavService.launchTmap(
                            name: golfCourse.nameKr,
                            lat: golfCourse.lat,
                            lon: golfCourse.lon,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0064FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '티맵',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 카카오맵 버튼
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await NavService.launchKakaoMap(
                          name: golfCourse.nameKr,
                          lat: golfCourse.lat,
                          lon: golfCourse.lon,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE812), // 카카오 노란색
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '카카오맵',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 동반자에게 공유하기 버튼 추가
          InkWell(
            onTap: () async {
              if (golfScore == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('날씨 정보를 불러오는 중입니다...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              try {
                await KakaoShareService.shareGolfWeather(
                  golfCourse: golfCourse,
                  golfScore: golfScore,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('공유 중 오류가 발생했습니다: $e'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.brandGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.brandGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_rounded,
                    size: 20,
                    color: AppColors.brandGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '동반자에게 공유하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildAdBanner(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, DailyWeather daily) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              theme.dividerTheme.color?.withValues(alpha: 0.5) ??
              AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getWeatherIcon(daily.weatherMain),
            size: 48,
            color: _getWeatherIconColor(daily.weatherMain),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${daily.minTemp.toStringAsFixed(0)}° / ${daily.maxTemp.toStringAsFixed(0)}°',
                  style: TextStyles.heading2(
                    color: isDark ? Colors.white : AppColors.textStrong,
                  ),
                ),
                Text(
                  daily.weatherDescription,
                  style: TextStyles.body2(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '강수확률',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                ),
              ),
              Text(
                '${(daily.rainProb * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textStrong,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                theme.dividerTheme.color?.withValues(alpha: 0.5) ??
                AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyles.caption(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyles.heading2(
                color: isDark ? Colors.white : AppColors.textStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHourlyDetail(
    BuildContext context,
    String type,
    List<HourlyWeather> hourlyData,
  ) {
    String title;
    IconData icon;
    Color color;

    switch (type) {
      case 'wind':
        title = '시간별 바람 예보';
        icon = Icons.air;
        color = Colors.blue;
        break;
      case 'temp':
        title = '시간별 기온 예보';
        icon = Icons.thermostat;
        color = Colors.orange;
        break;
      case 'rain':
        title = '시간별 강수 예보';
        icon = Icons.umbrella;
        color = Colors.teal;
        break;
      case 'uvi':
        title = '시간별 자외선 예보';
        icon = Icons.wb_sunny_outlined;
        color = Colors.red;
        break;
      default:
        return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 12),
                  Text(title, style: TextStyles.heading2()),
                ],
              ),
            ),
            Expanded(
              child: hourlyData.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '시간별 예보는 현재 시간 기준\n48시간 이내의 데이터만 제공됩니다.',
                              textAlign: TextAlign.center,
                              style: TextStyles.body1(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '그 외 날짜는 일별 요약을 참고해주세요.',
                              textAlign: TextAlign.center,
                              style: TextStyles.caption(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: hourlyData.length,
                      itemBuilder: (context, index) {
                        final h = hourlyData[index];
                        final dateStr = DateFormat('MM.dd').format(h.time);
                        final timeStr = DateFormat('HH:00').format(h.time);
                        String valueText = '';
                        String subText = '';

                        if (type == 'wind') {
                          valueText = '${h.windSpeed.toStringAsFixed(1)} m/s';
                        } else if (type == 'temp') {
                          valueText = '${h.temperature.toStringAsFixed(0)}°';
                          subText = '체감 ${h.feelsLike.toStringAsFixed(0)}°';
                        } else if (type == 'rain') {
                          valueText = '${h.rainAmount.toStringAsFixed(1)}mm';
                          subText = '습도 ${h.humidity}%';
                        } else if (type == 'uvi') {
                          valueText = h.uvi?.toStringAsFixed(1) ?? '0.0';
                        }

                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timeStr,
                                    style: TextStyles.body1(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textStrong,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    dateStr,
                                    style: TextStyles.caption(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    valueText,
                                    style: TextStyles.body1(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textStrong,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (subText.isNotEmpty)
                                    Text(
                                      subText,
                                      style: TextStyles.caption(
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.signalRed),
            const SizedBox(height: 16),
            Text(
              error.toString().contains('API')
                  ? '날씨 정보를 불러올 수 없습니다.\nAPI 연결을 확인해주세요.'
                  : '오류가 발생했습니다.',
              style: TextStyles.body1(color: AppColors.signalRed),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(weatherDataProvider);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _getWeatherIconColor(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Colors.orange[400]!;
      case 'clouds':
        return AppColors.textMuted;
      case 'rain':
        return Colors.blue[400]!;
      case 'snow':
        return Colors.blue[200]!;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _buildAdviceRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF94A3B8), // slate-400
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFCBD5E1), // slate-300
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdBanner() {
    if (_bannerAd == null || !_isBannerAdLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
