import '../models/question.dart';
import '../models/answer.dart';
import '../models/country.dart';

class ExpertSystem {
  final List<Question> questions;
  final List<Question> additionalQuestions;
  final List<Country> countries;
  Map<String, double> countryScores = {};
  List<Map<String, dynamic>> userAnswers = [];
  bool _showAdditionalQuestions = false;

  ExpertSystem({
    required this.questions,
    required this.additionalQuestions,
    required this.countries,
  }) {
    // Инициализируем счетчики для всех стран
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

    // Обновляем счетчики стран
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
    
    return topEntries.map((entry) {
      var country = countries.firstWhere((c) => c.name == entry.key);
      return {
        'country': country,
        'score': entry.value,
        'matchPercentage': (entry.value / (questions.length + additionalQuestions.length) * 100).clamp(0, 100),
      };
    }).toList();
  }

  void reset() {
    countryScores.clear();
    userAnswers.clear();
    _showAdditionalQuestions = false;
    for (var country in countries) {
      countryScores[country.name] = 0.0;
    }
  }

  bool get isMainComplete => userAnswers.length >= questions.length;
  bool get isAdditionalComplete => _showAdditionalQuestions && 
      userAnswers.length >= questions.length + additionalQuestions.length;
  bool get isComplete => isMainComplete && (!_showAdditionalQuestions || isAdditionalComplete);

  void showAdditionalQuestions() {
    _showAdditionalQuestions = true;
  }

  int get currentQuestionIndex => userAnswers.length;
  
  Question? get currentQuestion {
    if (userAnswers.length < questions.length) {
      return questions[userAnswers.length];
    } else if (_showAdditionalQuestions && 
               userAnswers.length < questions.length + additionalQuestions.length) {
      return additionalQuestions[userAnswers.length - questions.length];
    }
    return null;
  }

  int get totalQuestions => questions.length + 
      (_showAdditionalQuestions ? additionalQuestions.length : 0);
  
  bool get shouldShowAdditionalQuestions => 
      isMainComplete && !_showAdditionalQuestions && !isAdditionalComplete;
}