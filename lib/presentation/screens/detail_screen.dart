import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../domain/entities/golf_score.dart';
import '../../domain/entities/weather_data.dart';
import '../providers/golf_course_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../../core/services/kakao_share_service.dart';

/// 날씨 상세 화면 (React 프로토타입과 동일한 디자인)
class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final golfCourse = ref.watch(selectedGolfCourseProvider);
    final weatherAsync = ref.watch(weatherDataProvider);
    final golfScore = ref.watch(golfScoreProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    if (golfCourse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('골프장 날씨')),
        body: const Center(child: Text('골프장 정보가 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
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
                          icon: const Icon(Icons.star_border, size: 24),
                          color: AppColors.textMuted,
                          onPressed: () {},
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
                            Icons.share_outlined,
                            size: 24,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () async {
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
            _buildDateSelector(context, ref, selectedDate),

            // Content
            Expanded(
              child: weatherAsync.when(
                data: (weather) => _buildContent(
                  context,
                  ref,
                  weather,
                  golfScore,
                  selectedDate,
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
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final displayDate = selectedDate ?? today;
    final dates = List.generate(8, (index) => today.add(Duration(days: index)));

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(color: Colors.white),
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
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textStrong,
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
              color: scoreBgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scoreBorderColor, width: 1),
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
                    color: Colors.white,
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
                          : Colors.white,
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
                                : AppColors.textStrong,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else if (dailyForDate != null)
            _buildDailySummaryCard(dailyForDate)
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
            childAspectRatio: 1.3,
            children: [
              _buildAnalysisCard(
                icon: Icons.air,
                iconColor: Colors.blue[500]!,
                iconBgColor: Colors.blue[50]!,
                label: '바람',
                value:
                    '${golfScore?.windSpeed.toStringAsFixed(1) ?? '0.0'} m/s',
              ),
              _buildAnalysisCard(
                icon: Icons.thermostat,
                iconColor: Colors.orange[500]!,
                iconBgColor: Colors.orange[50]!,
                label: '기온/체감',
                value:
                    '${golfScore?.temperature.toStringAsFixed(0) ?? weather.current.temperature.toStringAsFixed(0)}° / ${golfScore?.feelsLike.toStringAsFixed(0) ?? weather.current.feelsLike.toStringAsFixed(0)}°',
              ),
              _buildAnalysisCard(
                icon: Icons.umbrella,
                iconColor: Colors.teal[500]!,
                iconBgColor: Colors.teal[50]!,
                label: '강수/습도',
                value:
                    '${golfScore?.rainAmount.toStringAsFixed(1) ?? weather.current.rainAmount.toStringAsFixed(1)}mm / ${golfScore?.humidity ?? weather.current.humidity}%',
              ),
              _buildAnalysisCard(
                icon: Icons.wb_sunny_outlined,
                iconColor: Colors.red[400]!,
                iconBgColor: Colors.red[50]!,
                label: '자외선',
                value:
                    (golfScore?.uvi ?? weather.current.uvi)?.toStringAsFixed(
                      1,
                    ) ??
                    '0.0',
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(DailyWeather daily) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
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
                  style: TextStyles.heading2(),
                ),
                Text(
                  daily.weatherDescription,
                  style: TextStyles.body2(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Text(
                '강수확률',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              Text(
                '${(daily.rainProb * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyles.caption()),
          const SizedBox(height: 4),
          Text(value, style: TextStyles.heading2()),
        ],
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
}
