import 'package:equatable/equatable.dart';

class ContactSupportModel extends Equatable {
  final String hotline;
  final String emergencyPhone;
  final String supportEmail;
  final String partnersEmail;
  final String workingHoursAr;
  final String workingHoursEn;
  final String addressAr;
  final String addressEn;
  final String socialTwitter;
  final String socialLinkedin;

  const ContactSupportModel({
    required this.hotline,
    required this.emergencyPhone,
    required this.supportEmail,
    required this.partnersEmail,
    required this.workingHoursAr,
    required this.workingHoursEn,
    required this.addressAr,
    required this.addressEn,
    required this.socialTwitter,
    required this.socialLinkedin,
  });

  String workingHours(String lang) => lang == 'en'
      ? (workingHoursEn.isNotEmpty ? workingHoursEn : workingHoursAr)
      : (workingHoursAr.isNotEmpty ? workingHoursAr : workingHoursEn);

  String address(String lang) => lang == 'en'
      ? (addressEn.isNotEmpty ? addressEn : addressAr)
      : (addressAr.isNotEmpty ? addressAr : addressEn);

  factory ContactSupportModel.fromMap(Map<String, dynamic> map) {
    return ContactSupportModel(
      hotline: map['hotline'] as String? ?? '',
      emergencyPhone: map['emergencyPhone'] as String? ?? '',
      supportEmail: map['supportEmail'] as String? ?? '',
      partnersEmail: map['partnersEmail'] as String? ?? '',
      workingHoursAr: map['workingHoursAr'] as String? ?? map['workingHours'] as String? ?? '',
      workingHoursEn: map['workingHoursEn'] as String? ?? '',
      addressAr: map['addressAr'] as String? ?? map['address'] as String? ?? '',
      addressEn: map['addressEn'] as String? ?? '',
      socialTwitter: map['socialTwitter'] as String? ?? '',
      socialLinkedin: map['socialLinkedin'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        hotline,
        emergencyPhone,
        supportEmail,
        partnersEmail,
        workingHoursAr,
        workingHoursEn,
        addressAr,
        addressEn,
        socialTwitter,
        socialLinkedin,
      ];
}
