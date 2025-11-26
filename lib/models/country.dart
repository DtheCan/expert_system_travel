class Country {
  final String name;
  final String description;
  final String imageUrl;
  final double averageTemperature;
  final String bestSeason;
  final bool visaRequired;
  final double flightTime;
  final double popularity;

  Country({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.averageTemperature,
    required this.bestSeason,
    required this.flightTime,
    required this.popularity,
    required this.visaRequired,
  });
}