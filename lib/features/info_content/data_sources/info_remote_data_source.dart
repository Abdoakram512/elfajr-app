import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/about_us_model.dart';
import '../models/contact_support_model.dart';
import '../models/faq_model.dart';
import '../models/terms_privacy_model.dart';

abstract class InfoRemoteDataSource {
  Future<AboutUsModel?> getAboutUs();
  Future<List<FaqItemModel>> getFaqs();
  Future<TermsPrivacyModel?> getTermsPrivacy();
  Future<ContactSupportModel?> getContactSupport();
}

class InfoRemoteDataSourceImpl implements InfoRemoteDataSource {
  final FirebaseFirestore _firestore;

  InfoRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AboutUsModel?> getAboutUs() async {
    final doc = await _firestore.collection('content').doc('about_us').get();
    if (doc.exists && doc.data() != null) {
      return AboutUsModel.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<FaqItemModel>> getFaqs() async {
    final doc = await _firestore.collection('content').doc('faqs').get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final rawItems = data['items'];
      if (rawItems is List) {
        return rawItems.map((item) {
          if (item is Map<String, dynamic>) {
            return FaqItemModel.fromMap(item);
          }
          return FaqItemModel.fromMap(Map<String, dynamic>.from(item as Map));
        }).toList();
      }
    }
    return <FaqItemModel>[];
  }

  @override
  Future<TermsPrivacyModel?> getTermsPrivacy() async {
    final doc =
        await _firestore.collection('content').doc('terms_privacy').get();
    if (doc.exists && doc.data() != null) {
      return TermsPrivacyModel.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<ContactSupportModel?> getContactSupport() async {
    final doc =
        await _firestore.collection('content').doc('contact_support').get();
    if (doc.exists && doc.data() != null) {
      return ContactSupportModel.fromMap(doc.data()!);
    }
    return null;
  }
}
