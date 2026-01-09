# GolfCast ⛳️

골프장 날씨 정보를 제공하는 Flutter 앱

## 소개

GolfCast는 골프장별 실시간 날씨 정보와 골프 지수를 제공하여 최적의 라운딩 시간을 찾아주는 앱입니다.

## 주요 기능

- 🔍 **골프장 검색**: 수도권 주요 골프장 검색
- 🌤️ **실시간 날씨**: OpenWeatherMap API 기반 정확한 날씨 정보
- ⛳️ **골프 지수**: 바람, 강수, 기온을 고려한 0~100점 골프 지수
- ⏰ **시간별 예보**: 다음 12시간 시간별 날씨 예보
- 🤖 **AI 캐디 조언**: 날씨 조건에 따른 맞춤형 플레이 팁

## 기술 스택

- **Framework**: Flutter 3.10.4+
- **Architecture**: Clean Architecture (Domain/Data/Presentation)
- **State Management**: Riverpod
- **API**: OpenWeatherMap API
- **Font**: Pretendard

## 프로젝트 구조

```
lib/
├── core/                   # 공통 유틸리티
│   ├── constants/         # 컬러, 텍스트 스타일
│   ├── theme/             # 앱 테마
│   └── utils/             # 골프 점수 계산기
├── domain/                 # 비즈니스 로직
│   ├── entities/          # GolfCourse, WeatherData, GolfScore
│   ├── repositories/      # Repository 인터페이스
│   └── usecases/          # Use Cases
├── data/                   # 데이터 레이어
│   ├── models/            # DTO (JSON 변환)
│   ├── datasources/       # API & 로컬 데이터
│   └── repositories/      # Repository 구현
└── presentation/           # UI 레이어
    ├── providers/         # Riverpod Providers
    ├── screens/           # HomeScreen, DetailScreen
    └── widgets/           # 재사용 가능한 위젯
```

## 설치 및 실행

1. **Flutter SDK 설치**
   ```bash
   flutter --version  # Flutter 3.10.4 이상 필요
   ```

2. **패키지 설치**
   ```bash
   flutter pub get
   ```

3. **앱 실행**
   ```bash
   flutter run
   ```

## API 키 설정

OpenWeatherMap API 키가 필요합니다:
1. [OpenWeatherMap](https://openweathermap.org/api)에서 API 키 발급
2. `lib/data/datasources/remote_weather_datasource.dart`의 `_apiKey` 수정

## 디자인 시스템

### 컬러 팔레트
- **Brand Green**: #15803D - 로고, 주요 버튼
- **Signal Green**: #10B981 - 80점 이상 (Good)
- **Signal Yellow**: #FBBF24 - 50-79점 (So-so)
- **Signal Red**: #F43F5E - 49점 이하 (Bad)

### 타이포그래피
- Display XL (64px) - 골프 점수
- Heading 1 (24px) - 메인 타이틀
- Body 1 (16px) - 일반 텍스트
- Caption (12px) - 부가 정보

## 스크린샷

### 홈 화면
- 검색창을 통한 골프장 검색
- 최근 검색 기록
- 인기 골프장 Top 3

### 상세 화면
- 골프 지수 점수 카드
- 시간별 날씨 예보
- 상세 분석 (바람, 체감온도)
- AI 캐디 조언

## 라이선스

MIT License

## 개발자

개발: [@lalahaah](https://github.com/lalahaah)
