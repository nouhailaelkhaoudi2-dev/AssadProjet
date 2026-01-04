import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../../features/news/domain/entities/news_article.dart';

/// Service pour GNews API (actualités CAN 2025)
class NewsApiService {
  late final Dio _dio;

  NewsApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.newsBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  /// Récupère les actualités de la CAN 2025
  Future<List<NewsArticle>> getNews({
    String? query,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointSearch,
        queryParameters: {
          'q': query ?? ApiConstants.newsDefaultQuery,
          'lang': ApiConstants.newsLanguage,
          'max': pageSize,
          'apikey': ApiKeys.gnewsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['articles'] != null) {
        final articles = response.data['articles'] as List;
        return articles.map((json) => _parseArticle(json)).toList();
      }
      return _getDemoNews();
    } catch (e) {
      debugPrint('Erreur GNews: $e');
      return _getDemoNews();
    }
  }

  /// Récupère les headlines sportifs
  Future<List<NewsArticle>> getSportsHeadlines({int pageSize = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointTopHeadlines,
        queryParameters: {
          'category': 'sports',
          'lang': ApiConstants.newsLanguage,
          'country': ApiConstants.newsCountry,
          'max': pageSize,
          'apikey': ApiKeys.gnewsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['articles'] != null) {
        final articles = response.data['articles'] as List;
        return articles.map((json) => _parseArticle(json)).toList();
      }
      return _getDemoNews();
    } catch (e) {
      debugPrint('Erreur GNews headlines: $e');
      return _getDemoNews();
    }
  }

  /// Recherche d'actualités par équipe
  Future<List<NewsArticle>> searchByTeam(String teamName) async {
    return getNews(query: '$teamName football CAN 2025');
  }

  /// Parse un article depuis le JSON de GNews
  NewsArticle _parseArticle(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['url'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Sans titre',
      description: json['description'],
      content: json['content'] ?? json['description'],
      imageUrl: json['image'],
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? 'Source inconnue',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt']) ?? DateTime.now()
          : DateTime.now(),
      author: null,
    );
  }

  /// Données de démonstration (fallback si API échoue)
  List<NewsArticle> _getDemoNews() {
    final now = DateTime.now();
    return [
      NewsArticle(
        id: '1',
        title: 'Le Maroc dévoile sa liste de 26 joueurs pour la CAN 2025',
        description:
            'Le sélectionneur Walid Regragui a annoncé la liste des Lions de l\'Atlas.',
        content:
            'Le sélectionneur national Walid Regragui a dévoilé la liste des 26 joueurs qui défendront les couleurs du Maroc lors de la CAN 2025. On retrouve les cadres habituels comme Achraf Hakimi, Hakim Ziyech et Youssef En-Nesyri.',
        imageUrl: null,
        url: 'https://example.com/article1',
        source: 'Le Matin Sport',
        publishedAt: now.subtract(const Duration(hours: 2)),
        author: null,
      ),
      NewsArticle(
        id: '2',
        title: 'CAN 2025 : Les stades marocains sont prêts',
        description: 'Les six stades ont été inspectés et validés par la CAF.',
        content:
            'La CAF a officiellement validé les six stades marocains pour la CAN 2025.',
        imageUrl: null,
        url: 'https://example.com/article2',
        source: 'CAF Official',
        publishedAt: now.subtract(const Duration(hours: 5)),
        author: null,
      ),
      NewsArticle(
        id: '3',
        title: 'Billetterie CAN 2025 : Plus de 500 000 billets vendus',
        description: 'L\'engouement pour la compétition se confirme.',
        content:
            'En moins d\'une semaine, plus de 500 000 billets ont trouvé preneurs.',
        imageUrl: null,
        url: 'https://example.com/article3',
        source: 'Africa Sports',
        publishedAt: now.subtract(const Duration(hours: 8)),
        author: null,
      ),
    ];
  }
}
