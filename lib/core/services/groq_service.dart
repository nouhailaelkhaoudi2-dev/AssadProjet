import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'football_api_service.dart';
import 'news_api_service.dart';
import '../../features/matches/domain/entities/match.dart';
import '../../features/matches/domain/entities/match_details.dart';
import '../../features/matches/domain/entities/team.dart';

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

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

    _conversationHistory.add(ChatMessage(
      role: 'system',
      content: '''Tu es TikiTaka, l'assistant officiel de la CAN 2025 au Maroc.

Tu réponds aux questions sur les matchs, équipes, stades et billetterie.
- Dates: 21 décembre 2025 - 18 janvier 2026
- Pays hôte: Maroc
- 24 équipes en 6 groupes
- Stades: Casablanca, Rabat, Marrakech, Tanger, Fès, Agadir
- Billetterie: https://tickets.cafonline.com/fr

RÈGLES:
- Réponds en français, naturellement
- Ne mentionne jamais "API" ou termes techniques
- Utilise les données fournies pour répondre
- Maximum 2 emojis par réponse
- Sois concis et précis''',
    ));
  }

  Future<String> chat(String userMessage) async {
    try {
      _conversationHistory.add(ChatMessage(
        role: 'user',
        content: userMessage,
      ));

      final functionResponse = await _handleFunctionCalls(userMessage);
      if (functionResponse != null) {
        _conversationHistory.add(ChatMessage(
          role: 'system',
          content: 'Données actuelles:\n$functionResponse\n\nUtilise ces informations pour répondre.',
        ));
      }

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

        _conversationHistory.add(ChatMessage(
          role: 'assistant',
          content: assistantMessage,
        ));

        if (functionResponse != null) {
          _conversationHistory.removeWhere((m) =>
              m.role == 'system' && m.content.contains('Données actuelles'));
        }

        _trimHistory();
        return assistantMessage;
      }

      return 'Désolé, je n\'ai pas pu obtenir de réponse.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return 'Service surchargé. Réessayez dans quelques instants.';
      }
      return 'Erreur de connexion.';
    } catch (e) {
      return 'Une erreur est survenue.';
    }
  }

  Future<String?> _handleFunctionCalls(String message) async {
    final lowerMessage = message.toLowerCase();

    // Détails d'un match d'hier pour une équipe spécifique
    if (_containsAny(lowerMessage, ['détail', 'detail']) && _containsAny(lowerMessage, ['hier', 'yesterday'])) {
      final teamName = _extractTeamName(lowerMessage);
      if (teamName != null) {
        return await _getTeamMatchByDate(teamName, -1);
      }
      return await _getMatchesByRelativeDate(-1);
    }

    // Détails d'un match d'aujourd'hui pour une équipe spécifique
    if (_containsAny(lowerMessage, ['détail', 'detail']) && _containsAny(lowerMessage, ['aujourd', 'today', 'ce soir'])) {
      final teamName = _extractTeamName(lowerMessage);
      if (teamName != null) {
        return await _getTeamMatchByDate(teamName, 0);
      }
      return await _getMatchesByRelativeDate(0);
    }

    // Détails d'un match spécifique (buteurs, stats, compo)
    if (_containsAny(lowerMessage, ['détail', 'detail', 'buteur', 'marqué', 'qui a marqué', 'scorer', 'composition', 'compo', 'onze', '11', 'titulaire', 'statistique', 'stat', 'possession', 'tir'])) {
      final teamMatch = await _findTeamInMessage(lowerMessage);
      if (teamMatch != null) {
        return await _getMatchDetailsWithEvents(teamMatch);
      }
      return await _getLastMatchDetails();
    }

    // Meilleurs buteurs de la compétition
    if (_containsAny(lowerMessage, ['meilleur buteur', 'top buteur', 'plus de buts', 'classement buteur'])) {
      return await _getTopScorersInfo();
    }

    // Meilleurs passeurs
    if (_containsAny(lowerMessage, ['meilleur passeur', 'top passeur', 'plus de passes', 'assist'])) {
      return await _getTopAssistsInfo();
    }

    // Confrontation directe (H2H)
    if (_containsAny(lowerMessage, ['confrontation', 'face à face', 'historique', 'h2h', 'vs', 'contre'])) {
      final teams = _extractTwoTeams(lowerMessage);
      if (teams != null) {
        return await _getHeadToHeadInfo(teams.$1, teams.$2);
      }
    }

    // Question sur le groupe d'un pays spécifique
    if (_containsAny(lowerMessage, ['dans quel groupe', 'quel groupe', 'groupe de', 'groupe du'])) {
      return _getTeamGroupInfo(lowerMessage);
    }

    // Équipes d'un groupe spécifique
    if (_containsAny(lowerMessage, ['qui est dans le groupe', 'équipes du groupe', 'groupe a', 'groupe b', 'groupe c', 'groupe d', 'groupe e', 'groupe f'])) {
      return _getGroupTeamsInfo(lowerMessage);
    }

    // Effectif d'une équipe
    if (_containsAny(lowerMessage, ['effectif', 'joueur', 'squad', 'équipe de', 'liste'])) {
      final teamName = _extractTeamName(lowerMessage);
      if (teamName != null) {
        return await _getTeamSquadInfo(teamName);
      }
    }

    // Entraîneur
    if (_containsAny(lowerMessage, ['entraineur', 'entraîneur', 'coach', 'sélectionneur'])) {
      final teamName = _extractTeamName(lowerMessage);
      if (teamName != null) {
        return await _getTeamCoachInfo(teamName);
      }
      return _getAllCoachesInfo();
    }

    // Blessures
    if (_containsAny(lowerMessage, ['blessé', 'blessure', 'absent', 'indisponible', 'forfait'])) {
      final teamName = _extractTeamName(lowerMessage);
      if (teamName != null) {
        return await _getInjuriesInfo(teamName);
      }
    }

    // Prédiction de match
    if (_containsAny(lowerMessage, ['prédiction', 'prediction', 'pronostic', 'qui va gagner'])) {
      return await _getPredictionInfo(lowerMessage);
    }

    // Matchs d'hier (avec ou sans équipe spécifique)
    if (_containsAny(lowerMessage, ['hier', 'yesterday'])) {
      final teamName = _extractTeamName(lowerMessage);
      if (teamName != null) {
        return await _getTeamMatchByDate(teamName, -1);
      }
      return await _getMatchesByRelativeDate(-1);
    }

    // Matchs de demain (avec ou sans équipe spécifique)
    if (_containsAny(lowerMessage, ['demain', 'tomorrow'])) {
      final teamName = _extractTeamName(lowerMessage);
      if (teamName != null) {
        return await _getTeamMatchByDate(teamName, 1);
      }
      return await _getMatchesByRelativeDate(1);
    }

    // Matchs d'aujourd'hui (avec ou sans équipe spécifique)
    if (_containsAny(lowerMessage, ['aujourd\'hui', 'aujourd hui', 'aujourdhui', 'ce soir', 'today'])) {
      final teamName = _extractTeamName(lowerMessage);
      if (teamName != null) {
        return await _getTeamMatchByDate(teamName, 0);
      }
      return await _getMatchesByRelativeDate(0);
    }

    // Huitièmes de finale
    if (_containsAny(lowerMessage, ['huitième', 'huitiemes', '8ème', '8eme', 'round of 16', '16'])) {
      return await _getMatchesByPhaseInfo('Round of 16');
    }

    // Quarts de finale
    if (_containsAny(lowerMessage, ['quart', 'quarter'])) {
      return await _getMatchesByPhaseInfo('Quarter-finals');
    }

    // Demi-finales
    if (_containsAny(lowerMessage, ['demi', 'semi'])) {
      return await _getMatchesByPhaseInfo('Semi-finals');
    }

    // Finale
    if (_containsAny(lowerMessage, ['finale', 'final']) && !_containsAny(lowerMessage, ['demi', 'semi', 'quart', 'quarter'])) {
      return await _getMatchesByPhaseInfo('Final');
    }

    // Phase de groupes
    if (_containsAny(lowerMessage, ['groupe', 'group', 'poule'])) {
      return await _getGroupStageInfo(lowerMessage);
    }

    // Matchs en direct
    if (_containsAny(lowerMessage, ['en direct', 'live', 'en cours'])) {
      return await _getLiveMatchesInfo();
    }

    // Matchs à venir / prochains
    if (_containsAny(lowerMessage, ['prochain', 'à venir', 'calendrier', 'programme'])) {
      return await _getUpcomingMatchesInfo();
    }

    // Résumé de match
    if (_containsAny(lowerMessage, ['résumé', 'resume', 'raconter', 'raconte', 'comment s\'est passé', 'comment s est passé', 'déroulé', 'passé le match'])) {
      return await _getMatchSummaryInfo(lowerMessage);
    }

    // Résultats
    if (_containsAny(lowerMessage, ['résultat', 'score', 'terminé', 'gagné', 'perdu', 'dernier'])) {
      return await _getResultsInfo();
    }

    // Classement
    if (_containsAny(lowerMessage, ['classement', 'standing', 'tableau', 'points', 'position'])) {
      return await _getStandingsInfo();
    }

    // Actualités
    if (_containsAny(lowerMessage, ['actualité', 'news', 'nouvelle', 'article'])) {
      return await _getNewsInfo();
    }

    // Billetterie
    if (_containsAny(lowerMessage, ['billet', 'ticket', 'place', 'acheter', 'réserver'])) {
      return _getTicketInfo();
    }

    // Stades
    if (_containsAny(lowerMessage, ['stade', 'stadium'])) {
      return _getStadiumInfo();
    }

    // Équipes participantes
    if (_containsAny(lowerMessage, ['équipe', 'team', 'pays', 'nation', 'qualifié', 'participant'])) {
      return _getTeamsInfo();
    }

    return null;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  Future<String> _getMatchesByRelativeDate(int daysOffset) async {
    final targetDate = DateTime.now().add(Duration(days: daysOffset));
    final dateStr = '${targetDate.day}/${targetDate.month}/${targetDate.year}';

    String dayLabel;
    if (daysOffset == 0) {
      dayLabel = "aujourd'hui";
    } else if (daysOffset == -1) {
      dayLabel = "hier";
    } else if (daysOffset == 1) {
      dayLabel = "demain";
    } else {
      dayLabel = "le $dateStr";
    }

    try {
      final matches = await _footballService.getMatchesByDate(targetDate);

      if (matches.isEmpty) {
        return 'Aucun match programmé $dayLabel ($dateStr).';
      }

      final buffer = StringBuffer('Matchs $dayLabel ($dateStr):\n\n');
      for (final m in matches) {
        buffer.writeln(_formatMatch(m));
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les matchs $dayLabel.';
    }
  }

  Future<String> _getMatchesByPhaseInfo(String phase) async {
    try {
      final matches = await _footballService.getMatchesByPhase(phase);

      if (matches.isEmpty) {
        // Essayer de récupérer tous les matchs et filtrer par phase
        final allMatches = await _footballService.getAllMatches();
        final phaseMatches = allMatches.where((m) {
          final phaseLower = phase.toLowerCase();
          if (phaseLower.contains('16')) return m.phase == TournamentPhase.roundOf16;
          if (phaseLower.contains('quarter')) return m.phase == TournamentPhase.quarterFinal;
          if (phaseLower.contains('semi')) return m.phase == TournamentPhase.semiFinal;
          if (phaseLower.contains('final') && !phaseLower.contains('semi') && !phaseLower.contains('quarter')) {
            return m.phase == TournamentPhase.final_;
          }
          return false;
        }).toList();

        if (phaseMatches.isEmpty) {
          return 'Les matchs des $phase ne sont pas encore programmés ou disponibles.';
        }

        final buffer = StringBuffer('$phase:\n\n');
        for (final m in phaseMatches) {
          buffer.writeln(_formatMatch(m));
        }
        return buffer.toString();
      }

      final buffer = StringBuffer('$phase:\n\n');
      for (final m in matches) {
        buffer.writeln(_formatMatch(m));
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les matchs des $phase.';
    }
  }

  Future<String> _getGroupStageInfo(String message) async {
    try {
      // Détecter un groupe spécifique (A, B, C, D, E, F)
      String? specificGroup;
      final groupMatch = RegExp(r'groupe\s*([a-fA-F])').firstMatch(message);
      if (groupMatch != null) {
        specificGroup = groupMatch.group(1)!.toUpperCase();
      }

      final allMatches = await _footballService.getAllMatches();
      final groupMatches = allMatches.where((m) => m.phase == TournamentPhase.groupStage).toList();

      if (groupMatches.isEmpty) {
        return 'Les matchs de la phase de groupes ne sont pas encore disponibles.';
      }

      if (specificGroup != null) {
        final filtered = groupMatches.where((m) => m.group == specificGroup).toList();
        if (filtered.isEmpty) {
          return 'Aucun match trouvé pour le Groupe $specificGroup.';
        }

        final buffer = StringBuffer('Groupe $specificGroup:\n\n');
        for (final m in filtered) {
          buffer.writeln(_formatMatch(m));
        }
        return buffer.toString();
      }

      // Retourner un résumé de tous les groupes
      final buffer = StringBuffer('Phase de groupes:\n\n');
      final groups = <String, List<Match>>{};
      for (final m in groupMatches) {
        final g = m.group ?? 'A';
        groups.putIfAbsent(g, () => []).add(m);
      }

      for (final g in groups.keys.toList()..sort()) {
        buffer.writeln('Groupe $g: ${groups[g]!.length} matchs');
      }
      buffer.writeln('\nDemande un groupe spécifique pour plus de détails.');
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les matchs de la phase de groupes.';
    }
  }

  String _formatMatch(Match m) {
    final buffer = StringBuffer();

    String statusStr;
    if (m.status.isLive) {
      statusStr = '🔴 EN DIRECT';
      if (m.minute != null) statusStr += ' (${m.minute}\')';
    } else if (m.status.isFinished) {
      statusStr = '✅ Terminé';
    } else {
      statusStr = '⏰ ${m.dateTime.hour}h${m.dateTime.minute.toString().padLeft(2, '0')}';
    }

    buffer.writeln('$statusStr - ${m.dateTime.day}/${m.dateTime.month}/${m.dateTime.year}');

    if (m.status.isFinished || m.status.isLive) {
      buffer.writeln('${m.homeTeam.name} ${m.homeScore ?? 0} - ${m.awayScore ?? 0} ${m.awayTeam.name}');
    } else {
      buffer.writeln('${m.homeTeam.name} vs ${m.awayTeam.name}');
    }

    buffer.writeln('📍 ${m.stadium}, ${m.city}');
    if (m.group != null) buffer.writeln('Groupe ${m.group}');
    buffer.writeln('');

    return buffer.toString();
  }

  Future<String> _getLiveMatchesInfo() async {
    try {
      final matches = await _footballService.getLiveMatches();
      if (matches.isEmpty) {
        return 'Aucun match en direct actuellement.';
      }

      final buffer = StringBuffer('Matchs en direct:\n\n');
      for (final m in matches) {
        buffer.writeln(_formatMatch(m));
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les matchs en direct.';
    }
  }

  Future<String> _getUpcomingMatchesInfo() async {
    try {
      final matches = await _footballService.getUpcomingMatches();
      if (matches.isEmpty) {
        return 'Aucun match à venir programmé.';
      }

      final buffer = StringBuffer('Prochains matchs:\n\n');
      for (final m in matches.take(5)) {
        buffer.writeln(_formatMatch(m));
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les prochains matchs.';
    }
  }

  Future<String> _getResultsInfo() async {
    try {
      final matches = await _footballService.getResults();
      if (matches.isEmpty) {
        return 'Aucun résultat disponible.';
      }

      final buffer = StringBuffer('Derniers résultats:\n\n');
      for (final m in matches.take(5)) {
        buffer.writeln(_formatMatch(m));
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les résultats.';
    }
  }

  Future<String> _getMatchSummaryInfo(String message) async {
    try {
      // Chercher les noms d'équipes dans le message
      final allMatches = await _footballService.getResults(limit: 20);

      if (allMatches.isEmpty) {
        return 'Aucun match terminé disponible pour générer un résumé.';
      }

      // Essayer de trouver un match spécifique mentionné
      Match? targetMatch;

      for (final m in allMatches) {
        final homeNameLower = m.homeTeam.name.toLowerCase();
        final awayNameLower = m.awayTeam.name.toLowerCase();

        if (message.contains(homeNameLower) || message.contains(awayNameLower)) {
          targetMatch = m;
          break;
        }
      }

      // Si pas de match spécifique trouvé, prendre le dernier match terminé
      targetMatch ??= allMatches.first;

      final buffer = StringBuffer();
      buffer.writeln('RÉSUMÉ DU MATCH:');
      buffer.writeln('${targetMatch.homeTeam.name} ${targetMatch.homeScore ?? 0} - ${targetMatch.awayScore ?? 0} ${targetMatch.awayTeam.name}');
      buffer.writeln('Date: ${targetMatch.dateTime.day}/${targetMatch.dateTime.month}/${targetMatch.dateTime.year}');
      buffer.writeln('Stade: ${targetMatch.stadium}, ${targetMatch.city}');
      if (targetMatch.group != null) buffer.writeln('Groupe: ${targetMatch.group}');
      buffer.writeln('');

      // Déterminer le vainqueur
      final homeScore = targetMatch.homeScore ?? 0;
      final awayScore = targetMatch.awayScore ?? 0;

      if (homeScore > awayScore) {
        buffer.writeln('Vainqueur: ${targetMatch.homeTeam.name}');
      } else if (awayScore > homeScore) {
        buffer.writeln('Vainqueur: ${targetMatch.awayTeam.name}');
      } else {
        buffer.writeln('Match nul');
      }

      buffer.writeln('');
      buffer.writeln('Génère un résumé narratif et engageant de ce match.');

      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les informations du match.';
    }
  }

  Future<String> _getStandingsInfo() async {
    try {
      final standings = await _footballService.getStandings();
      if (standings.isEmpty) {
        return 'Le classement n\'est pas encore disponible.';
      }

      final buffer = StringBuffer('Classement:\n\n');
      standings.forEach((group, teams) {
        buffer.writeln('$group:');
        for (final t in teams) {
          buffer.writeln('  ${t['rank']}. ${t['team']} - ${t['points']} pts');
        }
        buffer.writeln('');
      });
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer le classement.';
    }
  }

  Future<String> _getNewsInfo() async {
    try {
      final articles = await _newsService.getNews(pageSize: 5);
      if (articles.isEmpty) {
        return 'Aucune actualité disponible.';
      }

      final buffer = StringBuffer('Actualités:\n\n');
      for (final a in articles.take(5)) {
        buffer.writeln('• ${a.title}');
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les actualités.';
    }
  }

  String _getTicketInfo() {
    return '''Billetterie CAN 2025:
- Site: https://tickets.cafonline.com/fr
- Catégories: VIP, Cat 1, Cat 2, Cat 3
- Prix: 50 à 2000 DH''';
  }

  String _getStadiumInfo() {
    return '''Stades CAN 2025:
1. Stade Mohammed V - Casablanca (45 000)
2. Stade Prince Moulay Abdellah - Rabat (53 000)
3. Grand Stade de Marrakech (45 000)
4. Grand Stade de Tanger (45 000)
5. Stade de Fès (35 000)
6. Stade d'Agadir (45 000)''';
  }

  String _getTeamsInfo() {
    return '''24 équipes CAN 2025:
Groupe A: Maroc, Mali, Zambie, Comores
Groupe B: Égypte, Afrique du Sud, Angola, Zimbabwe
Groupe C: Nigeria, Tunisie, Ouganda, Tanzanie
Groupe D: Sénégal, RD Congo, Bénin, Botswana
Groupe E: Algérie, Burkina Faso, Guinée Équatoriale, Soudan
Groupe F: Côte d'Ivoire, Cameroun, Gabon, Mozambique''';
  }

  // Nouvelles méthodes pour les détails complets

  /// Trouve un nom d'équipe dans le message
  String? _extractTeamName(String message) {
    final teams = [
      'maroc', 'morocco', 'mali', 'zambie', 'zambia', 'comores', 'comoros',
      'egypte', 'egypt', 'égypte', 'afrique du sud', 'south africa', 'angola', 'zimbabwe',
      'nigeria', 'tunisie', 'tunisia', 'ouganda', 'uganda', 'tanzanie', 'tanzania',
      'senegal', 'sénégal', 'rd congo', 'dr congo', 'benin', 'bénin', 'botswana',
      'algerie', 'algérie', 'algeria', 'burkina faso', 'guinee equatoriale', 'guinée équatoriale', 'soudan', 'sudan',
      'cote d\'ivoire', 'côte d\'ivoire', 'ivory coast', 'cameroun', 'cameroon', 'gabon', 'mozambique'
    ];
    
    for (final team in teams) {
      if (message.contains(team)) {
        return team;
      }
    }
    return null;
  }

  /// Trouve un match récent impliquant une équipe
  Future<Match?> _findTeamInMessage(String message) async {
    final teamName = _extractTeamName(message);
    if (teamName == null) return null;

    final allMatches = await _footballService.getResults(limit: 20);
    for (final match in allMatches) {
      if (match.homeTeam.name.toLowerCase().contains(teamName) ||
          match.awayTeam.name.toLowerCase().contains(teamName)) {
        return match;
      }
    }

    final upcoming = await _footballService.getUpcomingMatches(limit: 20);
    for (final match in upcoming) {
      if (match.homeTeam.name.toLowerCase().contains(teamName) ||
          match.awayTeam.name.toLowerCase().contains(teamName)) {
        return match;
      }
    }
    return null;
  }

  /// Extrait deux équipes d'un message pour H2H
  (String, String)? _extractTwoTeams(String message) {
    final teams = [
      'maroc', 'mali', 'zambie', 'comores', 'egypte', 'égypte', 'afrique du sud',
      'angola', 'zimbabwe', 'nigeria', 'tunisie', 'ouganda', 'tanzanie',
      'senegal', 'sénégal', 'rd congo', 'benin', 'bénin', 'botswana',
      'algerie', 'algérie', 'burkina faso', 'guinee equatoriale', 'guinée équatoriale', 'soudan',
      'cote d\'ivoire', 'côte d\'ivoire', 'cameroun', 'gabon', 'mozambique'
    ];
    
    final found = <String>[];
    for (final team in teams) {
      if (message.contains(team) && !found.contains(team)) {
        found.add(team);
        if (found.length == 2) break;
      }
    }
    
    if (found.length == 2) {
      return (found[0], found[1]);
    }
    return null;
  }

  /// Récupère les détails complets d'un match avec événements
  Future<String> _getMatchDetailsWithEvents(Match match) async {
    try {
      final details = await _footballService.getMatchFullDetails(match.id);
      final events = details['events'] as List<MatchEvent>? ?? [];
      final stats = details['statistics'] as MatchStatistics?;
      final lineups = details['lineups'] as List<TeamLineup>? ?? [];

      final buffer = StringBuffer();
      buffer.writeln('MATCH: ${match.homeTeam.name} ${match.homeScore ?? 0} - ${match.awayScore ?? 0} ${match.awayTeam.name}');
      buffer.writeln('Date: ${match.dateTime.day}/${match.dateTime.month}/${match.dateTime.year}');
      buffer.writeln('Stade: ${match.stadium}, ${match.city}');
      buffer.writeln('');

      // Événements (buts, cartons)
      if (events.isNotEmpty) {
        buffer.writeln('ÉVÉNEMENTS:');
        final goals = events.where((e) => e.type == EventType.goal).toList();
        if (goals.isNotEmpty) {
          buffer.writeln('Buts:');
          for (final goal in goals) {
            final assist = goal.assistName != null ? ' (passe de ${goal.assistName})' : '';
            buffer.writeln('  ${goal.timeDisplay} - ${goal.playerName} (${goal.teamName})$assist');
          }
        }
        
        final cards = events.where((e) => e.type == EventType.card).toList();
        if (cards.isNotEmpty) {
          buffer.writeln('Cartons:');
          for (final card in cards) {
            buffer.writeln('  ${card.timeDisplay} - ${card.playerName} (${card.teamName}) - ${card.detail}');
          }
        }
        buffer.writeln('');
      }

      // Statistiques
      if (stats != null && stats.stats.isNotEmpty) {
        buffer.writeln('STATISTIQUES:');
        for (final stat in stats.stats.take(8)) {
          buffer.writeln('  ${stat.typeLabel}: ${stat.homeValue ?? 0} - ${stat.awayValue ?? 0}');
        }
        buffer.writeln('');
      }

      // Compositions
      if (lineups.isNotEmpty) {
        buffer.writeln('COMPOSITIONS:');
        for (final lineup in lineups) {
          buffer.writeln('${lineup.teamName} (${lineup.formation}):');
          if (lineup.coachName != null) {
            buffer.writeln('  Entraîneur: ${lineup.coachName}');
          }
          buffer.writeln('  Titulaires: ${lineup.startingXI.map((p) => p.name).join(", ")}');
          buffer.writeln('');
        }
      }

      return buffer.toString();
    } catch (e) {
      return _formatMatch(match);
    }
  }

  /// Récupère les détails du dernier match terminé
  Future<String> _getLastMatchDetails() async {
    try {
      final results = await _footballService.getResults(limit: 1);
      if (results.isEmpty) {
        return 'Aucun match terminé récemment.';
      }
      return await _getMatchDetailsWithEvents(results.first);
    } catch (e) {
      return 'Impossible de récupérer les détails du match.';
    }
  }

  /// Récupère le match d'une équipe à une date relative (0=aujourd'hui, -1=hier, 1=demain)
  Future<String> _getTeamMatchByDate(String teamName, int daysOffset) async {
    try {
      final targetDate = DateTime.now().add(Duration(days: daysOffset));
      final matches = await _footballService.getMatchesByDate(targetDate);
      
      String dayLabel;
      if (daysOffset == 0) dayLabel = "aujourd'hui";
      else if (daysOffset == -1) dayLabel = "hier";
      else if (daysOffset == 1) dayLabel = "demain";
      else dayLabel = "le ${targetDate.day}/${targetDate.month}/${targetDate.year}";

      // Chercher le match de l'équipe
      Match? teamMatch;
      for (final match in matches) {
        if (match.homeTeam.name.toLowerCase().contains(teamName) ||
            match.awayTeam.name.toLowerCase().contains(teamName)) {
          teamMatch = match;
          break;
        }
      }

      if (teamMatch == null) {
        // Chercher dans tous les matchs si pas trouvé à cette date
        final allMatches = await _footballService.getAllMatches();
        for (final match in allMatches) {
          final matchDate = match.dateTime;
          final isSameDay = matchDate.year == targetDate.year &&
              matchDate.month == targetDate.month &&
              matchDate.day == targetDate.day;
          
          if (isSameDay && (match.homeTeam.name.toLowerCase().contains(teamName) ||
              match.awayTeam.name.toLowerCase().contains(teamName))) {
            teamMatch = match;
            break;
          }
        }
      }

      if (teamMatch == null) {
        return 'Aucun match trouvé pour ${_capitalizeTeam(teamName)} $dayLabel.';
      }

      // Récupérer les détails complets
      return await _getMatchDetailsWithEvents(teamMatch);
    } catch (e) {
      return 'Impossible de récupérer les informations du match.';
    }
  }

  /// Récupère les meilleurs buteurs
  Future<String> _getTopScorersInfo() async {
    try {
      final scorers = await _footballService.getTopScorers(limit: 10);
      if (scorers.isEmpty) {
        return 'Le classement des buteurs n\'est pas encore disponible.';
      }

      final buffer = StringBuffer('MEILLEURS BUTEURS CAN 2025:\n\n');
      for (int i = 0; i < scorers.length; i++) {
        final s = scorers[i];
        buffer.writeln('${i + 1}. ${s.playerName} (${s.teamName}) - ${s.goals} buts');
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les meilleurs buteurs.';
    }
  }

  /// Récupère les meilleurs passeurs
  Future<String> _getTopAssistsInfo() async {
    try {
      final assisters = await _footballService.getTopAssists(limit: 10);
      if (assisters.isEmpty) {
        return 'Le classement des passeurs n\'est pas encore disponible.';
      }

      final buffer = StringBuffer('MEILLEURS PASSEURS CAN 2025:\n\n');
      for (int i = 0; i < assisters.length; i++) {
        final a = assisters[i];
        buffer.writeln('${i + 1}. ${a.playerName} (${a.teamName}) - ${a.assists} passes décisives');
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les meilleurs passeurs.';
    }
  }

  /// Récupère l'historique des confrontations
  Future<String> _getHeadToHeadInfo(String team1, String team2) async {
    try {
      final team1Id = _footballService.getTeamIdByName(team1);
      final team2Id = _footballService.getTeamIdByName(team2);

      if (team1Id == null || team2Id == null) {
        return 'Équipe non trouvée. Vérifiez l\'orthographe.';
      }

      final h2h = await _footballService.getHeadToHead(team1Id, team2Id);
      if (h2h == null) {
        return 'Pas d\'historique de confrontations disponible.';
      }

      final buffer = StringBuffer();
      buffer.writeln('CONFRONTATIONS: ${h2h.team1} vs ${h2h.team2}');
      buffer.writeln('Total: ${h2h.totalMatches} matchs');
      buffer.writeln('${h2h.team1}: ${h2h.team1Wins} victoires');
      buffer.writeln('${h2h.team2}: ${h2h.team2Wins} victoires');
      buffer.writeln('Nuls: ${h2h.draws}');
      buffer.writeln('');

      if (h2h.recentMatches.isNotEmpty) {
        buffer.writeln('Dernières rencontres:');
        for (final m in h2h.recentMatches.take(5)) {
          buffer.writeln('  ${m.date.day}/${m.date.month}/${m.date.year}: ${m.homeTeam} ${m.homeScore}-${m.awayScore} ${m.awayTeam}');
        }
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer l\'historique des confrontations.';
    }
  }

  /// Retourne le groupe d'un pays spécifique
  String _getTeamGroupInfo(String message) {
    final teamName = _extractTeamName(message);
    if (teamName == null) {
      return 'Précise le nom du pays pour connaître son groupe.';
    }

    final groups = {
      'A': ['maroc', 'morocco', 'mali', 'zambie', 'zambia', 'comores', 'comoros'],
      'B': ['egypte', 'egypt', 'égypte', 'afrique du sud', 'south africa', 'angola', 'zimbabwe'],
      'C': ['nigeria', 'tunisie', 'tunisia', 'ouganda', 'uganda', 'tanzanie', 'tanzania'],
      'D': ['senegal', 'sénégal', 'rd congo', 'dr congo', 'benin', 'bénin', 'botswana'],
      'E': ['algerie', 'algérie', 'algeria', 'burkina faso', 'guinee equatoriale', 'guinée équatoriale', 'equatorial guinea', 'soudan', 'sudan'],
      'F': ['cote d\'ivoire', 'côte d\'ivoire', 'ivory coast', 'cameroun', 'cameroon', 'gabon', 'mozambique'],
    };

    for (final entry in groups.entries) {
      if (entry.value.any((t) => teamName.contains(t) || t.contains(teamName))) {
        final teamList = entry.value.where((t) => t == entry.value.first || 
            t == 'mali' || t == 'angola' || t == 'nigeria' || t == 'senegal' || t == 'algerie' || t == 'cameroun')
            .join(', ');
        
        final allTeams = _getGroupTeamNames(entry.key);
        return 'Le ${_capitalizeTeam(teamName)} est dans le GROUPE ${entry.key} avec: $allTeams';
      }
    }
    return 'Pays non trouvé dans les équipes qualifiées.';
  }

  String _getGroupTeamNames(String group) {
    switch (group) {
      case 'A': return 'Maroc, Mali, Zambie, Comores';
      case 'B': return 'Égypte, Afrique du Sud, Angola, Zimbabwe';
      case 'C': return 'Nigeria, Tunisie, Ouganda, Tanzanie';
      case 'D': return 'Sénégal, RD Congo, Bénin, Botswana';
      case 'E': return 'Algérie, Burkina Faso, Guinée Équatoriale, Soudan';
      case 'F': return 'Côte d\'Ivoire, Cameroun, Gabon, Mozambique';
      default: return '';
    }
  }

  String _capitalizeTeam(String team) {
    return team.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  /// Retourne les équipes d'un groupe spécifique
  String _getGroupTeamsInfo(String message) {
    String? group;
    if (message.contains('groupe a') || message.contains('group a')) group = 'A';
    else if (message.contains('groupe b') || message.contains('group b')) group = 'B';
    else if (message.contains('groupe c') || message.contains('group c')) group = 'C';
    else if (message.contains('groupe d') || message.contains('group d')) group = 'D';
    else if (message.contains('groupe e') || message.contains('group e')) group = 'E';
    else if (message.contains('groupe f') || message.contains('group f')) group = 'F';

    if (group == null) {
      return '''Voici tous les groupes de la CAN 2025:
Groupe A: Maroc, Mali, Zambie, Comores
Groupe B: Égypte, Afrique du Sud, Angola, Zimbabwe
Groupe C: Nigeria, Tunisie, Ouganda, Tanzanie
Groupe D: Sénégal, RD Congo, Bénin, Botswana
Groupe E: Algérie, Burkina Faso, Guinée Équatoriale, Soudan
Groupe F: Côte d'Ivoire, Cameroun, Gabon, Mozambique''';
    }

    return 'GROUPE $group: ${_getGroupTeamNames(group)}';
  }

  /// Récupère l'effectif d'une équipe
  Future<String> _getTeamSquadInfo(String teamName) async {
    try {
      final teamId = _footballService.getTeamIdByName(teamName);
      if (teamId == null) {
        return 'Équipe non trouvée.';
      }

      final squad = await _footballService.getTeamSquad(teamId);
      if (squad.isEmpty) {
        return 'L\'effectif de cette équipe n\'est pas encore disponible.';
      }

      final buffer = StringBuffer('EFFECTIF ${_capitalizeTeam(teamName)}:\n\n');
      
      final goalkeepers = squad.where((p) => p['position'] == 'Goalkeeper').toList();
      final defenders = squad.where((p) => p['position'] == 'Defender').toList();
      final midfielders = squad.where((p) => p['position'] == 'Midfielder').toList();
      final attackers = squad.where((p) => p['position'] == 'Attacker').toList();

      if (goalkeepers.isNotEmpty) {
        buffer.writeln('Gardiens: ${goalkeepers.map((p) => p['name']).join(', ')}');
      }
      if (defenders.isNotEmpty) {
        buffer.writeln('Défenseurs: ${defenders.map((p) => p['name']).join(', ')}');
      }
      if (midfielders.isNotEmpty) {
        buffer.writeln('Milieux: ${midfielders.map((p) => p['name']).join(', ')}');
      }
      if (attackers.isNotEmpty) {
        buffer.writeln('Attaquants: ${attackers.map((p) => p['name']).join(', ')}');
      }

      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer l\'effectif.';
    }
  }

  /// Récupère l'entraîneur d'une équipe
  Future<String> _getTeamCoachInfo(String teamName) async {
    try {
      final teamId = _footballService.getTeamIdByName(teamName);
      if (teamId == null) {
        return 'Équipe non trouvée.';
      }

      final coach = await _footballService.getTeamCoach(teamId);
      if (coach == null) {
        return 'Information sur l\'entraîneur non disponible.';
      }

      return '''Entraîneur ${_capitalizeTeam(teamName)}:
Nom: ${coach['name']}
Nationalité: ${coach['nationality'] ?? 'Non spécifié'}
Âge: ${coach['age'] ?? 'Non spécifié'}''';
    } catch (e) {
      return 'Impossible de récupérer les informations de l\'entraîneur.';
    }
  }

  String _getAllCoachesInfo() {
    return '''Sélectionneurs CAN 2025:
🇲🇦 Maroc: Walid Regragui
🇲🇱 Mali: Tom Saintfiet
🇿🇲 Zambie: Avram Grant
🇰🇲 Comores: Amir Abdou
🇪🇬 Égypte: Hossam Hassan
🇿🇦 Afrique du Sud: Hugo Broos
🇦🇴 Angola: Pedro Gonçalves
🇿🇼 Zimbabwe: Jairos Tapera
🇳🇬 Nigeria: Augustine Eguavoen
🇹🇳 Tunisie: Faouzi Benzarti
🇺🇬 Ouganda: Paul Put
🇹🇿 Tanzanie: Hemed Suleiman
🇸🇳 Sénégal: Aliou Cissé
🇨🇩 RD Congo: Sébastien Desabre
🇧🇯 Bénin: Gernot Rohr
🇧🇼 Botswana: Morena Ramoreboli
🇩🇿 Algérie: Vladimir Petkovic
🇧🇫 Burkina Faso: Brama Traoré
🇬🇶 Guinée Équatoriale: Juan Micha
🇸🇩 Soudan: Kwesi Appiah
🇨🇮 Côte d'Ivoire: Emerse Faé
🇨🇲 Cameroun: Marc Brys
🇬🇦 Gabon: Thierry Mouyouma
🇲🇿 Mozambique: Chiquinho Conde''';
  }

  /// Récupère les blessures d'une équipe
  Future<String> _getInjuriesInfo(String teamName) async {
    try {
      final teamId = _footballService.getTeamIdByName(teamName);
      if (teamId == null) {
        return 'Équipe non trouvée.';
      }

      final injuries = await _footballService.getInjuries(teamId: teamId);
      if (injuries.isEmpty) {
        return 'Aucun joueur blessé signalé pour ${_capitalizeTeam(teamName)}.';
      }

      final buffer = StringBuffer('BLESSURES ${_capitalizeTeam(teamName)}:\n\n');
      for (final injury in injuries.take(10)) {
        final player = injury['player'];
        buffer.writeln('• ${player['name']} - ${injury['player']['reason'] ?? 'Blessure'}');
      }
      return buffer.toString();
    } catch (e) {
      return 'Impossible de récupérer les informations sur les blessures.';
    }
  }

  /// Récupère une prédiction de match
  Future<String> _getPredictionInfo(String message) async {
    try {
      final teamName = _extractTeamName(message);
      if (teamName == null) {
        return 'Précise les équipes pour obtenir une prédiction.';
      }

      final upcoming = await _footballService.getUpcomingMatches(limit: 10);
      Match? targetMatch;
      
      for (final match in upcoming) {
        if (match.homeTeam.name.toLowerCase().contains(teamName) ||
            match.awayTeam.name.toLowerCase().contains(teamName)) {
          targetMatch = match;
          break;
        }
      }

      if (targetMatch == null) {
        return 'Aucun match à venir trouvé pour cette équipe.';
      }

      final prediction = await _footballService.getMatchPredictions(targetMatch.id);
      if (prediction == null) {
        return '''Match à venir: ${targetMatch.homeTeam.name} vs ${targetMatch.awayTeam.name}
Date: ${targetMatch.dateTime.day}/${targetMatch.dateTime.month}/${targetMatch.dateTime.year}
Prédiction non disponible pour ce match.''';
      }

      final predictions = prediction['predictions'] ?? {};
      final winner = predictions['winner']?['name'] ?? 'Incertain';
      final advice = predictions['advice'] ?? '';

      return '''PRÉDICTION: ${targetMatch.homeTeam.name} vs ${targetMatch.awayTeam.name}
Date: ${targetMatch.dateTime.day}/${targetMatch.dateTime.month}/${targetMatch.dateTime.year}
Favori: $winner
Conseil: $advice''';
    } catch (e) {
      return 'Impossible de récupérer la prédiction.';
    }
  }

  void _trimHistory() {
    if (_conversationHistory.length > 21) {
      final systemMessage = _conversationHistory.first;
      _conversationHistory.removeRange(1, _conversationHistory.length - 20);
      if (_conversationHistory.first.role != 'system') {
        _conversationHistory.insert(0, systemMessage);
      }
    }
  }

  void resetConversation() {
    final systemMessage = _conversationHistory.first;
    _conversationHistory.clear();
    _conversationHistory.add(systemMessage);
  }

  Future<String> generateMatchSummary(String homeTeam, String awayTeam, int homeScore, int awayScore) async {
    final prompt = '''Résumé du match CAN 2025:
$homeTeam $homeScore - $awayScore $awayTeam
Génère un résumé de 2-3 phrases.''';
    return await chat(prompt);
  }
}

