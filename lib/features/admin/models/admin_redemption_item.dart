import 'package:equatable/equatable.dart';

class AdminRedemptionItem extends Equatable {
  final String id;
  final String beneficiaryName;
  final String cardId;
  final String merchantName;
  final double amount;
  final int foodBaskets;
  final String city;
  final DateTime timestamp;

  const AdminRedemptionItem({
    required this.id,
    required this.beneficiaryName,
    required this.cardId,
    required this.merchantName,
    required this.amount,
    required this.foodBaskets,
    required this.city,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        beneficiaryName,
        cardId,
        merchantName,
        amount,
        foodBaskets,
        city,
        timestamp,
      ];
}
