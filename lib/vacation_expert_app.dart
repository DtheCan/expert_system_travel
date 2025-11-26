import 'package:flutter/material.dart';
import 'data/expert_system_data.dart';
import 'logic/expert_system.dart';
import 'models/country.dart';
import 'models/answer.dart';

class VacationExpertApp extends StatefulWidget {
  const VacationExpertApp({super.key});

  @override
  State<VacationExpertApp> createState() => _VacationExpertAppState();
}

class _VacationExpertAppState extends State<VacationExpertApp> {
  late ExpertSystem expertSystem;
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    expertSystem = ExpertSystem(
      questions: ExpertSystemData.getQuestions(),
      additionalQuestions: ExpertSystemData.getAdditionalQuestions(),
      countries: ExpertSystemData.countries,
    );
  }

  void _restartQuiz() {
    setState(() {
      expertSystem.reset();
      results.clear();
    });
  }

  Widget _buildUserAnswersAnalysis() {
    final userAnswers = expertSystem.userAnswers;
    final totalQuestions = expertSystem.totalQuestions;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Анализ ваших ответов',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildAnalysisRow('Всего вопросов', '$totalQuestions'),
            _buildAnalysisRow('Отвечено вопросов', '${userAnswers.length}'),
            _buildAnalysisRow('Тип отдыха', _getUserPreference('q1')),
            _buildAnalysisRow(
              'Предпочитаемый климат',
              _getUserPreference('q2'),
            ),
            _buildAnalysisRow('Бюджет поездки', _getUserPreference('q3')),
            if (userAnswers.length > 5) ...[
              _buildAnalysisRow('Тип питания', _getUserPreference('q6')),
              _buildAnalysisRow('Размещение', _getUserPreference('q7')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  String _getUserPreference(String questionId) {
    final answer = expertSystem.userAnswers.firstWhere(
      (ua) => ua['questionId'] == questionId,
      orElse: () => {},
    );
    if (answer.isNotEmpty) {
      return (answer['answer'] as Answer).text;
    }
    return 'Не указано';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Экспертная система выбора страны отдыха',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Куда поехать отдыхать?'),
          backgroundColor: Colors.blue[700],
          actions: [
            if (expertSystem.userAnswers.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.restart_alt),
                onPressed: _restartQuiz,
                tooltip: 'Начать заново',
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (results.isNotEmpty) {
      return _buildDetailedResultsScreen();
    } else if (expertSystem.isComplete) {
      return _buildFinalScreen();
    } else if (expertSystem.currentQuestion != null) {
      return _buildQuestionScreen(); // Все вопросы идут подряд
    } else {
      return _buildErrorScreen();
    }
  }

  Widget _buildQuestionScreen() {
    final question = expertSystem.currentQuestion;
    if (question == null) return _buildErrorScreen();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Прогресс бар - уже корректно работает
          LinearProgressIndicator(
            value:
                expertSystem.currentQuestionIndex / expertSystem.totalQuestions,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 20),

          // Текст вопроса - ОБНОВИТЬ для отображения типа вопросов
          Text(
            _getQuestionTypeText(), // ← НОВЫЙ МЕТОД
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),

          Text(
            question.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30), // ← ДОБАВИТЬ этот отступ
          // ДОБАВИТЬ ЭТУ ЧАСТЬ - варианты ответов
          Expanded(
            child: ListView.builder(
              itemCount: question.answers.length,
              itemBuilder: (context, index) {
                final answer = question.answers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      answer.text,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      setState(() {
                        expertSystem.addAnswer(question.id, answer);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getQuestionTypeText() {
    final currentIndex = expertSystem.currentQuestionIndex;
    final totalQuestions = expertSystem.totalQuestions;

    return 'Вопрос ${currentIndex + 1} из $totalQuestions';
  }

  Widget _buildFinalScreen() {
    final topCountries = expertSystem.getTopCountries(count: 3);
    final totalQuestions = expertSystem.totalQuestions;
    final answeredQuestions = expertSystem.userAnswers.length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Рекомендация готова!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Text(
            'На основе ваших ответов на $answeredQuestions из $totalQuestions вопросов:',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          Expanded(
            child: ListView.builder(
              itemCount: topCountries.length,
              itemBuilder: (context, index) {
                final result = topCountries[index];
                final country = result['country'] as Country;
                final percentage = result['matchPercentage'] as double;
                final score = result['score'] as double;
                final maxScore = result['maxPossibleScore'] as double;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColorByPercentage(percentage),
                      child: Text(
                        '${percentage.toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      country.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(country.description),
                        const SizedBox(height: 4),
                        Text(
                          'Совпадение: ${score.toStringAsFixed(1)}/${maxScore.toStringAsFixed(1)} баллов',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      setState(() {
                        // СОХРАНЯЕМ ВСЕ ДАННЫЕ ДЛЯ ДЕТАЛЬНОГО ПРОСМОТРА
                        results = [
                          {
                            'country': country,
                            'matchPercentage': percentage,
                            'score': score,
                            'maxPossibleScore': maxScore,
                          },
                        ];
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _restartQuiz,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Пройти тест заново'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ДОБАВЛЯЕМ РАСШИРЕННЫЙ ЭКРАН РЕЗУЛЬТАТОВ
  Widget _buildDetailedResultsScreen() {
    // ИСПОЛЬЗУЕМ ПЕРВЫЙ ЭЛЕМЕНТ ИЗ RESULTS, А НЕ TOPCOUNTRIES
    final result = results.first;
    final country = result['country'] as Country;
    final percentage = result['matchPercentage'] as double;
    final score = result['score'] as double;
    final maxScore = result['maxPossibleScore'] as double;
    final totalQuestions = expertSystem.totalQuestions;
    final answeredQuestions = expertSystem.userAnswers.length;

    // ПОЛУЧАЕМ ВСЕ СТРАНЫ ДЛЯ АЛЬТЕРНАТИВНЫХ ВАРИАНТОВ
    final allCountries = expertSystem.getTopCountries(count: 5);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и основная информация
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: _getColorByPercentage(percentage),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${percentage.toInt()}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${score.toStringAsFixed(1)}/$maxScore',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  country.name,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'На основе $answeredQuestions из $totalQuestions вопросов',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 5),
                Text(
                  'Идеальное совпадение с вашими предпочтениями!',
                  style: TextStyle(fontSize: 16, color: Colors.green[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Анализ ответов
          _buildUserAnswersAnalysis(),
          const SizedBox(height: 20),

          // Детальная информация о стране
          _buildCountryDetailSection(country),
          const SizedBox(height: 20),

          // Рекомендации
          _buildRecommendations(country),
          const SizedBox(height: 20),

          // Альтернативные варианты (ПЕРЕДАЕМ ALLCOUNTRIES)
          _buildAlternativeOptions(allCountries),
          const SizedBox(height: 30),

          // Кнопки действий
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCountryDetailSection(Country country) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Подробности о стране',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildDetailRow(
              '🌡️',
              'Средняя температура',
              '${country.averageTemperature}°C',
            ),
            _buildDetailRow('📅', 'Лучший сезон', country.bestSeason),
            _buildDetailRow('💰', 'Уровень цен', _getPriceLevel(country.name)),
            _buildDetailRow(
              '🕒',
              'Разница во времени',
              _getTimeDifference(country.name),
            ),
            _buildDetailRow('✈️', 'Перелет', '${country.flightTime} часов'),
            _buildDetailRow(
              '📝',
              'Виза',
              country.visaRequired ? 'Требуется' : 'Не требуется',
            ),
            _buildDetailRow(
              '⭐',
              'Популярность',
              '${(country.popularity * 100).toInt()}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String emoji, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeOptions(List<Map<String, dynamic>> topCountries) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Альтернативные варианты',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...topCountries.skip(1).take(2).map((result) {
              final country = result['country'] as Country;
              final percentage = result['matchPercentage'] as double;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColorByPercentage(percentage),
                  child: Text(
                    '${percentage.toInt()}%',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                title: Text(country.name),
                subtitle: Text('Совпадение: ${percentage.toInt()}%'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  setState(() {
                    // ДОБАВЛЯЕМ ВСЕ ДАННЫЕ О ВЫБРАННОЙ СТРАНЕ
                    results = [
                      {
                        'country': country,
                        'matchPercentage': percentage,
                        'score': result['score'],
                        'maxPossibleScore': result['maxPossibleScore'],
                      },
                    ];
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(Country country) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Наши рекомендации',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildRecommendationItem(
              '🏨',
              'Лучшие отели',
              _getHotelsRecommendation(country.name),
            ),
            _buildRecommendationItem(
              '🍽️',
              'Где поесть',
              _getRestaurantsRecommendation(country.name),
            ),
            _buildRecommendationItem(
              '🎯',
              'Что посмотреть',
              _getSightsRecommendation(country.name),
            ),
            _buildRecommendationItem(
              '💡',
              'Советы',
              _getTipsRecommendation(country.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String emoji, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                // ВОЗВРАЩАЕМСЯ К ОСНОВНЫМ РЕЗУЛЬТАТАМ
                results.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Вернуться к результатам'),
          ),
        ),
      ],
    );
  }

  // Вспомогательные методы
  Color _getColorByPercentage(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getPriceLevel(String country) {
    final prices = {
      'Швейцария': 'Высокий',
      'Франция': 'Выше среднего',
      'Япония': 'Выше среднего',
      'Италия': 'Средний',
      'Испания': 'Средний',
      'Египет': 'Низкий',
    };
    return prices[country] ?? 'Средний';
  }

  String _getTimeDifference(String country) {
    final differences = {
      'Египет': '-1 час',
      'Испания': '-2 часа',
      'Франция': '-2 часа',
      'Италия': '-2 часа',
      'Швейцария': '-2 часа',
      'Япония': '+6 часов',
    };
    return differences[country] ?? '0 часов';
  }

  String _getHotelsRecommendation(String country) {
    final recommendations = {
      'Египет': 'Отели в Хургаде и Шарм-эль-Шейхе с системой "все включено"',
      'Испания': 'Бутик-отели в Барселоне и курортные комплексы в Коста-Брава',
      'Франция': 'Отели в центре Парижа или шале в Альпах',
      'Италия': 'Исторические отели в Риме и Венеции',
      'Япония': 'Рёканы (традиционные гостиницы) и современные отели в Токио',
      'Швейцария': 'Горнолыжные курорты в Церматте и Давосе',
    };
    return recommendations[country] ?? 'Разнообразные варианты размещения';
  }

  String _getRestaurantsRecommendation(String country) {
    final recommendations = {
      'Египет': 'Рестораны с восточной кухней и морепродуктами',
      'Испания': 'Тапас-бары и рестораны паэльи',
      'Франция': 'Мишленовские рестораны и уютные бистро',
      'Италия': 'Траттории с пастой и пиццей, джелатерии',
      'Япония': 'Суши-бары, раменные и рестораны темпуры',
      'Швейцария': 'Рестораны с фондю и раклетом',
    };
    return recommendations[country] ??
        'Местная кухня и интернациональные рестораны';
  }

  String _getSightsRecommendation(String country) {
    final recommendations = {
      'Египет': 'Пирамиды Гизы, Луксор, дайвинг в Красном море',
      'Испания': 'Саграда Фамилия, Альгамбра, побережье Коста-Брава',
      'Франция': 'Эйфелева башня, Лувр, Лазурный берег',
      'Италия': 'Колизей, Венеция, Флоренция, побережье Амальфи',
      'Япония': 'Гора Фудзи, Киото, Токио, храмы и сады',
      'Швейцария': 'Альпы, Женевское озеро, горнолыжные курорты',
    };
    return recommendations[country] ??
        'Исторические и природные достопримечательности';
  }

  String _getTipsRecommendation(String country) {
    final tips = {
      'Египет': 'Брать с собой солнцезащитные средства, уважать местные обычаи',
      'Испания': 'Посещать сиесту, пробовать местные вина',
      'Франция':
          'Изучить базовые фразы на французском, бронировать столики заранее',
      'Италия': 'Избегать туристических ловушек, пробовать региональную кухню',
      'Япония':
          'Изучить правила этикета, пользоваться общественным транспортом',
      'Швейцария': 'Планировать бюджет, использовать Swiss Travel Pass',
    };
    return tips[country] ?? 'Изучите местные обычаи и правила поведения';
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 20),
          const Text('Произошла ошибка', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _restartQuiz,
            child: const Text('Начать заново'),
          ),
        ],
      ),
    );
  }
}
