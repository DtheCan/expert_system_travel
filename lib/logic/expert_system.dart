import '../models/question.dart';
import '../models/answer.dart';
import '../models/country.dart';

class ExpertSystem {
  final List<Question> questions;
  final List<Question> additionalQuestions;
  final List<Country> countries;
  Map<String, double> countryScores = {};
  List<Map<String, dynamic>> userAnswers = [];

  ExpertSystem({
    required this.questions,
    required this.additionalQuestions,
    required this.countries,
  }) {
    for (var country in countries) {
      countryScores[country.name] = 0.0;
    }
  }

  void addAnswer(String questionId, Answer answer) {
    userAnswers.add({
      'questionId': questionId,
      'answer': answer,
      'timestamp': DateTime.now(),
    });

    for (var entry in answer.countryScores.entries) {
      String countryName = entry.key;
      double score = entry.value;
      countryScores[countryName] = (countryScores[countryName] ?? 0.0) + score;
    }
  }

  List<Map<String, dynamic>> getTopCountries({int count = 3}) {
  var sortedEntries = countryScores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  var topEntries = sortedEntries.take(count).toList();
 
  // УЛУЧШЕННЫЙ РАСЧЕТ: максимальный возможный балл = количество вопросов
  double maxPossibleScore = totalQuestions.toDouble();
  
  return topEntries.map((entry) {
    var country = countries.firstWhere((c) => c.name == entry.key);
    double percentage = (entry.value / maxPossibleScore * 100).clamp(0, 100);
    
    return {
      'country': country,
      'score': entry.value,
      'matchPercentage': percentage,
      'maxPossibleScore': maxPossibleScore,
    };
  }).toList();
}

  void reset() {
    countryScores.clear();
    userAnswers.clear();
    for (var country in countries) {
      countryScores[country.name] = 0.0;
    }
  }

  bool get isComplete => userAnswers.length >= totalQuestions;

  int get currentQuestionIndex => userAnswers.length;
  
  Question? get currentQuestion {
    if (userAnswers.length < totalQuestions) {
      if (userAnswers.length < questions.length) {
        return questions[userAnswers.length];
      } else {
        int additionalIndex = userAnswers.length - questions.length;
        return additionalQuestions[additionalIndex];
      }
    }
    return null;
  }

  int get totalQuestions => questions.length + additionalQuestions.length;
}