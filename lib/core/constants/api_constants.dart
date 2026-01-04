/// Constantes pour les APIs externes
class ApiConstants {
  ApiConstants._();

  // API Football (api-football.com)
  static const String footballBaseUrl = 'https://v3.football.api-sports.io';
  static const String footballApiKeyHeader = 'x-apisports-key';

  // ID de la compétition CAN 2025
  static const int afconLeagueId = 6; // AFCON
  static const int afconSeason = 2025;

  // Endpoints Football
  static const String endpointFixtures = '/fixtures';
  static const String endpointStandings = '/standings';
  static const String endpointTeams = '/teams';
  static const String endpointPlayers = '/players';
  static const String endpointStatistics = '/fixtures/statistics';
  static const String endpointEvents = '/fixtures/events';
  static const String endpointLineups = '/fixtures/lineups';
  static const String endpointH2H = '/fixtures/headtohead';
  static const String endpointTopScorers = '/players/topscorers';
  static const String endpointTopAssists = '/players/topassists';
  static const String endpointSquads = '/players/squads';
  static const String endpointCoaches = '/coachs';
  static const String endpointVenues = '/venues';
  static const String endpointInjuries = '/injuries';
  static const String endpointPredictions = '/predictions';

  // GNews API (supporte CORS)
  static const String newsBaseUrl = 'https://gnews.io/api/v4';
  static const String endpointSearch = '/search';
  static const String endpointTopHeadlines = '/top-headlines';
  
  // Paramètres de recherche News par défaut
  static const String newsDefaultQuery = 'CAN 2025 football Afrique';
  static const String newsLanguage = 'fr';
  static const String newsCountry = 'ma';

  // Groq AI
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqModel = 'llama-3.3-70b-versatile';

  // Edge TTS (Microsoft Neural Voices - Gratuit)
  // Voix françaises disponibles : fr-FR-DeniseNeural, fr-FR-HenriNeural
  static const String edgeTtsVoice = 'fr-FR-DeniseNeural'; // Voix féminine naturelle
  static const String edgeTtsLanguage = 'fr-FR';

  // Headers communs
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

/// Clés API (chargées depuis .env)
class ApiKeys {
  ApiKeys._();

  static String get footballApiKey => _env['FOOTBALL_API_KEY'] ?? '';
  static String get gnewsApiKey => _env['GNEWS_API_KEY'] ?? '';
  static String get groqApiKey => _env['GROQ_API_KEY'] ?? '';

  // Les clés sont initialisées au démarrage via initKeys()
  static final Map<String, String> _env = {};

  static void initKeys(Map<String, String> env) {
    _env.addAll(env);
  }
}
