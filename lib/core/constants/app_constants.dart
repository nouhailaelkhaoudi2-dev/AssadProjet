/// Constantes générales de l'application CAN 2025
class AppConstants {
  AppConstants._();

  // Informations de l'application
  static const String appName = 'CAN 2025 Morocco';
  static const String appVersion = '1.0.0';

  // Dates du tournoi
  static const String tournamentStartDate = '2025-12-21';
  static const String tournamentEndDate = '2026-01-18';

  // Pays hôte
  static const String hostCountry = 'Maroc';
  static const List<String> hostCities = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fès',
    'Tanger',
    'Agadir',
  ];

  // Nombre d'équipes
  static const int totalTeams = 24;
  static const int totalGroups = 6;

  // URL Billetterie officielle
  static const String ticketingUrl = 'https://tickets.cafonline.com/fr';

  // Langues supportées
  static const String defaultLanguage = 'fr';
  static const List<String> supportedLanguages = ['fr', 'en', 'ar'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int newsPageSize = 15;

  // Cache
  static const int cacheMaxAge = 300; // 5 minutes en secondes
  static const int newsCacheMaxAge = 600; // 10 minutes

  // Timeouts
  static const int connectionTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000;

  // IA / Chatbot
  static const int maxChatHistoryLength = 50;
  static const int maxTokensPerResponse = 2048;
}
