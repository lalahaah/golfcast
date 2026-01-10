import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/golf_logo.dart';

class SettingsScreen extends StatelessWidget {
  final String version;

  const SettingsScreen({super.key, this.version = "1.0.0"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFF1F5F9), // slate-100
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
                        child: const Icon(
                          LucideIcons.chevronLeft,
                          size: 24,
                          color: Color(0xFF475569), // slate-600
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '설정 및 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A), // slate-900
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
                        // 2. App Name (English)
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Golf',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A), // slate-900
                                  letterSpacing: -1.0,
                                ),
                              ),
                              TextSpan(
                                text: 'Cast',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF15803D), // green-700
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
                            color: Color(0xFF64748B), // slate-500
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu Groups
                  _buildMenuGroup(
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
                        value: 'N.E.I.L(내일)',
                        type: _MenuType.text,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildMenuGroup(
                    title: '고객 지원',
                    items: [
                      _MenuItem(
                        icon: LucideIcons.mail,
                        label: '문의하기',
                        type: _MenuType.link,
                        onTap: () => _launchUrl('mailto:support@golfcast.com'),
                      ),
                      _MenuItem(
                        icon: LucideIcons.messageSquare,
                        label: '피드백 보내기',
                        type: _MenuType.link,
                        onTap: () =>
                            _launchUrl('https://forms.gle/your-form-link'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildMenuGroup(
                    title: '법적 고지 및 약관',
                    items: [
                      _MenuItem(
                        icon: LucideIcons.shieldCheck,
                        label: '개인정보 처리방침',
                        type: _MenuType.link,
                        onTap: () {}, // TODO: Add link
                      ),
                      _MenuItem(
                        icon: LucideIcons.fileText,
                        label: '서비스 이용약관',
                        type: _MenuType.link,
                        onTap: () {}, // TODO: Add link
                      ),
                      _MenuItem(
                        icon: LucideIcons.github,
                        label: '오픈소스 라이선스',
                        type: _MenuType.link,
                        onTap: () {}, // TODO: Add link
                      ),
                    ],
                  ),

                  // Footer Info
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 40),
                    child: Text(
                      'MADE WITH ❤️ BY NEXT ENGINE IDEA LAB\nALL RIGHTS RESERVED.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFCBD5E1), // slate-300
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

  Widget _buildMenuGroup({
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
              color: Color(0xFF94A3B8), // slate-400
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF1F5F9), // slate-100
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _buildListTile(item),
                  if (index != items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: const Color(0xFFF8FAFC), // slate-50
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(_MenuItem item) {
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
                  Icon(
                    item.icon,
                    size: 18,
                    color: const Color(0xFF94A3B8), // slate-400
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155), // slate-700
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (item.value != null)
                    Text(
                      item.value!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8), // slate-400
                      ),
                    ),
                  if (item.type == _MenuType.link) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: Color(0xFFCBD5E1), // slate-300
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

enum _MenuType { text, link }

class _MenuItem {
  final IconData icon;
  final String label;
  final String? value;
  final _MenuType type;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.value,
    required this.type,
    this.onTap,
  });
}
