import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LocationTermsScreen extends StatelessWidget {
  const LocationTermsScreen({super.key});

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
                    '위치정보 이용약관',
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
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSection(
                    title: 'GolfCast 위치정보 이용약관',
                    content:
                        '본 약관은 (주)루시퍼(이하 "회사")가 제공하는 "GolfCast" 서비스(이하 "서비스")와 관련하여, "회사"가 "이용자"의 개인위치정보를 이용함에 있어 "회사"와 "이용자"의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.',
                    isMainTitle: true,
                  ),
                  const SizedBox(height: 32),
                  _buildArticle(
                    title: '제1조 (목적)',
                    content:
                        '본 약관은 (주)루시퍼(이하 "회사")가 제공하는 "GolfCast" 서비스(이하 "서비스")와 관련하여, "회사"가 "이용자"의 개인위치정보를 이용함에 있어 "회사"와 "이용자"의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.',
                  ),
                  _buildArticle(
                    title: '제2조 (약관 외 준칙)',
                    content:
                        '본 약관에 명시되지 않은 사항은 위치정보의 보호 및 이용 등에 관한 법률, 개인정보 보호법, 정보통신망 이용촉진 및 정보보호 등에 관한 법률 등 관계 법령 및 "회사"가 정한 "서비스" 이용약관의 규정에 따릅니다.',
                  ),
                  _buildArticle(
                    title: '제3조 (서비스의 내용)',
                    content:
                        '"회사"는 "이용자"의 위치정보를 이용하여 아래와 같은 서비스를 제공합니다.\n\n'
                        '1. 내 주변 골프장 검색: "이용자"의 현재 위치를 기반으로 인근 골프장의 날씨 및 골프 지수 정보 제공\n'
                        '2. 날씨 정보 개인화: "이용자"가 위치한 지역의 기상 특성을 고려한 맞춤형 라운딩 가이드 제공',
                  ),
                  _buildArticle(
                    title: '제4조 (개인위치정보의 이용 또는 제공)',
                    content:
                        '1. "회사"는 서비스 제공을 위해 "이용자"의 위치정보를 이용할 수 있으며, "이용자"는 본 약관에 동의함으로써 이에 동의한 것으로 간주합니다.\n'
                        '2. "회사"는 "이용자"의 동의 없이 개인위치정보를 제3자에게 제공하지 않습니다.\n'
                        '3. "회사"는 개인위치정보를 블록체인이나 서버에 저장하지 않으며, 서비스 제공 즉시 파기하는 것을 원칙으로 합니다. 단, 관계 법령에 따라 보존할 필요가 있는 경우 해당 기간까지 보관합니다.',
                  ),
                  _buildArticle(
                    title: '제5조 (이용자의 권리)',
                    content:
                        '1. "이용자"는 "회사"에 대하여 언제든지 개인위치정보를 이용한 서비스 제공 및 제3자 제공에 대한 동의의 전부 또는 일부를 철회할 수 있습니다.\n'
                        '2. "이용자"는 언제든지 개인위치정보의 이용 및 제공 사실 확인자료의 열람 및 고지를 요구할 수 있습니다.\n'
                        '3. "이용자"는 단말기의 설정 기능을 통해 위치정보 수집 허용 여부를 직접 제어할 수 있습니다.',
                  ),
                  _buildArticle(
                    title: '제6조 (위치정보관리책임자의 지정)',
                    content:
                        '"회사"는 위치정보를 적절히 관리·보호하고 이용자의 불만을 원활히 처리할 수 있도록 실질적인 책임을 가진 위치정보관리책임자를 지정합니다.\n\n'
                        '● 성명: 박원영\n'
                        '● 연락처: nextidealab.ai@gmail.com',
                  ),
                  _buildArticle(
                    title: '제7조 (손해배상 및 면책)',
                    content:
                        '1. "회사"가 위치정보의 보호 및 이용 등에 관한 법률 제15조 내지 제26조의 규정을 위반한 행위로 "이용자"에게 손해가 발생한 경우 "이용자"는 "회사"에 대하여 손해배상 청구를 할 수 있습니다.\n'
                        '2. "회사"는 천재지변 등 불가항력인 사유로 서비스를 제공할 수 없는 경우 이로 인하여 "이용자"에게 발생한 손해에 대하여 책임을 부담하지 않습니다.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '부칙\n본 약관은 2026년 1월 21부터 시행합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B), // slate-500
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isMainTitle = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMainTitle ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A), // slate-900
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF475569), // slate-600
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildArticle({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B), // slate-800
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569), // slate-600
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
