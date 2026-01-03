import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'football_api_service.dart';
import 'news_api_service.dart';
import '../../features/matches/domain/entities/match.dart';

/// Message de chat
class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

/// Service pour Groq AI (Alternative à Gemini)
class GroqService {
  late final Dio _dio;
  final List<ChatMessage> _conversationHistory = [];
  final FootballApiService _footballService = FootballApiService();
  final NewsApiService _newsService = NewsApiService();

  GroqService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.groqBaseUrl,
      headers: {
        'Authorization': 'Bearer ${ApiKeys.groqApiKey}',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));

    // Message système pour contextualiser l'assistant
    _conversationHistory.add(ChatMessage(
      role: 'system',
      content: '''Tu es TikiTaka, l'assistant officiel de la CAN 2025 (Coupe d'Afrique des Nations) au Maroc.

Tu réponds aux questions sur:
- Les matchs, résultats et scores en temps réel
- Les 24 équipes participantes
- Les joueurs et statistiques
- Les 6 stades au Maroc
- La billetterie (https://tickets.cafonline.com/fr)
- Les actualités de la compétition

Informations clés:
- Dates: 21 décembre 2025 - 18 janvier 2026
- Pays hôte: Maroc 🇲🇦
- 24 équipes en 6 groupes
- Stades: Casablanca, Rabat, Marrakech, Tanger, Fès, Agadir

RÈGLES IMPORTANTES:
- Réponds TOUJOURS en français de manière naturelle et chaleureuse
- Ne mentionne JAMAIS "API", "données", "base de données" ou termes techniques
- Parle comme un expert passionné du football africain
- LIMITE l'utilisation des emojis (1 ou 2 maximum par réponse, pas plus)
- Privilégie les réponses concises et fluides pour une lecture vocale
- Sois concis mais informatif
- Utilise des emojis avec modération pour rendre les réponses vivantes''',
    ));
  }

  /// Envoie un message et obtient une réponse
  Future<String> chat(String userMessage) async {
    try {
      // Ajouter le message de l'utilisateur à l'historique
      _conversationHistory.add(ChatMessage(
        role: 'user',
        content: userMessage,
      ));

      // Vérifier si on doit appeler une fonction spécifique
      final functionResponse = await _handleFunctionCalls(userMessage);
      if (functionResponse != null) {
        // Ajouter le contexte de la fonction au message
        _conversationHistory.add(ChatMessage(
          role: 'system',
          content: 'Voici les informations actuelles: $functionResponse\n\nUtilise ces informations pour répondre naturellement à l\'utilisateur, sans mentionner de source technique.',
        ));
      }

      // Appeler l'API Groq
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': ApiConstants.groqModel,
          'messages': _conversationHistory.map((m) => m.toJson()).toList(),
          'temperature': 0.7,
          'max_tokens': 1024,
        },
      );

      if (response.statusCode == 200) {
        final assistantMessage = response.data['choices'][0]['message']['content'] as String;

        // Ajouter la réponse à l'historique
        _conversationHistory.add(ChatMessage(
          role: 'assistant',
          content: assistantMessage,
        ));

        // Supprimer le message système temporaire s'il a été ajouté
        if (functionResponse != null) {
          _conversationHistory.removeWhere((m) =>
            m.role == 'system' && m.content.contains('Voici les données actuelles'));
        }

        // Limiter l'historique pour éviter de dépasser les limites de tokens
        _trimHistory();

        return assistantMessage;
      }

      return 'Désolé, je n\'ai pas pu obtenir de réponse. Veuillez réessayer.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return 'Le service est temporairement surchargé. Veuillez réessayer dans quelques instants.';
      }
      return 'Erreur de connexion: ${e.message}';
    } catch (e) {
      return 'Une erreur est survenue: $e';
    }
  }

  /// Gère les appels de fonctions basés sur le message
  Future<String?> _handleFunctionCalls(String message) async {
    final lowerMessage = message.toLowerCase();

    // Matchs d'aujourd'hui
    if (_containsAny(lowerMessage, ['aujourd\'hui', 'ce soir', 'ce jour', 'aujourd hui', 'aujourdhui'])) {
      return await _getTodayMatchesInfo();
    }

    // Matchs en direct
    if (_containsAny(lowerMessage, ['en direct', 'live', 'en cours', 'maintenant'])) {
      return await _getLiveMatchesInfo();
    }

    // Matchs à venir
    if (_containsAny(lowerMessage, ['prochain', 'à venir', 'calendrier', 'programme', 'quand'])) {
      return await _getUpcomingMatchesInfo();
    }

    // Résultats
    if (_containsAny(lowerMessage, ['résultat', 'score', 'terminé', 'gagné', 'perdu'])) {
      return await _getResultsInfo();
    }

    // Classement
    if (_containsAny(lowerMessage, ['classement', 'standing', 'tableau', 'points', 'position'])) {
      return await _getStandingsInfo();
    }

    // Actualités
    if (_containsAny(lowerMessage, ['actualité', 'news', 'nouvelle', 'article', 'info'])) {
      return await _getNewsInfo();
    }

    // Billetterie
    if (_containsAny(lowerMessage, ['billet', 'ticket', 'place', 'acheter', 'réserver'])) {
      return _getTicketInfo();
    }

    // Stades
    if (_containsAny(lowerMessage, ['stade', 'stadium', 'où', 'lieu', 'ville'])) {
      return _getStadiumInfo();
    }

    // Équipes
    if (_containsAny(lowerMessage, ['équipe', 'team', 'pays', 'nation', 'groupe'])) {
      return _getTeamsInfo();
    }

    return null;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  Future<String> _getLiveMatchesInfo() async {
    try {
      final matches = await _footballService.getLiveMatches();
      if (matches.isEmpty) {
        return 'Aucun match en direct actuellement.';
      }
      
      final buffer = StringBuffer('🔴 Matchs en direct:\n\n');
      for (final m in matches) {
        buffer.writeln('${m.homeTeam.flagEmoji} ${m.homeTeam.name} ${m.homeScore ?? 0} - ${m.awayScore ?? 0} ${m.awayTeam.name} ${m.awayTeam.flagEmoji}');
        buffer.writeln('📍 ${m.stadium}, ${m.city}');
        if (m.minute != null) buffer.writeln('⏱️ ${m.minute}\'');
        buffer.writeln('');
      }
      return buffer.toString();
    } catch (e) {
      return 'Les matchs en direct ne sont pas disponibles pour le moment.';
    }
  }

  Future<String> _getUpcomingMatchesInfo() async {
    try {
      final matches = await _footballService.getUpcomingMatches();
      if (matches.isEmpty) {
        return 'Aucun match à venir programmé pour le moment.';
      }
      
      final buffer = StringBuffer('📅 Prochains matchs:\n\n');
      for (final m in matches.take(5)) {
        buffer.writeln('${m.homeTeam.flagEmoji} ${m.homeTeam.name} vs ${m.awayTeam.name} ${m.awayTeam.flagEmoji}');
        buffer.writeln('📅 ${m.dateTime.day}/${m.dateTime.month}/${m.dateTime.year} à ${m.dateTime.hour}h${m.dateTime.minute.toString().padLeft(2, '0')}');
        buffer.writeln('📍 ${m.stadium}, ${m.city}');
        if (m.group != null) buffer.writeln('🏆 Groupe ${m.group}');
        buffer.writeln('');
      }
      return buffer.toString();
    } catch (e) {
      return 'Le calendrier des matchs n\'est pas disponible pour le moment.';
    }
  }

  Future<String> _getResultsInfo() async {
    try {
      final matches = await _footballService.getResults();
      if (matches.isEmpty) {
        return 'Aucun résultat disponible pour le moment.';
      }
      
      final buffer = StringBuffer('✅ Derniers résultats:\n\n');
      for (final m in matches.take(5)) {
        buffer.writeln('${m.homeTeam.flagEmoji} ${m.homeTeam.name} ${m.homeScore ?? 0} - ${m.awayScore ?? 0} ${m.awayTeam.name} ${m.awayTeam.flagEmoji}');
        buffer.writeln('📅 ${m.dateTime.day}/${m.dateTime.month}/${m.dateTime.year}');
        buffer.writeln('');
      }
      return buffer.toString();
    } catch (e) {
      return 'Les résultats ne sont pas disponibles pour le moment.';
    }
  }

  Future<String> _getTodayMatchesInfo() async {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    try {
      final matches = await _footballService.getTodayMatches();

      if (matches.isNotEmpty) {
        final buffer = StringBuffer('📅 Matchs du $dateStr:\n\n');
        
        for (final m in matches) {
          final statusEmoji = m.status.isLive ? '🔴 EN DIRECT' : 
                              m.status.isFinished ? '✅ Terminé' : '⏰ À venir';
          final scoreOrTime = m.status.isFinished || m.status.isLive
              ? '${m.homeScore ?? 0} - ${m.awayScore ?? 0}'
              : '${m.dateTime.hour}h${m.dateTime.minute.toString().padLeft(2, '0')}';
          
          buffer.writeln('$statusEmoji');
          buffer.writeln('${m.homeTeam.flagEmoji} ${m.homeTeam.name} $scoreOrTime ${m.awayTeam.name} ${m.awayTeam.flagEmoji}');
          buffer.writeln('📍 ${m.stadium}, ${m.city}');
          if (m.group != null) buffer.writeln('🏆 Groupe ${m.group}');
          buffer.writeln('');
        }
        
        return buffer.toString();
      }

      return 'Aucun match programmé pour aujourd\'hui ($dateStr).';
    } catch (e) {
      return 'Les matchs du jour ne sont pas disponibles pour le moment.';
    }
  }

  Future<String> _getStandingsInfo() async {
    try {
      final standings = await _footballService.getStandings();
      if (standings.isEmpty) {
        return 'Le classement n\'est pas encore disponible.';
      }
      
      final buffer = StringBuffer('🏆 Classement par groupe:\n\n');
      standings.forEach((group, teams) {
        buffer.writeln('📊 $group:');
        for (final t in teams) {
          buffer.writeln('  ${t['rank']}. ${t['team']} - ${t['points']} pts (${t['won']}V ${t['draw']}N ${t['lost']}D)');
        }
        buffer.writeln('');
      });
      return buffer.toString();
    } catch (e) {
      return 'Le classement n\'est pas disponible pour le moment.';
    }
  }

  Future<String> _getNewsInfo() async {
    try {
      final articles = await _newsService.getNews(pageSize: 5);
      if (articles.isEmpty) {
        return 'Aucune actualité disponible pour le moment.';
      }
      
      final buffer = StringBuffer('📰 Actualités récentes:\n\n');
      for (final a in articles.take(5)) {
        buffer.writeln('• ${a.title}');
        if (a.description != null) {
          buffer.writeln('  ${a.description!.length > 100 ? '${a.description!.substring(0, 100)}...' : a.description}');
        }
        buffer.writeln('');
      }
      return buffer.toString();
    } catch (e) {
      return 'Les actualités ne sont pas disponibles pour le moment.';
    }
  }

  String _getTicketInfo() {
    return '''Informations billetterie CAN 2025:
- Site officiel: https://tickets.cafonline.com/fr
- Catégories: VIP, Catégorie 1, Catégorie 2, Catégorie 3
- Prix: de 50 DH à 2000 DH selon la catégorie et le match
- Matchs du Maroc très demandés
- Finale: Stade Mohammed V, Casablanca''';
  }

  String _getStadiumInfo() {
    return '''Stades de la CAN 2025 au Maroc:
1. Stade Mohammed V - Casablanca (45 000 places) - Finale
2. Stade Prince Moulay Abdellah - Rabat (53 000 places)
3. Grand Stade de Marrakech (45 000 places)
4. Grand Stade de Tanger (45 000 places)
5. Stade de Fès (35 000 places)
6. Stade d'Agadir (45 000 places)''';
  }

  String _getTeamsInfo() {
    return '''24 équipes qualifiées pour la CAN 2025:
Groupe A: Maroc (hôte), Mali, Zambie, Comores
Groupe B: Égypte, Afrique du Sud, Angola, Zimbabwe
Groupe C: Nigeria, Tunisie, Ouganda, Tanzanie
Groupe D: Sénégal, RD Congo, Bénin, Botswana
Groupe E: Algérie, Burkina Faso, Guinée Équatoriale, Soudan
Groupe F: Côte d'Ivoire, Cameroun, Gabon, Mozambique''';
  }

  /// Limite l'historique de conversation
  void _trimHistory() {
    // Garder le message système et les 20 derniers messages
    if (_conversationHistory.length > 21) {
      final systemMessage = _conversationHistory.first;
      _conversationHistory.removeRange(1, _conversationHistory.length - 20);
      if (_conversationHistory.first.role != 'system') {
        _conversationHistory.insert(0, systemMessage);
      }
    }
  }

  /// Réinitialise la conversation
  void resetConversation() {
    final systemMessage = _conversationHistory.first;
    _conversationHistory.clear();
    _conversationHistory.add(systemMessage);
  }

  /// Génère un résumé de match
  Future<String> generateMatchSummary(String homeTeam, String awayTeam, int homeScore, int awayScore) async {
    final prompt = '''Génère un résumé court et engageant du match de la CAN 2025:
$homeTeam $homeScore - $awayScore $awayTeam

Le résumé doit inclure:
- Le résultat et son importance
- Une phrase sur le déroulement du match
- Maximum 3 phrases''';

    return await chat(prompt);
  }
}
