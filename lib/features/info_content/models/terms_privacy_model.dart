import 'package:equatable/equatable.dart';

class TermsPrivacyModel extends Equatable {
  final String termsTitle;
  final List<String> termsList;
  final String privacyTitle;
  final List<String> privacyList;
  final String lastUpdated;

  const TermsPrivacyModel({
    required this.termsTitle,
    required this.termsList,
    required this.privacyTitle,
    required this.privacyList,
    required this.lastUpdated,
  });

  factory TermsPrivacyModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return TermsPrivacyModel(
      termsTitle: map['termsTitle'] as String? ?? 'شروط الاستخدام',
      termsList: parseList(map['termsList']),
      privacyTitle: map['privacyTitle'] as String? ?? 'سياسة الخصوصية',
      privacyList: parseList(map['privacyList']),
      lastUpdated: map['lastUpdated'] as String? ?? '2026',
    );
  }

  @override
  List<Object?> get props => [
        termsTitle,
        termsList,
        privacyTitle,
        privacyList,
        lastUpdated,
      ];
}
