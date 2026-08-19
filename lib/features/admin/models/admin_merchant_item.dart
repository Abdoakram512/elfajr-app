import 'package:equatable/equatable.dart';

class AdminMerchantItem extends Equatable {
  final String id;
  final String name;
  final String storeType;
  final String city;
  final String commercialReg;
  final int totalTransactions;
  final double totalDisbursed;
  final bool isActive;

  const AdminMerchantItem({
    required this.id,
    required this.name,
    required this.storeType,
    required this.city,
    required this.commercialReg,
    required this.totalTransactions,
    required this.totalDisbursed,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        storeType,
        city,
        commercialReg,
        totalTransactions,
        totalDisbursed,
        isActive,
      ];
}
