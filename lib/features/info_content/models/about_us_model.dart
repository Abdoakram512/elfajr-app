import 'package:equatable/equatable.dart';

class AboutUsModel extends Equatable {
  final String titleAr;
  final String titleEn;
  final String taglineAr;
  final String taglineEn;
  final String descriptionAr;
  final String descriptionEn;
  final String visionAr;
  final String visionEn;
  final String missionAr;
  final String missionEn;
  final List<String> valuesAr;
  final List<String> valuesEn;
  final String email;
  final String phone;
  final String headquartersAr;
  final String headquartersEn;
  final String version;

  const AboutUsModel({
    required this.titleAr,
    required this.titleEn,
    required this.taglineAr,
    required this.taglineEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.visionAr,
    required this.visionEn,
    required this.missionAr,
    required this.missionEn,
    required this.valuesAr,
    required this.valuesEn,
    required this.email,
    required this.phone,
    required this.headquartersAr,
    required this.headquartersEn,
    required this.version,
  });

  String title(String lang) => lang == 'en' ? (titleEn.isNotEmpty ? titleEn : titleAr) : (titleAr.isNotEmpty ? titleAr : titleEn);
  String tagline(String lang) => lang == 'en' ? (taglineEn.isNotEmpty ? taglineEn : taglineAr) : (taglineAr.isNotEmpty ? taglineAr : taglineEn);
  String description(String lang) => lang == 'en' ? (descriptionEn.isNotEmpty ? descriptionEn : descriptionAr) : (descriptionAr.isNotEmpty ? descriptionAr : descriptionEn);
  String vision(String lang) => lang == 'en' ? (visionEn.isNotEmpty ? visionEn : visionAr) : (visionAr.isNotEmpty ? visionAr : visionEn);
  String mission(String lang) => lang == 'en' ? (missionEn.isNotEmpty ? missionEn : missionAr) : (missionAr.isNotEmpty ? missionAr : missionEn);
  List<String> values(String lang) => lang == 'en' ? (valuesEn.isNotEmpty ? valuesEn : valuesAr) : (valuesAr.isNotEmpty ? valuesAr : valuesEn);
  String headquarters(String lang) => lang == 'en' ? (headquartersEn.isNotEmpty ? headquartersEn : headquartersAr) : (headquartersAr.isNotEmpty ? headquartersAr : headquartersEn);

  factory AboutUsModel.fromMap(Map<String, dynamic> map) {
    List<String> parseValues(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return AboutUsModel(
      titleAr: map['titleAr'] as String? ?? map['title'] as String? ?? '',
      titleEn: map['titleEn'] as String? ?? '',
      taglineAr: map['taglineAr'] as String? ?? map['tagline'] as String? ?? '',
      taglineEn: map['taglineEn'] as String? ?? '',
      descriptionAr: map['descriptionAr'] as String? ?? map['description'] as String? ?? '',
      descriptionEn: map['descriptionEn'] as String? ?? '',
      visionAr: map['visionAr'] as String? ?? map['vision'] as String? ?? '',
      visionEn: map['visionEn'] as String? ?? '',
      missionAr: map['missionAr'] as String? ?? map['mission'] as String? ?? '',
      missionEn: map['missionEn'] as String? ?? '',
      valuesAr: parseValues(map['valuesAr']).isNotEmpty
          ? parseValues(map['valuesAr'])
          : parseValues(map['values']),
      valuesEn: parseValues(map['valuesEn']),
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      headquartersAr: map['headquartersAr'] as String? ?? map['headquarters'] as String? ?? '',
      headquartersEn: map['headquartersEn'] as String? ?? '',
      version: map['version'] as String? ?? '1.0.0',
    );
  }

  @override
  List<Object?> get props => [
        titleAr,
        titleEn,
        taglineAr,
        taglineEn,
        descriptionAr,
        descriptionEn,
        visionAr,
        visionEn,
        missionAr,
        missionEn,
        valuesAr,
        valuesEn,
        email,
        phone,
        headquartersAr,
        headquartersEn,
        version,
      ];
}
