import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                    '개인정보 처리방침',
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
                    title: 'GolfCast 개인정보처리방침',
                    content:
                        '(주)루시퍼(이하 "회사")는 「개인정보 보호법」 제30조에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.\n\n본 방침은 2026년 1월 21일부터 시행됩니다.',
                    isMainTitle: true,
                  ),
                  const SizedBox(height: 32),
                  _buildArticle(
                    title: '제1조 (개인정보의 처리 목적)',
                    content:
                        '"회사"는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며 이용 목적이 변경되는 경우에는 「개인정보 보호법」 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.\n\n'
                        '1. 서비스 제공 및 관리: 골프장별 기상 정보 제공, 골프 지수 산출, 내비게이션 연동 서비스 제공 및 본인 확인 등\n'
                        '2. 회원 가입 및 관리 (향후 확장 시): 회원 가입 의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정 이용 방지\n'
                        '3. 마케팅 및 광고에의 활용 (선택 시): 신규 서비스 개발 및 맞춤 서비스 제공, 이벤트 및 광고성 정보 제공 및 참여기회 제공',
                  ),
                  _buildArticle(
                    title: '제2조 (개인정보의 처리 및 보유 기간)',
                    content:
                        '1. "회사"는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.\n'
                        '2. 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.\n'
                        '○ 서비스 이용 기록 및 접속 로그: 3개월 (통신비밀보호법)\n'
                        '○ 회원 가입 정보: 회원 탈퇴 시까지 (단, 관계 법령 위반에 따른 수사/조사 중인 경우 해당 수사/조사 종료 시까지)',
                  ),
                  _buildArticle(
                    title: '제3조 (처리하는 개인정보의 항목)',
                    content:
                        '"회사"는 서비스 제공을 위해 최소한의 개인정보를 수집하고 있습니다.\n\n'
                        '1. 비회원 서비스 이용 시 (현재):\n'
                        '○ 수집 항목: 기기 모델명, OS 버전, 서비스 이용 기록, 접속 로그, 쿠키, IP 주소\n'
                        '2. 회원 서비스 이용 시 (로그인 기능 도입 후):\n'
                        '○ 필수 항목: 이메일 주소, 비밀번호, 닉네임\n'
                        '○ 선택 항목: 선호 골프장, 성별, 연령대\n'
                        '3. 위치기반 서비스 이용 시:\n'
                        '○ 수집 항목: 사용자의 실시간 위치 정보 (단, 위치정보 이용약관에 따라 서비스 제공 즉시 파기하거나 익명화 처리함)',
                  ),
                  _buildArticle(
                    title: '제4조 (개인정보의 제3자 제공)',
                    content:
                        '"회사"는 정보주체의 개인정보를 제1조(개인정보의 처리 목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 「개인정보 보호법」 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.',
                  ),
                  _buildArticle(
                    title: '제5조 (개인정보처리의 위탁)',
                    content:
                        '"회사"는 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁할 수 있습니다.\n\n'
                        '● 위탁 대상: 구글 클라우드 서비스 (Firebase), AWS\n'
                        '● 위탁 업무: 데이터 보관 및 시스템 운영 (Cloud 인프라 제공)',
                  ),
                  _buildArticle(
                    title: '제6조 (정보주체와 법정대리인의 권리·의무 및 그 행사방법)',
                    content:
                        '1. 정보주체는 "회사"에 대해 언제든지 개인정보 열람·정정·삭제·처리정지 요구 등의 권리를 행사할 수 있습니다.\n'
                        '2. 제1항에 따른 권리 행사는 "회사"에 대해 서면, 전자우편 등을 통하여 하실 수 있으며 "회사"는 이에 대해 지체 없이 조치하겠습니다.',
                  ),
                  _buildArticle(
                    title: '제7조 (개인정보의 파기절차 및 파기방법)',
                    content:
                        '1. "회사"는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체 없이 해당 개인정보를 파기합니다.\n'
                        '2. 전자적 파일 형태의 정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제합니다.',
                  ),
                  _buildArticle(
                    title: '제8조 (개인정보의 안전성 확보 조치)',
                    content:
                        '"회사"는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다.\n\n'
                        '1. 관리적 조치: 내부관리계획 수립 및 시행, 정기적 직원 교육 등\n'
                        '2. 기술적 조치: 개인정보처리시스템 등의 접근권한 관리, 접속기록의 보관 및 위변조 방지, 개인정보의 암호화, 보안프로그램 설치',
                  ),
                  _buildArticle(
                    title: '제9조 (개인정보 보호책임자)',
                    content:
                        '"회사"는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.\n\n'
                        '● 성명: 박원영\n'
                        '● 직책: 대표이사 / 개인정보 보호책임자\n'
                        '● 연락처: nextidealab.ai@gmail.com',
                  ),
                  _buildArticle(
                    title: '제10조 (권익침해 구제방법)',
                    content:
                        '정보주체는 아래의 기관에 대해 개인정보 침해에 대한 피해구제, 상담 등을 문의하실 수 있습니다.\n\n'
                        '● 개인정보침해신고센터 (privacy.kisa.or.kr / 국번없이 118)\n'
                        '● 개인정보분쟁조정위원회 (kopico.go.kr / 국번없이 1833-6972)',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '부칙\n본 개인정보 처리방침은 2026년 1월 21일부터 적용됩니다.',
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
