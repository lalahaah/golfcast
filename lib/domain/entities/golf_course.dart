/// 골프장 엔티티
/// 비즈니스 로직에서 사용하는 순수 Dart 클래스
class GolfCourse {
  final String id;
  final String nameKr;
  final String nameEn;
  final List<String> aliases;
  final String regionDepth1;
  final String regionDepth2;
  final double lat;
  final double lon;
  final String? courseType;

  const GolfCourse({
    required this.id,
    required this.nameKr,
    required this.nameEn,
    required this.aliases,
    required this.regionDepth1,
    required this.regionDepth2,
    required this.lat,
    required this.lon,
    this.courseType,
  });

  /// 전체 이름 (한글 + 영문)
  String get fullName => '$nameKr ($nameEn)';

  /// 지역 전체 이름
  String get fullRegion => '$regionDepth1 $regionDepth2';

  @override
  String toString() =>
      'GolfCourse(id: $id, name: $nameKr, region: $fullRegion)';
}
