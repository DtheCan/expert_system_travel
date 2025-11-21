import 'package:flutter/material.dart';
import 'data/expert_system_data.dart';
import 'logic/expert_system.dart';
import 'models/country.dart';

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
      questions: ExpertSystemData.getQuestions(), // ИЗМЕНИТЕ ЗДЕСЬ
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
    } else if (expertSystem.shouldShowAdditionalQuestions) {
      return _buildAdditionalQuestionsPrompt();
    } else {
      return _buildQuestionScreen();
    }
  }

  Widget _buildAdditionalQuestionsPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Хотите уточнить рекомендацию?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          const Text(
            'Ответьте на 2 дополнительных вопроса для более точного подбора страны',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      expertSystem.showAdditionalQuestions();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Да, продолжить'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      // Пропускаем дополнительные вопросы
                    });
                  },
                  child: const Text('Показать результат'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = expertSystem.currentQuestion;
    if (question == null) return _buildErrorScreen();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Прогресс бар
          LinearProgressIndicator(
            value:
                expertSystem.currentQuestionIndex / expertSystem.totalQuestions,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 20),

          // Текст вопроса
          Text(
            'Вопрос ${expertSystem.currentQuestionIndex + 1} из ${expertSystem.totalQuestions}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),

          Text(
            question.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Варианты ответов
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

  Widget _buildFinalScreen() {
    final topCountries = expertSystem.getTopCountries(count: 3);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Рекомендация готов!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'На основе ваших ответов мы подобрали лучшие варианты:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        '${(percentage).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      country.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(country.description),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      setState(() {
                        results = [result];
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
    final topCountries = expertSystem.getTopCountries(count: 5);
    final topCountry = topCountries.first;
    final country = topCountry['country'] as Country;
    final percentage = topCountry['matchPercentage'] as double;

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
                  child: Text(
                    '${percentage.toInt()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                  'Идеальное совпадение с вашими предпочтениями!',
                  style: TextStyle(fontSize: 16, color: Colors.green[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Детальная информация о стране
          _buildCountryDetailSection(country),
          const SizedBox(height: 20),

          // Анализ по критериям
          _buildCriteriaAnalysis(),
          const SizedBox(height: 20),

          // Альтернативные варианты
          _buildAlternativeOptions(topCountries),
          const SizedBox(height: 20),

          // Рекомендации
          _buildRecommendations(country),
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
            _buildDetailRow('✈️', 'Перелет', _getFlightInfo(country.name)),
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

  Widget _buildCriteriaAnalysis() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Анализ ваших предпочтений',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildCriteriaRow('Тип отдыха', 'Пляжный', 85),
            _buildCriteriaRow('Климат', 'Жаркий', 90),
            _buildCriteriaRow('Бюджет', 'Средний', 75),
            _buildCriteriaRow('Активности', 'Экскурсии', 80),
            _buildCriteriaRow('Питание', 'Все включено', 70),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaRow(String criterion, String preference, int match) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$criterion: $preference'),
              Text(
                '$match%',
                style: TextStyle(
                  color: _getColorByPercentage(match.toDouble()),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: match / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorByPercentage(match.toDouble()),
            ),
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
                    results = [result];
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
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Действие для поиска туров
            },
            icon: const Icon(Icons.search),
            label: const Text('Найти туры'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                results.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Новый подбор'),
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

  String _getFlightInfo(String country) {
    final flights = {
      'Египет': '4-5 часов',
      'Испания': '5-6 часов',
      'Франция': '4 часа',
      'Италия': '4 часа',
      'Швейцария': '4 часа',
      'Япония': '10-12 часов',
    };
    return flights[country] ?? '3-4 часа';
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
