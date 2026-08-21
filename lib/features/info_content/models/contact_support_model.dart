import 'package:equatable/equatable.dart';

class ContactSupportModel extends Equatable {
  final String hotline;
  final String emergencyPhone;
  final String supportEmail;
  final String partnersEmail;
  final String workingHours;
  final String address;
  final String socialTwitter;
  final String socialLinkedin;

  const ContactSupportModel({
    required this.hotline,
    required this.emergencyPhone,
    required this.supportEmail,
    required this.partnersEmail,
    required this.workingHours,
    required this.address,
    required this.socialTwitter,
    required this.socialLinkedin,
  });

  factory ContactSupportModel.fromMap(Map<String, dynamic> map) {
    return ContactSupportModel(
      hotline: map['hotline'] as String? ?? '19000',
      emergencyPhone: map['emergencyPhone'] as String? ?? '+201000000000',
      supportEmail: map['supportEmail'] as String? ?? 'support@alfajr.org',
      partnersEmail: map['partnersEmail'] as String? ?? 'merchants@alfajr.org',
      workingHours: map['workingHours'] as String? ?? 'السبت - الخميس: 9:00 ص - 9:00 م',
      address: map['address'] as String? ?? 'جمهورية مصر العربية - المقر الإداري المركزي',
      socialTwitter: map['socialTwitter'] as String? ?? '@AlFajrCharity',
      socialLinkedin: map['socialLinkedin'] as String? ?? 'company/alfajr-foundation',
    );
  }

  @override
  List<Object?> get props => [
        hotline,
        emergencyPhone,
        supportEmail,
        partnersEmail,
        workingHours,
        address,
        socialTwitter,
        socialLinkedin,
      ];
}
