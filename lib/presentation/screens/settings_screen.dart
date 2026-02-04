import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/golf_logo.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'location_terms_screen.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  final String version;

  const SettingsScreen({super.key, this.version = "1.0.0"});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          LucideIcons.chevronLeft,
                          size: 24,
                          color: isDarkMode
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '설정 및 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // App Logo Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const GolfLogo(size: 100),
                        const SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Golf',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const TextSpan(
                                text: 'Cast',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF15803D),
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '내일 라운딩 갈까 말까?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu Groups
                  _buildMenuGroup(
                    context,
                    title: '화면 설정',
                    items: [
                      _MenuItem(
                        icon: isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                        label: '다크 모드',
                        type: _MenuType.toggle,
                        boolValue: isDarkMode,
                        onChanged: (value) {
                          ref.read(themeProvider.notifier).toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildMenuGroup(
                    context,
                    title: '앱 정보',
                    items: [
                      _MenuItem(
                        icon: LucideIcons.info,
                        label: '버전 정보',
                        value: 'v$version',
                        type: _MenuType.text,
                      ),
                      const _MenuItem(
                        icon: LucideIcons.award,
                        label: '개발자',
                        value: 'Next Idea Lab(NIL)',
                        type: _MenuType.text,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildMenuGroup(
                    context,
                    title: '고객 지원',
                    items: [
                      _MenuItem(
                        icon: LucideIcons.mail,
                        label: '문의하기',
                        type: _MenuType.link,
                        onTap: () =>
                            _launchUrl('mailto:nextidealab.ai@gmail.com'),
                      ),
                      _MenuItem(
                        icon: LucideIcons.messageSquare,
                        label: '피드백 보내기',
                        type: _MenuType.link,
                        onTap: () =>
                            _launchUrl('mailto:nextidealab.ai@gmail.com'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildMenuGroup(
                    context,
                    title: '법적 고지 및 약관',
                    items: [
                      _MenuItem(
                        icon: LucideIcons.shieldCheck,
                        label: '개인정보 처리방침',
                        type: _MenuType.link,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuItem(
                        icon: LucideIcons.fileText,
                        label: '서비스 이용약관',
                        type: _MenuType.link,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TermsOfServiceScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuItem(
                        icon: LucideIcons.mapPin,
                        label: '위치정보 이용약관',
                        type: _MenuType.link,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LocationTermsScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuItem(
                        icon: LucideIcons.github,
                        label: '오픈소스 라이선스',
                        type: _MenuType.link,
                        onTap: () {
                          showLicensePage(
                            context: context,
                            applicationName: '',
                            applicationVersion: version,
                            applicationIcon: Column(
                              children: [
                                const GolfLogo(size: 80),
                                const SizedBox(height: 16),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Golf',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                          letterSpacing: -1.0,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'Cast',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF15803D),
                                          letterSpacing: -1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                            applicationLegalese: '© 2026 Next Idea Lab',
                          );
                        },
                      ),
                    ],
                  ),

                  // Footer Info
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 40),
                    child: Text(
                      'MADE WITH ❤️ BY NEXT IDEA LAB\nALL RIGHTS RESERVED.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                        height: 1.6,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildMenuGroup(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerTheme.color!),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _buildListTile(context, item),
                  if (index != items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerTheme.color,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, _MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.type == _MenuType.link ? item.onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(item.icon, size: 18, color: const Color(0xFF94A3B8)),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (item.type == _MenuType.toggle)
                    Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: item.boolValue ?? false,
                        onChanged: item.onChanged,
                        activeTrackColor: const Color(0xFF15803D),
                      ),
                    )
                  else if (item.value != null)
                    Text(
                      item.value!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  if (item.type == _MenuType.link) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: Color(0xFFCBD5E1),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

enum _MenuType { text, link, toggle }

class _MenuItem {
  final IconData icon;
  final String label;
  final String? value;
  final bool? boolValue;
  final _MenuType type;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onChanged;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.value,
    this.boolValue,
    required this.type,
    this.onTap,
    this.onChanged,
  });
}
