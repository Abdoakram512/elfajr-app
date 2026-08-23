import 'package:equatable/equatable.dart';

class TermsPrivacyModel extends Equatable {
  final String termsTitleAr;
  final String termsTitleEn;
  final List<String> termsListAr;
  final List<String> termsListEn;
  final String privacyTitleAr;
  final String privacyTitleEn;
  final List<String> privacyListAr;
  final List<String> privacyListEn;
  final String lastUpdatedAr;
  final String lastUpdatedEn;

  const TermsPrivacyModel({
    required this.termsTitleAr,
    required this.termsTitleEn,
    required this.termsListAr,
    required this.termsListEn,
    required this.privacyTitleAr,
    required this.privacyTitleEn,
    required this.privacyListAr,
    required this.privacyListEn,
    required this.lastUpdatedAr,
    required this.lastUpdatedEn,
  });

  String termsTitle(String lang) => lang == 'en'
      ? (termsTitleEn.isNotEmpty ? termsTitleEn : termsTitleAr)
      : (termsTitleAr.isNotEmpty ? termsTitleAr : termsTitleEn);

  List<String> termsList(String lang) => lang == 'en'
      ? (termsListEn.isNotEmpty ? termsListEn : termsListAr)
      : (termsListAr.isNotEmpty ? termsListAr : termsListEn);

  String privacyTitle(String lang) => lang == 'en'
      ? (privacyTitleEn.isNotEmpty ? privacyTitleEn : privacyTitleAr)
      : (privacyTitleAr.isNotEmpty ? privacyTitleAr : privacyTitleEn);

  List<String> privacyList(String lang) => lang == 'en'
      ? (privacyListEn.isNotEmpty ? privacyListEn : privacyListAr)
      : (privacyListAr.isNotEmpty ? privacyListAr : privacyListEn);

  String lastUpdated(String lang) => lang == 'en'
      ? (lastUpdatedEn.isNotEmpty ? lastUpdatedEn : lastUpdatedAr)
      : (lastUpdatedAr.isNotEmpty ? lastUpdatedAr : lastUpdatedEn);

  factory TermsPrivacyModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return TermsPrivacyModel(
      termsTitleAr: map['termsTitleAr'] as String? ?? map['termsTitle'] as String? ?? '',
      termsTitleEn: map['termsTitleEn'] as String? ?? '',
      termsListAr: parseList(map['termsListAr']).isNotEmpty
          ? parseList(map['termsListAr'])
          : parseList(map['termsList']),
      termsListEn: parseList(map['termsListEn']),
      privacyTitleAr: map['privacyTitleAr'] as String? ?? map['privacyTitle'] as String? ?? '',
      privacyTitleEn: map['privacyTitleEn'] as String? ?? '',
      privacyListAr: parseList(map['privacyListAr']).isNotEmpty
          ? parseList(map['privacyListAr'])
          : parseList(map['privacyList']),
      privacyListEn: parseList(map['privacyListEn']),
      lastUpdatedAr: map['lastUpdatedAr'] as String? ?? map['lastUpdated'] as String? ?? '',
      lastUpdatedEn: map['lastUpdatedEn'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        termsTitleAr,
        termsTitleEn,
        termsListAr,
        termsListEn,
        privacyTitleAr,
        privacyTitleEn,
        privacyListAr,
        privacyListEn,
        lastUpdatedAr,
        lastUpdatedEn,
      ];
}
