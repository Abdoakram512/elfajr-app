import 'package:equatable/equatable.dart';
import '../models/admin_merchant_item.dart';

class AdminMerchantsState extends Equatable {
  final List<AdminMerchantItem> merchants;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const AdminMerchantsState({
    this.merchants = const [],
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

  AdminMerchantsState copyWith({
    List<AdminMerchantItem>? merchants,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminMerchantsState(
      merchants: merchants ?? this.merchants,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [merchants, searchQuery, isLoading, errorMessage];
}
