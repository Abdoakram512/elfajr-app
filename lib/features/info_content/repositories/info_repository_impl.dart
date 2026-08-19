import '../data_sources/info_remote_data_source.dart';
import '../models/about_us_model.dart';
import '../models/contact_support_model.dart';
import '../models/faq_model.dart';
import '../models/terms_privacy_model.dart';
import 'info_repository.dart';

class InfoRepositoryImpl implements InfoRepository {
  final InfoRemoteDataSource _remoteDataSource;

  InfoRepositoryImpl({
    required InfoRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<AboutUsModel?> getAboutUs() {
    return _remoteDataSource.getAboutUs();
  }

  @override
  Future<List<FaqItemModel>> getFaqs() {
    return _remoteDataSource.getFaqs();
  }

  @override
  Future<TermsPrivacyModel?> getTermsPrivacy() {
    return _remoteDataSource.getTermsPrivacy();
  }

  @override
  Future<ContactSupportModel?> getContactSupport() {
    return _remoteDataSource.getContactSupport();
  }
}
