import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../features/matches/domain/entities/match.dart';
import '../../features/matches/domain/entities/match_details.dart';
import '../../features/matches/domain/entities/team.dart';

/// Service pour l'API Football - Utilise uniquement l'API, pas de données de fallback
class FootballApiService {
  late final Dio _dio;

  FootballApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.footballBaseUrl,
      headers: {
        ApiConstants.footballApiKeyHeader: ApiKeys.footballApiKey,
        ...ApiConstants.defaultHeaders,
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  /// Récupère les matchs de la CAN 2025
  Future<List<Match>> getMatches({
    String? date,
    String? status,
    int? round,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'league': ApiConstants.afconLeagueId,
        'season': ApiConstants.afconSeason,
      };

      if (date != null) queryParams['date'] = date;
      if (status != null) queryParams['status'] = status;
      if (round != null) queryParams['round'] = round;

      final response = await _dio.get(
        ApiConstants.endpointFixtures,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.map((json) => _parseMatch(json)).toList();
      }
      return [];
    } catch (e) {
      // Pas de fallback - retourner liste vide en cas d'erreur
      return [];
    }
  }

  /// Récupère les matchs d'aujourd'hui
  Future<List<Match>> getTodayMatches() async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getMatches(date: dateStr);
  }

  /// Récupère les matchs à venir
  Future<List<Match>> getUpcomingMatches({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointFixtures,
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
          'status': 'NS', // Not Started
          'next': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.map((json) => _parseMatch(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les matchs en direct
  Future<List<Match>> getLiveMatches() async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointFixtures,
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
          'live': 'all',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.map((json) => _parseMatch(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les résultats (matchs terminés)
  Future<List<Match>> getResults({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointFixtures,
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
          'status': 'FT', // Full Time
          'last': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.map((json) => _parseMatch(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les matchs d'une date spécifique
  Future<List<Match>> getMatchesByDate(DateTime date) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return getMatches(date: dateStr);
  }

  /// Récupère tous les matchs de la compétition
  Future<List<Match>> getAllMatches() async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointFixtures,
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.map((json) => _parseMatch(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les matchs par phase (round of 16, quarter, semi, final)
  Future<List<Match>> getMatchesByPhase(String phase) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointFixtures,
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
          'round': phase,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.map((json) => _parseMatch(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les rounds disponibles pour la compétition
  Future<List<String>> getAvailableRounds() async {
    try {
      final response = await _dio.get(
        '/fixtures/rounds',
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère le classement
  Future<Map<String, List<Map<String, dynamic>>>> getStandings() async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointStandings,
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
        },
      );

      if (response.statusCode == 200) {
        final standings = <String, List<Map<String, dynamic>>>{};
        final data = response.data['response'] as List;

        if (data.isNotEmpty) {
          final league = data[0]['league'];
          final groups = league['standings'] as List;

          for (int i = 0; i < groups.length; i++) {
            final group = groups[i] as List;
            final groupName = String.fromCharCode(65 + i); // A, B, C...
            standings['Groupe $groupName'] = group.map((team) => {
              'rank': team['rank'],
              'team': team['team']['name'],
              'points': team['points'],
              'played': team['all']['played'],
              'won': team['all']['win'],
              'draw': team['all']['draw'],
              'lost': team['all']['lose'],
              'goalsFor': team['all']['goals']['for'],
              'goalsAgainst': team['all']['goals']['against'],
            }).toList().cast<Map<String, dynamic>>();
          }
        }
        return standings;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Récupère les statistiques d'un match
  Future<MatchStatistics?> getMatchStatistics(String matchId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointStatistics,
        queryParameters: {'fixture': matchId},
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        if (data.isNotEmpty) {
          return MatchStatistics.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère les événements d'un match (buts, cartons, remplacements)
  Future<List<MatchEvent>> getMatchEvents(String matchId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointEvents,
        queryParameters: {'fixture': matchId},
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.map((e) => MatchEvent.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les compositions des équipes pour un match
  Future<List<TeamLineup>> getMatchLineups(String matchId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointLineups,
        queryParameters: {'fixture': matchId},
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.map((l) => TeamLineup.fromJson(l)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les meilleurs buteurs de la CAN 2025
  Future<List<TopScorer>> getTopScorers({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointTopScorers,
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.take(limit).map((p) => TopScorer.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les meilleurs passeurs de la CAN 2025
  Future<List<TopScorer>> getTopAssists({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointTopAssists,
        queryParameters: {
          'league': ApiConstants.afconLeagueId,
          'season': ApiConstants.afconSeason,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.take(limit).map((p) => TopScorer.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère l'historique des confrontations entre deux équipes
  Future<HeadToHead?> getHeadToHead(int team1Id, int team2Id, {int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointH2H,
        queryParameters: {
          'h2h': '$team1Id-$team2Id',
          'last': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        if (data.isEmpty) return null;

        final matches = data.map((m) => H2HMatch.fromJson(m)).toList();

        int team1Wins = 0;
        int team2Wins = 0;
        int draws = 0;

        String team1Name = '';
        String team2Name = '';

        for (final match in matches) {
          if (team1Name.isEmpty) {
            team1Name = match.homeTeam;
            team2Name = match.awayTeam;
          }

          if (match.homeScore > match.awayScore) {
            if (match.homeTeam == team1Name) team1Wins++;
            else team2Wins++;
          } else if (match.awayScore > match.homeScore) {
            if (match.awayTeam == team1Name) team1Wins++;
            else team2Wins++;
          } else {
            draws++;
          }
        }

        return HeadToHead(
          team1: team1Name,
          team2: team2Name,
          team1Wins: team1Wins,
          team2Wins: team2Wins,
          draws: draws,
          recentMatches: matches,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère les informations détaillées d'une équipe par son ID
  Future<Map<String, dynamic>?> getTeamInfo(int teamId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointTeams,
        queryParameters: {'id': teamId},
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        if (data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère l'effectif d'une équipe
  Future<List<Map<String, dynamic>>> getTeamSquad(int teamId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointSquads,
        queryParameters: {'team': teamId},
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        if (data.isNotEmpty) {
          final players = data[0]['players'] as List? ?? [];
          return players.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère l'entraîneur d'une équipe
  Future<Map<String, dynamic>?> getTeamCoach(int teamId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointCoaches,
        queryParameters: {'team': teamId},
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        if (data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère les blessures d'une équipe
  Future<List<Map<String, dynamic>>> getInjuries({int? teamId, String? fixtureId}) async {
    try {
      final params = <String, dynamic>{
        'league': ApiConstants.afconLeagueId,
        'season': ApiConstants.afconSeason,
      };
      if (teamId != null) params['team'] = teamId;
      if (fixtureId != null) params['fixture'] = fixtureId;

      final response = await _dio.get(
        ApiConstants.endpointInjuries,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les prédictions pour un match
  Future<Map<String, dynamic>?> getMatchPredictions(String matchId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointPredictions,
        queryParameters: {'fixture': matchId},
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        if (data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère un match spécifique par son ID
  Future<Match?> getMatchById(String matchId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointFixtures,
        queryParameters: {'id': matchId},
      );

      if (response.statusCode == 200) {
        final data = response.data['response'] as List;
        if (data.isNotEmpty) {
          return _parseMatch(data[0]);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère les détails complets d'un match (score, buteurs, stats, compos)
  Future<Map<String, dynamic>> getMatchFullDetails(String matchId) async {
    try {
      final results = await Future.wait([
        getMatchById(matchId),
        getMatchEvents(matchId),
        getMatchStatistics(matchId),
        getMatchLineups(matchId),
      ]);

      return {
        'match': results[0] as Match?,
        'events': results[1] as List<MatchEvent>,
        'statistics': results[2] as MatchStatistics?,
        'lineups': results[3] as List<TeamLineup>,
      };
    } catch (e) {
      return {};
    }
  }

  /// Cherche une équipe par nom dans les équipes de la CAN
  int? getTeamIdByName(String teamName) {
    final normalized = teamName.toLowerCase().trim();
    
    // Mapping des noms vers les IDs API Football pour les équipes de la CAN
    const teamIds = {
      'maroc': 1056, 'morocco': 1056,
      'mali': 1062, 
      'zambie': 1087, 'zambia': 1087,
      'comores': 5659, 'comoros': 5659,
      'egypte': 1052, 'egypt': 1052, 'égypte': 1052,
      'afrique du sud': 1082, 'south africa': 1082,
      'angola': 1064,
      'zimbabwe': 1086,
      'nigeria': 1066,
      'tunisie': 1077, 'tunisia': 1077,
      'ouganda': 1083, 'uganda': 1083,
      'tanzanie': 1075, 'tanzania': 1075,
      'senegal': 1072, 'sénégal': 1072,
      'rd congo': 1074, 'dr congo': 1074, 'congo dr': 1074,
      'benin': 1097, 'bénin': 1097,
      'botswana': 1068,
      'algerie': 1049, 'algérie': 1049, 'algeria': 1049,
      'burkina faso': 1078,
      'guinee equatoriale': 1089, 'guinée équatoriale': 1089, 'equatorial guinea': 1089,
      'soudan': 1090, 'sudan': 1090,
      'cote d\'ivoire': 1071, 'côte d\'ivoire': 1071, 'ivory coast': 1071,
      'cameroun': 1073, 'cameroon': 1073,
      'gabon': 1060,
      'mozambique': 1067,
    };
    
    return teamIds[normalized];
  }

  /// Mapping des noms d'équipes vers les codes ISO
  static const Map<String, String> _teamNameToCode = {
    // Groupe A
    'morocco': 'MA',
    'maroc': 'MA',
    'mali': 'ML',
    'zambia': 'ZM',
    'zambie': 'ZM',
    'comoros': 'KM',
    'comores': 'KM',
    // Groupe B
    'egypt': 'EG',
    'egypte': 'EG',
    'égypte': 'EG',
    'south africa': 'ZA',
    'afrique du sud': 'ZA',
    'angola': 'AO',
    'zimbabwe': 'ZW',
    // Groupe C
    'nigeria': 'NG',
    'tunisia': 'TN',
    'tunisie': 'TN',
    'uganda': 'UG',
    'ouganda': 'UG',
    'tanzania': 'TZ',
    'tanzanie': 'TZ',
    // Groupe D
    'senegal': 'SN',
    'sénégal': 'SN',
    'dr congo': 'CD',
    'congo dr': 'CD',
    'rd congo': 'CD',
    'democratic republic of congo': 'CD',
    'benin': 'BJ',
    'bénin': 'BJ',
    'botswana': 'BW',
    // Groupe E
    'algeria': 'DZ',
    'algerie': 'DZ',
    'algérie': 'DZ',
    'burkina faso': 'BF',
    'equatorial guinea': 'GQ',
    'guinée équatoriale': 'GQ',
    'guinee equatoriale': 'GQ',
    'sudan': 'SD',
    'soudan': 'SD',
    // Groupe F
    'ivory coast': 'CI',
    'cote divoire': 'CI',
    'côte d\'ivoire': 'CI',
    'cameroon': 'CM',
    'cameroun': 'CM',
    'gabon': 'GA',
    'mozambique': 'MZ',
    // Autres équipes africaines potentielles
    'ghana': 'GH',
    'congo': 'CG',
    'cape verde': 'CV',
    'guinea': 'GN',
    'guinée': 'GN',
    'guinea-bissau': 'GW',
    'mauritania': 'MR',
    'mauritanie': 'MR',
    'namibia': 'NA',
    'namibie': 'NA',
    'libya': 'LY',
    'libye': 'LY',
    'ethiopia': 'ET',
    'ethiopie': 'ET',
    'kenya': 'KE',
  };

  /// Obtient le code ISO à partir du nom de l'équipe
  String _getCountryCode(String teamName) {
    final normalized = teamName.toLowerCase().trim();
    return _teamNameToCode[normalized] ?? teamName.substring(0, 2).toUpperCase();
  }

  /// Parse un match depuis le JSON de l'API
  Match _parseMatch(Map<String, dynamic> json) {
    final fixture = json['fixture'];
    final teams = json['teams'];
    final goals = json['goals'];
    final league = json['league'];

    final homeTeamData = teams['home'];
    final awayTeamData = teams['away'];

    final homeTeamName = homeTeamData['name'].toString();
    final awayTeamName = awayTeamData['name'].toString();

    // Trouver les équipes dans notre liste ou créer des temporaires avec le bon code
    Team homeTeam = AfconTeams.teams.firstWhere(
      (t) => t.name.toLowerCase() == homeTeamName.toLowerCase(),
      orElse: () => Team(
        id: homeTeamData['id'].toString(),
        name: homeTeamName,
        code: _getCountryCode(homeTeamName),
        group: league['round']?.toString().contains('Group') == true
            ? league['round'].toString().split(' ').last
            : 'A',
        flagUrl: homeTeamData['logo'],
      ),
    );

    Team awayTeam = AfconTeams.teams.firstWhere(
      (t) => t.name.toLowerCase() == awayTeamName.toLowerCase(),
      orElse: () => Team(
        id: awayTeamData['id'].toString(),
        name: awayTeamName,
        code: _getCountryCode(awayTeamName),
        group: league['round']?.toString().contains('Group') == true
            ? league['round'].toString().split(' ').last
            : 'A',
        flagUrl: awayTeamData['logo'],
      ),
    );

    return Match(
      id: fixture['id'].toString(),
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      dateTime: DateTime.parse(fixture['date']),
      stadium: fixture['venue']['name'] ?? 'Stade inconnu',
      city: fixture['venue']['city'] ?? 'Ville inconnue',
      homeScore: goals['home'],
      awayScore: goals['away'],
      status: _parseStatus(fixture['status']['short']),
      phase: _parsePhase(league['round']),
      group: league['round']?.toString().contains('Group') == true
          ? league['round'].toString().split(' ').last
          : null,
      minute: fixture['status']['elapsed'],
    );
  }

  MatchStatus _parseStatus(String status) {
    switch (status) {
      case 'NS':
      case 'TBD':
        return MatchStatus.scheduled;
      case '1H':
      case '2H':
      case 'ET':
      case 'P':
        return MatchStatus.live;
      case 'HT':
        return MatchStatus.halftime;
      case 'FT':
      case 'AET':
      case 'PEN':
        return MatchStatus.finished;
      case 'PST':
      case 'SUSP':
        return MatchStatus.postponed;
      case 'CANC':
      case 'ABD':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.scheduled;
    }
  }

  TournamentPhase _parsePhase(String? round) {
    if (round == null) return TournamentPhase.groupStage;
    final lowerRound = round.toLowerCase();

    if (lowerRound.contains('group')) return TournamentPhase.groupStage;
    if (lowerRound.contains('16') || lowerRound.contains('round of 16')) {
      return TournamentPhase.roundOf16;
    }
    if (lowerRound.contains('quarter')) return TournamentPhase.quarterFinal;
    if (lowerRound.contains('semi')) return TournamentPhase.semiFinal;
    if (lowerRound.contains('3rd') || lowerRound.contains('third')) {
      return TournamentPhase.thirdPlace;
    }
    if (lowerRound.contains('final')) return TournamentPhase.final_;

    return TournamentPhase.groupStage;
  }
}
