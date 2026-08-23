import 'package:equatable/equatable.dart';
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
    final q = searchQuery.toLowerCase().trim();
    return merchants.where((m) {
      return m.name.toLowerCase().contains(q) ||
          m.city.toLowerCase().contains(q) ||
          m.storeType.toLowerCase().contains(q);
    }).toList();
  }

  List<AdminBeneficiaryItem> get filteredBeneficiaries {
    if (searchQuery.trim().isEmpty) return beneficiaries;
    final q = searchQuery.toLowerCase().trim();
    return beneficiaries.where((b) {
      return b.name.toLowerCase().contains(q) ||
          b.email.toLowerCase().contains(q) ||
          b.phone.toLowerCase().contains(q) ||
          b.city.toLowerCase().contains(q) ||
          b.cardId.toLowerCase().contains(q);
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

