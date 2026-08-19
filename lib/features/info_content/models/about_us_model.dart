import 'package:equatable/equatable.dart';

class AboutUsModel extends Equatable {
  final String title;
  final String tagline;
  final String description;
  final String vision;
  final String mission;
  final List<String> values;
  final String email;
  final String phone;
  final String headquarters;
  final String version;

  const AboutUsModel({
    required this.title,
    required this.tagline,
    required this.description,
    required this.vision,
    required this.mission,
    required this.values,
    required this.email,
    required this.phone,
    required this.headquarters,
    required this.version,
  });

  factory AboutUsModel.fromMap(Map<String, dynamic> map) {
    List<String> parseValues(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return AboutUsModel(
      title: map['title'] as String? ?? 'منصة قُوت (QOUT)',
      tagline: map['tagline'] as String? ??
          'المنظومة الوطنية الموحدة لإدارة وتوزيع الدعم الغذائي والإغاثي الذكي',
      description: map['description'] as String? ?? '',
      vision: map['vision'] as String? ?? '',
      mission: map['mission'] as String? ?? '',
      values: parseValues(map['values']),
      email: map['email'] as String? ?? 'info@qout.org',
      phone: map['phone'] as String? ?? '8001234567',
      headquarters: map['headquarters'] as String? ?? 'الرياض، المملكة العربية السعودية',
      version: map['version'] as String? ?? '2.4.0',
    );
  }

  @override
  List<Object?> get props => [
        title,
        tagline,
        description,
        vision,
        mission,
        values,
        email,
        phone,
        headquarters,
        version,
      ];
}
