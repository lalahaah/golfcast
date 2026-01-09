import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/utils/golf_score_calculator.dart';
import '../providers/golf_course_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/skeleton_loader.dart';

/// 날씨 상세 화면 (React 프로토타입과 동일한 디자인)
class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final golfCourse = ref.watch(selectedGolfCourseProvider);
    final weatherAsync = ref.watch(weatherDataProvider);
    final golfScore = ref.watch(golfScoreProvider);

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    color: AppColors.textBody,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(golfCourse.nameKr, style: TextStyles.heading2()),
                  IconButton(
                    icon: const Icon(Icons.star_border, size: 24),
                    color: AppColors.textMuted,
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: weatherAsync.when(
                data: (weather) => _buildContent(context, weather, golfScore),
                loading: () => const SkeletonLoader(),
                error: (error, stack) => _buildError(context, ref, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, weather, golfScore) {
    // 점수에 따른 색상 및 텍스트
    Color scoreColor;
    Color scoreBgColor;
    Color scoreBorderColor;
    String statusEmoji;
    String statusText;

    if (golfScore != null) {
      if (golfScore.isGood) {
        scoreColor = const Color(0xFF059669); // emerald-600
        scoreBgColor = const Color(0xFFECFDF5); // emerald-50
        scoreBorderColor = const Color(0xFFD1FAE5); // emerald-100
        statusEmoji = '😄';
        statusText = 'VERY GOOD';
      } else if (golfScore.isSoso) {
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
                  '"${golfScore?.message ?? '로딩 중...'}"',
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
          Text(
            '시간별 예보',
            style: TextStyles.body1().copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weather.hourly.length > 12
                  ? 12
                  : weather.hourly.length,
              itemBuilder: (context, index) {
                final hourly = weather.hourly[index];
                final timeFormat = DateFormat('HH:00');
                final isHighlighted = index == 1; // 두 번째 항목 강조

                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHighlighted ? AppColors.brandGreen : Colors.white,
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
                          fontSize: 12,
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
          ),
          const SizedBox(height: 24),

          // 상세 분석 (4-Factor Grid)
          Text(
            '상세 분석',
            style: TextStyles.body1().copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalysisCard(
                  icon: Icons.air,
                  iconColor: Colors.blue[500]!,
                  iconBgColor: Colors.blue[50]!,
                  label: '바람',
                  value: '${weather.current.windSpeed.toStringAsFixed(1)} m/s',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalysisCard(
                  icon: Icons.thermostat,
                  iconColor: Colors.orange[500]!,
                  iconBgColor: Colors.orange[50]!,
                  label: '체감온도',
                  value: '${weather.current.feelsLike.toStringAsFixed(0)}°',
                ),
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
                    Icons.location_on,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CADDIE'S TIP",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4ADE80), // green-400
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      GolfScoreCalculator.getWindAdvice(
                        weather.current.windSpeed,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFCBD5E1), // slate-300
                        height: 1.5,
                      ),
                    ),
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
}
