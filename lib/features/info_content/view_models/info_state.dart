import 'package:equatable/equatable.dart';
import '../models/about_us_model.dart';
import '../models/contact_support_model.dart';
import '../models/faq_model.dart';
import '../models/terms_privacy_model.dart';

class InfoState extends Equatable {
  final AboutUsModel? aboutUs;
  final List<FaqItemModel> faqs;
  final String selectedFaqCategory;
  final TermsPrivacyModel? termsPrivacy;
  final ContactSupportModel? contactSupport;
  final bool isLoading;
  final String? errorMessage;

  const InfoState({
    this.aboutUs,
    this.faqs = const [],
    this.selectedFaqCategory = 'all',
    this.termsPrivacy,
    this.contactSupport,
    this.isLoading = false,
    this.errorMessage,
  });

  List<String> availableFaqCategories(String lang) {
    final set = <String>{'all'};
    for (final f in faqs) {
      final cat = f.category(lang);
      if (cat.isNotEmpty) {
        set.add(cat);
      }
    }
    return set.toList();
  }

  List<FaqItemModel> filteredFaqs(String lang) {
    if (selectedFaqCategory == 'all' || selectedFaqCategory == 'الكل') {
      return faqs;
    }
    return faqs.where((f) => f.category(lang) == selectedFaqCategory || f.categoryAr == selectedFaqCategory || f.categoryEn == selectedFaqCategory).toList();
  }

  InfoState copyWith({
    AboutUsModel? aboutUs,
    List<FaqItemModel>? faqs,
    String? selectedFaqCategory,
    TermsPrivacyModel? termsPrivacy,
    ContactSupportModel? contactSupport,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InfoState(
      aboutUs: aboutUs ?? this.aboutUs,
      faqs: faqs ?? this.faqs,
      selectedFaqCategory: selectedFaqCategory ?? this.selectedFaqCategory,
      termsPrivacy: termsPrivacy ?? this.termsPrivacy,
      contactSupport: contactSupport ?? this.contactSupport,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        aboutUs,
        faqs,
        selectedFaqCategory,
        termsPrivacy,
        contactSupport,
        isLoading,
        errorMessage,
      ];
}
