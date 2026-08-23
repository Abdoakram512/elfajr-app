import 'package:equatable/equatable.dart';

class AdminBeneficiaryItem extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String cardId;
  final bool isApproved;
  final bool isActive;
  final DateTime createdAt;

  const AdminBeneficiaryItem({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.cardId,
    required this.isApproved,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        city,
        cardId,
        isApproved,
        isActive,
        createdAt,
      ];
}
