import '../models/about_us_model.dart';
import '../models/contact_support_model.dart';
import '../models/faq_model.dart';
import '../models/terms_privacy_model.dart';

abstract class InfoRepository {
  Future<AboutUsModel?> getAboutUs();
  Future<List<FaqItemModel>> getFaqs();
  Future<TermsPrivacyModel?> getTermsPrivacy();
  Future<ContactSupportModel?> getContactSupport();
}
