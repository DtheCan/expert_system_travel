import 'answer.dart';

class Question {
  final String id;
  final String text;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.text,
    required this.answers,
  });
}