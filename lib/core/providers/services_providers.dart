import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/football_api_service.dart';
import '../services/news_api_service.dart';
import '../services/groq_service.dart';
import '../../features/matches/domain/entities/match.dart';
import '../../features/news/domain/entities/news_article.dart';
import 'favorite_team_provider.dart';

// Services

final footballServiceProvider = Provider<FootballApiService>((ref) {
  return FootballApiService();
});

final newsServiceProvider = Provider<NewsApiService>((ref) {
  return NewsApiService();
});

final groqServiceProvider = Provider<GroqService>((ref) {
  return GroqService();
});

// Matches

final upcomingMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  // Try upcoming; fallback to today, then live, then recent results.
  final upcoming = await service.getUpcomingMatches(limit: 10);
  if (upcoming.isNotEmpty) return upcoming;

  final today = await service.getTodayMatches();
  if (today.isNotEmpty) return today;

  final live = await service.getLiveMatches();
  if (live.isNotEmpty) return live;

  return service.getResults(limit: 10);
});

final todayMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  return service.getTodayMatches();
});

final liveMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  return service.getLiveMatches();
});

final resultsProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  return service.getResults(limit: 10);
});

final standingsProvider =
    FutureProvider<Map<String, List<Map<String, dynamic>>>>((ref) async {
      final service = ref.watch(footballServiceProvider);
      return service.getStandings();
    });

final prioritizedMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.watch(footballServiceProvider);
  final favoriteTeam = ref.watch(favoriteTeamProvider);

  // Compose a list with fallbacks similar to upcoming provider.
  List<Match> matches = await service.getUpcomingMatches(limit: 20);
  if (matches.isEmpty) {
    matches = await service.getTodayMatches();
  }
  if (matches.isEmpty) {
    matches = await service.getLiveMatches();
  }
  if (matches.isEmpty) {
    matches = await service.getResults(limit: 20);
  }

  if (favoriteTeam == null) {
    return matches.take(10).toList();
  }

  final favoriteMatches = matches
      .where(
        (m) =>
            m.homeTeam.code == favoriteTeam.code ||
            m.awayTeam.code == favoriteTeam.code,
      )
      .toList();

  final otherMatches = matches
      .where(
        (m) =>
            m.homeTeam.code != favoriteTeam.code &&
            m.awayTeam.code != favoriteTeam.code,
      )
      .toList();

  return [...favoriteMatches, ...otherMatches].take(10).toList();
});

final favoriteTeamPlaysTodayProvider = FutureProvider<Match?>((ref) async {
  final service = ref.watch(footballServiceProvider);
  final favoriteTeam = ref.watch(favoriteTeamProvider);

  if (favoriteTeam == null) return null;

  final todayMatches = await service.getTodayMatches();

  try {
    return todayMatches.firstWhere(
      (m) =>
          m.homeTeam.code == favoriteTeam.code ||
          m.awayTeam.code == favoriteTeam.code,
    );
  } catch (_) {
    return null;
  }
});

// News

final newsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  final favoriteTeam = ref.watch(favoriteTeamProvider);

  if (favoriteTeam != null) {
    return service.getNews(
      query: '${favoriteTeam.name} football CAN 2025',
      pageSize: 20,
    );
  }

  return service.getNews(pageSize: 20);
});

final sportsHeadlinesProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  return service.getSportsHeadlines();
});

final teamNewsProvider = FutureProvider.family<List<NewsArticle>, String>((
  ref,
  teamName,
) async {
  final service = ref.watch(newsServiceProvider);
  return service.searchByTeam(teamName);
});

final favoriteTeamNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  final favoriteTeam = ref.watch(favoriteTeamProvider);

  if (favoriteTeam == null) {
    return [];
  }

  return service.searchByTeam(favoriteTeam.name);
});

// Chatbot

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GroqService _groqService;

  ChatNotifier(this._groqService) : super([]);

  Future<void> sendMessage(String message) async {
    state = [...state, ChatMessage(text: message, isUser: true)];

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

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
      final groqService = ref.watch(groqServiceProvider);
      return ChatNotifier(groqService);
    });

// Sentiment Analysis

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

class SentimentNotifier extends StateNotifier<SentimentState> {
  final GroqService _groqService;
  final NewsApiService _newsService;

  SentimentNotifier(this._groqService, this._newsService)
    : super(SentimentState());

  /// Analyse le sentiment global de la CAN 2025 basé sur les actualités réelles
  Future<void> analyzeCanSentiment() async {
    state = SentimentState(isLoading: true);

    try {
      // Utiliser la même requête que la page News (qui fonctionne)
      final articles = await _newsService.getNews(
        query: 'CAN 2025 football Afrique',
        pageSize: 15,
      );

      // Debug logs removed for production

      if (articles.isEmpty) {
        state = SentimentState(
          error:
              'Aucune actualité disponible. Vérifiez votre connexion internet.',
        );
        return;
      }

      // Construire le texte à analyser à partir des titres et descriptions
      final textsToAnalyze = articles
          .map((a) {
            final title = a.title;
            final desc = a.description ?? '';
            return '$title. $desc';
          })
          .join('\n\n');

      // Prompt structuré pour obtenir une analyse complète
      final prompt =
          '''Analyse le sentiment global des actualités suivantes concernant la CAN 2025 (Coupe d'Afrique des Nations au Maroc).

ACTUALITÉS:
$textsToAnalyze

Réponds UNIQUEMENT avec un JSON valide dans ce format exact (sans texte avant ou après):
{
  "sentiment": "positif",
  "score": 0.75,
  "keywords": ["Maroc", "CAN 2025", "football", "organisation", "supporters"],
  "summary": "Le sentiment général autour de la CAN 2025 au Maroc est très positif."
}

Remplace les valeurs par ton analyse réelle basée sur les actualités ci-dessus. Le score doit être entre 0.0 et 1.0.''';

      final response = await _groqService.chat(prompt);

      // Parser la réponse JSON
      final parsed = _parseJsonResponse(response);

      state = SentimentState(
        sentiment: parsed['sentiment'] ?? 'neutre',
        score: (parsed['score'] as num?)?.toDouble() ?? 0.5,
        keywords: (parsed['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
        summary: parsed['summary'] ?? 'Analyse non disponible.',
      );
    } catch (e) {
      state = SentimentState(error: 'Erreur d\'analyse: ${e.toString()}');
    }
  }

  /// Parse la réponse JSON de Groq
  Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      // Nettoyer la réponse pour extraire le JSON
      String cleanedResponse = response.trim();

      // Chercher le JSON dans la réponse
      final jsonStart = cleanedResponse.indexOf('{');
      final jsonEnd = cleanedResponse.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        cleanedResponse = cleanedResponse.substring(jsonStart, jsonEnd + 1);
      }

      return json.decode(cleanedResponse) as Map<String, dynamic>;
    } catch (e) {
      // Fallback: parser manuellement si le JSON échoue
      return _parseManually(response);
    }
  }

  /// Parse manuellement si le JSON échoue
  Map<String, dynamic> _parseManually(String response) {
    final lowerResponse = response.toLowerCase();

    String sentiment = 'neutre';
    double score = 0.5;

    if (lowerResponse.contains('positif') ||
        lowerResponse.contains('positive')) {
      sentiment = 'positif';
      score = 0.75;
    } else if (lowerResponse.contains('négatif') ||
        lowerResponse.contains('negative')) {
      sentiment = 'négatif';
      score = 0.25;
    }

    // Extraire les mots-clés potentiels
    final keywordPatterns = [
      'maroc',
      'can 2025',
      'football',
      'stade',
      'équipe',
      'organisation',
      'billets',
      'fans',
    ];
    final foundKeywords = keywordPatterns
        .where((k) => lowerResponse.contains(k))
        .toList();

    return {
      'sentiment': sentiment,
      'score': score,
      'keywords': foundKeywords.take(5).toList(),
      'summary': response.length > 200
          ? '${response.substring(0, 200)}...'
          : response,
    };
  }

  void reset() {
    state = SentimentState();
  }
}

final sentimentProvider =
    StateNotifierProvider<SentimentNotifier, SentimentState>((ref) {
      final groqService = ref.watch(groqServiceProvider);
      final newsService = ref.watch(newsServiceProvider);
      return SentimentNotifier(groqService, newsService);
    });

// Match Summary

final matchSummaryProvider =
    FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
      final groqService = ref.watch(groqServiceProvider);
      return groqService.generateMatchSummary(
        params['homeTeam'] as String,
        params['awayTeam'] as String,
        params['homeScore'] as int,
        params['awayScore'] as int,
      );
    });
