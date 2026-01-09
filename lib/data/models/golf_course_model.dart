import '../../domain/entities/golf_course.dart';

/// 골프장 데이터 모델 (DTO)
/// JSON <-> Entity 변환 담당
class GolfCourseModel extends GolfCourse {
  const GolfCourseModel({
    required super.id,
    required super.nameKr,
    required super.nameEn,
    required super.aliases,
    required super.regionDepth1,
    required super.regionDepth2,
    required super.lat,
    required super.lon,
    super.courseType,
  });

  /// JSON에서 모델 생성
  factory GolfCourseModel.fromJson(Map<String, dynamic> json) {
    return GolfCourseModel(
      id: json['id'] as String,
      nameKr: json['name_kr'] as String,
      nameEn: json['name_en'] as String,
      aliases: List<String>.from(json['aliases'] ?? []),
      regionDepth1: json['region_depth1'] as String,
      regionDepth2: json['region_depth2'] as String,
      lat: (json['location']['lat'] as num).toDouble(),
      lon: (json['location']['lon'] as num).toDouble(),
      courseType: json['course_type'] as String?,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_kr': nameKr,
      'name_en': nameEn,
      'aliases': aliases,
      'region_depth1': regionDepth1,
      'region_depth2': regionDepth2,
      'location': {'lat': lat, 'lon': lon},
      'course_type': courseType,
    };
  }
}
