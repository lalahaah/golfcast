import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                    '서비스 이용약관',
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
                    title: 'GolfCast 서비스 이용약관',
                    content:
                        '본 약관은 (주)루시퍼(이하 "회사")이 운영하는 "GolfCast" 애플리케이션 및 관련 제반 서비스(이하 "서비스")를 이용함에 있어 "회사"와 "이용자"의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
                    isMainTitle: true,
                  ),
                  const SizedBox(height: 32),
                  _buildChapter(title: '제1장 총칙'),
                  _buildArticle(
                    title: '제1조 (목적)',
                    content:
                        '본 약관은 (주)루시퍼(이하 "회사")이 운영하는 "GolfCast" 애플리케이션 및 관련 제반 서비스(이하 "서비스")를 이용함에 있어 "회사"와 "이용자"의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
                  ),
                  _buildArticle(
                    title: '제2조 (용어의 정의)',
                    content:
                        '1. "서비스"란 "회사"가 "이용자"에게 제공하는 골프장별 기상 정보 제공, 골프 지수 산출, 내비게이션 연동 및 기타 골프 관련 정보 제공 서비스를 의미합니다.\n'
                        '2. "이용자"란 "서비스"에 접속하여 본 약관에 따라 "회사"가 제공하는 "서비스"를 이용하는 회원 및 비회원을 말합니다.\n'
                        '3. "회원"이란 "서비스"에 접속하여 본 약관에 따라 "회사"와 이용계약을 체결하고 "회사"가 제공하는 "서비스"를 이용하는 자를 말합니다.\n'
                        '4. "비회원"이란 "회원"에 가입하지 않고 "회사"가 제공하는 "서비스"를 이용하는 자를 말합니다.',
                  ),
                  _buildArticle(
                    title: '제3조 (약관의 명시와 개정)',
                    content:
                        '1. "회사"는 본 약관의 내용을 "이용자"가 쉽게 알 수 있도록 서비스 화면에 게시합니다.\n'
                        '2. "회사"는 약관의 규제에 관한 법률, 정보통신망 이용촉진 및 정보보호 등에 관한 법률 등 관련법을 위배하지 않는 범위에서 본 약관을 개정할 수 있습니다.',
                  ),

                  _buildChapter(title: '제2장 서비스의 이용 및 계약'),
                  _buildArticle(
                    title: '제4조 (이용계약의 성립)',
                    content:
                        '1. 이용계약은 "이용자"가 본 약관의 내용에 대하여 동의를 한 다음 회원가입 신청을 하고 "회사"가 이러한 신청에 대하여 승낙함으로써 성립합니다.\n'
                        '2. "회사"는 "이용자"의 신청에 대하여 "서비스" 이용을 승낙함을 원칙으로 합니다. 다만, "회사"는 다음 각 호에 해당하는 신청에 대하여는 승낙을 하지 않거나 사후에 이용계약을 해지할 수 있습니다.\n'
                        '○ 가입신청자가 본 약관에 의하여 이전에 회원자격을 상실한 적이 있는 경우\n'
                        '○ 타인의 명의를 이용한 경우\n'
                        '○ 허위의 정보를 기재하거나, "회사"가 제시하는 내용을 기재하지 않은 경우',
                  ),
                  _buildArticle(
                    title: '제5조 (서비스의 제공 및 변경)',
                    content:
                        '1. "회사"는 "이용자"에게 아래와 같은 서비스를 제공합니다.\n'
                        '○ 골프장별 실시간 날씨 및 예보 정보\n'
                        '○ 기상 데이터를 기반으로 한 골프 지수(Golf Score) 산출\n'
                        '○ 골프장 위치 정보 및 내비게이션 앱 연동\n'
                        '○ 기타 "회사"가 추가 개발하거나 다른 회사와의 제휴계약 등을 통해 "이용자"에게 제공하는 일체의 서비스\n'
                        '2. "회사"는 서비스의 기술적 사양의 변경 등의 경우에는 장차 체결되는 계약에 의해 제공할 서비스의 내용을 변경할 수 있습니다.',
                  ),
                  _buildArticle(
                    title: '제6조 (서비스의 중단)',
                    content:
                        '1. "회사"는 컴퓨터 등 정보통신설비의 보수점검, 교체 및 고장, 통신두절 또는 운영상 상당한 이유가 있는 경우 "서비스"의 제공을 일시적으로 중단할 수 있습니다.\n'
                        '2. "회사"는 제1항의 사유로 "서비스"의 제공이 중단됨으로 인하여 "이용자"가 입은 손해에 대하여 고의 또는 과실이 없는 한 책임을 부담하지 않습니다.',
                  ),

                  _buildChapter(title: '제3장 의무 및 책임'),
                  _buildArticle(
                    title: '제7조 (회사의 의무)',
                    content:
                        '1. "회사"는 관련법과 본 약관이 금지하거나 미풍양속에 반하는 행위를 하지 않으며, 계속적이고 안정적으로 "서비스"를 제공하기 위하여 최선을 다하여 노력합니다.\n'
                        '2. "회사"는 "이용자"가 안전하게 "서비스"를 이용할 수 있도록 개인정보보호를 위한 보안 시스템을 갖추어야 하며 개인정보처리방침을 공시하고 준수합니다.',
                  ),
                  _buildArticle(
                    title: '제8조 (이용자의 의무)',
                    content:
                        '"이용자"는 다음 행위를 하여서는 안 됩니다.\n'
                        '1. 신청 또는 변경 시 허위내용의 등록\n'
                        '2. 타인의 정보 도용\n'
                        '3. "회사"가 게시한 정보의 변경\n'
                        '4. "회사"가 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시\n'
                        '5. "회사" 및 기타 제3자의 저작권 등 지식재산권에 대한 침해\n'
                        '6. "회사" 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위',
                  ),
                  _buildArticle(
                    title: '제9조 (회원의 ID 및 비밀번호에 대한 의무)',
                    content:
                        '1. ID와 비밀번호에 관한 관리책임은 "회원"에게 있으며, 이를 제3자가 이용하도록 하여서는 안 됩니다.\n'
                        '2. "회원"은 ID 및 비밀번호가 도용되거나 제3자가 사용하고 있음을 인지한 경우에는 바로 "회사"에 통지하고 "회사"의 안내에 따라야 합니다.',
                  ),

                  _buildChapter(title: '제4장 손해배상 및 면책조항'),
                  _buildArticle(
                    title: '제10조 (면책조항)',
                    content:
                        '1. 기상 정보의 정확성: "회사"가 제공하는 모든 기상 정보 및 골프 지수는 외부 API(OpenWeatherMap 등)와 자체 알고리즘을 기반으로 한 \'예측치\'이며, 실제 기상 상황과 다를 수 있습니다. "회사"는 정보의 정확성, 신뢰성으로 인해 발생하는 "이용자"의 손해(라운딩 취소 위약금 등)에 대해 책임을 지지 않습니다.\n'
                        '2. 서비스 불가항력: "회사"는 천재지변 또는 이에 준하는 불가항력으로 인하여 "서비스"를 제공할 수 없는 경우에는 "서비스" 제공에 관한 책임이 면제됩니다.\n'
                        '3. 이용자 귀책: "회사"는 "이용자"의 귀책사유로 인한 "서비스" 이용의 장애에 대하여는 책임을 지지 않습니다.',
                  ),
                  _buildArticle(
                    title: '제11조 (저작권의 귀속 및 이용제한)',
                    content:
                        '1. "회사"가 작성한 저작물에 대한 저작권 및 기타 지식재산권은 "회사"에 귀속합니다.\n'
                        '2. "이용자"는 "서비스"를 이용함으로써 얻은 정보 중 "회사"에게 지식재산권이 귀속된 정보를 "회사"의 사전 승낙 없이 복제, 송신, 출판, 배포, 방송 기타 방법에 의하여 영리목적으로 이용하거나 제3자에게 이용하게 하여서는 안 됩니다.',
                  ),
                  _buildArticle(
                    title: '제12조 (재판권 및 준거법)',
                    content:
                        '1. "회사"와 "이용자" 간에 발생한 분쟁에 관한 소송은 민사소송법상의 관할법원에 제기합니다.\n'
                        '2. "회사"와 "이용자" 간에 제기된 소송에는 대한민국법을 적용합니다.',
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    '부칙\n본 약관은 2026년 1월 21일부터 적용됩니다.',
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

  Widget _buildChapter({required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0F172A), // slate-900
        ),
      ),
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
