import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/football_api_service.dart';
import '../services/news_api_service.dart';
import '../services/groq_service.dart';
import '../../features/matches/domain/entities/match.dart';
import '../../features/news/domain/entities/news_article.dart';
import 'favorite_team_provider.dart';

// ============== SERVICES ==============

/// Provider pour le service Football API
final footballServiceProvider = Provider<FootballApiService>((ref) {
  return FootballApiService();
});

/// Provider pour le service News API
final newsServiceProvider = Provider<NewsApiService>((ref) {
  return NewsApiService();
});

/// Provider pour le service Groq AI
final groqServiceProvider = Provider<GroqService>((ref) {
  return GroqService();
});

// ============== MATCHES ==============

/// Provider pour les matchs à venir
final upcomingMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  return service.getUpcomingMatches(limit: 10);
});

/// Provider pour les matchs du jour
final todayMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  return service.getTodayMatches();
});

/// Provider pour les matchs en direct
final liveMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  return service.getLiveMatches();
});

/// Provider pour les résultats
final resultsProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  return service.getResults(limit: 10);
});

/// Provider pour le classement
final standingsProvider = FutureProvider<Map<String, List<Map<String, dynamic>>>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  return service.getStandings();
});

/// Provider pour les matchs triés avec l'équipe favorite en priorité
final prioritizedMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  final favoriteTeam = ref.watch(favoriteTeamProvider);
  final matches = await service.getUpcomingMatches(limit: 20);
  
  if (favoriteTeam == null) {
    return matches.take(10).toList();
  }
  
  // Séparer les matchs de l'équipe favorite
  final favoriteMatches = matches.where((m) =>
    m.homeTeam.code == favoriteTeam.code ||
    m.awayTeam.code == favoriteTeam.code
  ).toList();
  
  final otherMatches = matches.where((m) =>
    m.homeTeam.code != favoriteTeam.code &&
    m.awayTeam.code != favoriteTeam.code
  ).toList();
  
  // Retourner les matchs de l'équipe favorite d'abord
  return [...favoriteMatches, ...otherMatches].take(10).toList();
});

/// Provider pour vérifier si l'équipe favorite joue aujourd'hui
final favoriteTeamPlaysTodayProvider = FutureProvider<Match?>((ref) async {
  final service = ref.watch(footballServiceProvider);
  final favoriteTeam = ref.watch(favoriteTeamProvider);
  
  if (favoriteTeam == null) return null;
  
  final todayMatches = await service.getTodayMatches();
  
  try {
    return todayMatches.firstWhere((m) =>
      m.homeTeam.code == favoriteTeam.code ||
      m.awayTeam.code == favoriteTeam.code
    );
  } catch (_) {
    return null;
  }
});

// ============== NEWS ==============

/// Provider pour les actualités (filtrées par équipe favorite si définie)
final newsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  final favoriteTeam = ref.watch(favoriteTeamProvider);
  
  // Si une équipe favorite est définie, chercher les news de cette équipe
  if (favoriteTeam != null) {
    return service.getNews(
      query: '${favoriteTeam.name} football CAN 2025',
      pageSize: 20,
    );
  }
  
  // Sinon, actualités générales CAN 2025
  return service.getNews(pageSize: 20);
});

/// Provider pour les headlines sportifs
final sportsHeadlinesProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  return service.getSportsHeadlines();
});

/// Provider pour la recherche d'articles par équipe
final teamNewsProvider = FutureProvider.family<List<NewsArticle>, String>((ref, teamName) async {
  final service = ref.watch(newsServiceProvider);
  return service.searchByTeam(teamName);
});

/// Provider pour les news de l'équipe favorite uniquement
final favoriteTeamNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  final favoriteTeam = ref.watch(favoriteTeamProvider);
  
  if (favoriteTeam == null) {
    return [];
  }
  
  return service.searchByTeam(favoriteTeam.name);
});

// ============== CHATBOT ==============

/// État du chatbot
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Notifier pour les messages du chatbot
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GroqService _groqService;

  ChatNotifier(this._groqService) : super([]);

  Future<void> sendMessage(String message) async {
    // Ajouter le message de l'utilisateur
    state = [...state, ChatMessage(text: message, isUser: true)];

    // Obtenir la réponse de l'IA
    try {
      final response = await _groqService.chat(message);
      state = [...state, ChatMessage(text: response, isUser: false)];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
          text: 'Désolé, une erreur s\'est produite. Réessayez.',
          isUser: false,
        ),
      ];
    }
  }

  void clearChat() {
    _groqService.resetConversation();
    state = [];
  }
}

/// Provider pour les messages du chatbot
final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final groqService = ref.watch(groqServiceProvider);
  return ChatNotifier(groqService);
});

// ============== SENTIMENT ANALYSIS ==============

/// État de l'analyse de sentiment
class SentimentState {
  final bool isLoading;
  final String? sentiment;
  final double? score;
  final List<String>? keywords;
  final String? summary;
  final String? error;

  SentimentState({
    this.isLoading = false,
    this.sentiment,
    this.score,
    this.keywords,
    this.summary,
    this.error,
  });

  SentimentState copyWith({
    bool? isLoading,
    String? sentiment,
    double? score,
    List<String>? keywords,
    String? summary,
    String? error,
  }) {
    return SentimentState(
      isLoading: isLoading ?? this.isLoading,
      sentiment: sentiment ?? this.sentiment,
      score: score ?? this.score,
      keywords: keywords ?? this.keywords,
      summary: summary ?? this.summary,
      error: error ?? this.error,
    );
  }
}

/// Notifier pour l'analyse de sentiment
class SentimentNotifier extends StateNotifier<SentimentState> {
  final GroqService _groqService;

  SentimentNotifier(this._groqService) : super(SentimentState());

  Future<void> analyze(String text) async {
    state = SentimentState(isLoading: true);

    try {
      final response = await _groqService.chat(
        'Analyse le sentiment de ce texte et réponds uniquement avec: positif, négatif ou neutre. Texte: "$text"'
      );

      String sentiment = 'neutre';
      double score = 0.5;

      final lowerResponse = response.toLowerCase();
      if (lowerResponse.contains('positif')) {
        sentiment = 'positif';
        score = 0.8;
      } else if (lowerResponse.contains('négatif')) {
        sentiment = 'négatif';
        score = 0.2;
      }

      state = SentimentState(
        sentiment: sentiment,
        score: score,
        keywords: ['CAN 2025', 'Maroc'],
        summary: response,
      );
    } catch (e) {
      state = SentimentState(error: e.toString());
    }
  }

  void reset() {
    state = SentimentState();
  }
}

/// Provider pour l'analyse de sentiment
final sentimentProvider =
    StateNotifierProvider<SentimentNotifier, SentimentState>((ref) {
  final groqService = ref.watch(groqServiceProvider);
  return SentimentNotifier(groqService);
});

// ============== MATCH SUMMARY ==============

/// Provider pour générer un résumé de match
final matchSummaryProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
  final groqService = ref.watch(groqServiceProvider);
  return groqService.generateMatchSummary(
    params['homeTeam'] as String,
    params['awayTeam'] as String,
    params['homeScore'] as int,
    params['awayScore'] as int,
  );
});
