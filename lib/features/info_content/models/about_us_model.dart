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
      title: map['title'] as String? ?? 'مؤسسة الفجر الخيرية (Al-Fajr)',
      tagline: map['tagline'] as String? ??
          'المنظومة الموحدة لإدارة وتوزيع الدعم الغذائي الذكي المعتمد',
      description: map['description'] as String? ?? 'منظومة رقمية متكاملة لرقمنة توزيع الإعانات والمساعدات الغذائية للمستحقين.',
      vision: map['vision'] as String? ?? 'الريادة والشفافية التامة في العمل الإنساني والوصول الموثق لكافة الأسر المتعففة.',
      mission: map['mission'] as String? ?? 'توفير منظومة ذكية تعتمد البطاقات المشفرة لضمان كرامة المستفيد وسرعة الصرف.',
      values: parseValues(map['values']).isNotEmpty
          ? parseValues(map['values'])
          : ['الشفافية المطلقة', 'حفظ كرامة المستفيد', 'الأمانة المحاسبية', 'السرعة والتوثيق الميداني'],
      email: map['email'] as String? ?? 'info@alfajr.org',
      phone: map['phone'] as String? ?? '19000',
      headquarters: map['headquarters'] as String? ?? 'جمهورية مصر العربية - المقر الإداري المركزي',
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
