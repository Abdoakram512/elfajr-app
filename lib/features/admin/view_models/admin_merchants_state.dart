import 'package:equatable/equatable.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../models/admin_beneficiary_item.dart';
import '../models/admin_merchant_item.dart';

class AdminMerchantsState extends Equatable {
  final List<AdminMerchantItem> merchants;
  final List<AdminBeneficiaryItem> beneficiaries;
  final int selectedSegment; // 0 = Merchants, 1 = Beneficiaries
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const AdminMerchantsState({
    this.merchants = const [],
    this.beneficiaries = const [],
    this.selectedSegment = 0,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  List<AdminMerchantItem> get filteredMerchants {
    if (searchQuery.trim().isEmpty) return merchants;
    return merchants.where((m) {
      return ArabicNormalizer.matches(m.name, searchQuery) ||
          ArabicNormalizer.matches(m.city, searchQuery) ||
          ArabicNormalizer.matches(m.storeType, searchQuery);
    }).toList();
  }

  List<AdminBeneficiaryItem> get filteredBeneficiaries {
    if (searchQuery.trim().isEmpty) return beneficiaries;
    return beneficiaries.where((b) {
      return ArabicNormalizer.matches(b.name, searchQuery) ||
          ArabicNormalizer.matches(b.email, searchQuery) ||
          ArabicNormalizer.matches(b.phone, searchQuery) ||
          ArabicNormalizer.matches(b.city, searchQuery) ||
          ArabicNormalizer.matches(b.cardId, searchQuery);
    }).toList();
  }

  AdminMerchantsState copyWith({
    List<AdminMerchantItem>? merchants,
    List<AdminBeneficiaryItem>? beneficiaries,
    int? selectedSegment,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminMerchantsState(
      merchants: merchants ?? this.merchants,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      selectedSegment: selectedSegment ?? this.selectedSegment,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        merchants,
        beneficiaries,
        selectedSegment,
        searchQuery,
        isLoading,
        errorMessage,
      ];
}

