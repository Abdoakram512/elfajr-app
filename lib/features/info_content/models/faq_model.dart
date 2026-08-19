import 'package:equatable/equatable.dart';

class FaqItemModel extends Equatable {
  final String id;
  final String category;
  final String question;
  final String answer;

  const FaqItemModel({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });

  factory FaqItemModel.fromMap(Map<String, dynamic> map) {
    return FaqItemModel(
      id: map['id'] as String? ?? '',
      category: map['category'] as String? ?? 'عام',
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, category, question, answer];
}
