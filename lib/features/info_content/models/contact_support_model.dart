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
      hotline: map['hotline'] as String? ?? '8001234567',
      emergencyPhone: map['emergencyPhone'] as String? ?? '+966 11 234 5678',
      supportEmail: map['supportEmail'] as String? ?? 'support@qout.org',
      partnersEmail: map['partnersEmail'] as String? ?? 'merchants@qout.org',
      workingHours: map['workingHours'] as String? ?? '24/7',
      address: map['address'] as String? ?? 'الرياض، المملكة العربية السعودية',
      socialTwitter: map['socialTwitter'] as String? ?? '@QoutApp',
      socialLinkedin: map['socialLinkedin'] as String? ?? 'company/qout-platform',
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
