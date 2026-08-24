import 'package:equatable/equatable.dart';
import '../../../../core/utils/firebase_parser_utils.dart';

class NationalityModel extends Equatable {
  final String id;
  final String name;
  final DateTime? createdAt;

  const NationalityModel({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory NationalityModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return NationalityModel(
      id: documentId ?? (map['id'] as String? ?? (map['name'] as String? ?? '')),
      name: map['name'] as String? ?? '',
      createdAt: FirebaseParserUtils.parseNullableDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, createdAt];
}
