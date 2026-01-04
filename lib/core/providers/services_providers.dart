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

  SentimentNotifier(this._groqService) : super(SentimentState());

  Future<void> analyze(String text) async {
    state = SentimentState(isLoading: true);

    try {
      final response = await _groqService.chat(
        'Analyse le sentiment de ce texte et réponds uniquement avec: positif, négatif ou neutre. Texte: "$text"',
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

final sentimentProvider =
    StateNotifierProvider<SentimentNotifier, SentimentState>((ref) {
      final groqService = ref.watch(groqServiceProvider);
      return SentimentNotifier(groqService);
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
