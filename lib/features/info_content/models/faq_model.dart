import 'package:equatable/equatable.dart';

class FaqItemModel extends Equatable {
  final String id;
  final String categoryAr;
  final String categoryEn;
  final String questionAr;
  final String questionEn;
  final String answerAr;
  final String answerEn;

  const FaqItemModel({
    required this.id,
    required this.categoryAr,
    required this.categoryEn,
    required this.questionAr,
    required this.questionEn,
    required this.answerAr,
    required this.answerEn,
  });

  String category(String lang) => lang == 'en'
      ? (categoryEn.isNotEmpty ? categoryEn : categoryAr)
      : (categoryAr.isNotEmpty ? categoryAr : categoryEn);

  String question(String lang) => lang == 'en'
      ? (questionEn.isNotEmpty ? questionEn : questionAr)
      : (questionAr.isNotEmpty ? questionAr : questionEn);

  String answer(String lang) => lang == 'en'
      ? (answerEn.isNotEmpty ? answerEn : answerAr)
      : (answerAr.isNotEmpty ? answerAr : answerEn);

  factory FaqItemModel.fromMap(Map<String, dynamic> map) {
    return FaqItemModel(
      id: map['id'] as String? ?? '',
      categoryAr: map['categoryAr'] as String? ?? map['category'] as String? ?? '',
      categoryEn: map['categoryEn'] as String? ?? '',
      questionAr: map['questionAr'] as String? ?? map['question'] as String? ?? '',
      questionEn: map['questionEn'] as String? ?? '',
      answerAr: map['answerAr'] as String? ?? map['answer'] as String? ?? '',
      answerEn: map['answerEn'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryAr,
        categoryEn,
        questionAr,
        questionEn,
        answerAr,
        answerEn,
      ];
}
