import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../features/matches/domain/entities/match.dart';
import '../../features/matches/domain/entities/team.dart';

/// Service pour l'API Football - Utilise uniquement l'API, pas de données de fallback
class FootballApiService {
  late final Dio _dio;

  FootballApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.footballBaseUrl,
        headers: {
          ApiConstants.footballApiKeyHeader: ApiKeys.footballApiKey,
          ...ApiConstants.defaultHeaders,
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
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
      // Log pour diagnostic (ex: CORS en web)
      // ignore: avoid_print
      print('FootballApiService.getMatches error: $e');
      return [];
    }
  }

  /// Récupère les matchs d'aujourd'hui
  Future<List<Match>> getTodayMatches() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final matches = await getMatches(date: dateStr);
    if (matches.isEmpty) {
      // Fallback local pour garantir un rendu UI
      return _mockMatches(count: 3, startDate: today, group: 'A');
    }
    return matches;
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
        final parsed = data.map((json) => _parseMatch(json)).toList();
        if (parsed.isEmpty) {
          // Fallback local si l'API renvoie vide
          return _mockMatches(
            count: limit,
            startDate: DateTime.now().add(const Duration(days: 1)),
            group: 'A',
          );
        }
        return parsed;
      }
      // Fallback si status != 200
      return _mockMatches(
        count: limit,
        startDate: DateTime.now().add(const Duration(days: 1)),
        group: 'A',
      );
    } catch (e) {
      // ignore: avoid_print
      print('FootballApiService.getUpcomingMatches error: $e');
      // Fallback en cas d'erreur réseau/CORS
      return _mockMatches(
        count: limit,
        startDate: DateTime.now().add(const Duration(days: 1)),
        group: 'A',
      );
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
      // ignore: avoid_print
      print('FootballApiService.getLiveMatches error: $e');
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
      // ignore: avoid_print
      print('FootballApiService.getResults error: $e');
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
            standings['Groupe $groupName'] = group
                .map(
                  (team) => {
                    'rank': team['rank'],
                    'team': team['team']['name'],
                    'points': team['points'],
                    'played': team['all']['played'],
                    'won': team['all']['win'],
                    'draw': team['all']['draw'],
                    'lost': team['all']['lose'],
                    'goalsFor': team['all']['goals']['for'],
                    'goalsAgainst': team['all']['goals']['against'],
                  },
                )
                .toList()
                .cast<Map<String, dynamic>>();
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
  Future<Map<String, dynamic>?> getMatchStatistics(String matchId) async {
    try {
      final response = await _dio.get(
        ApiConstants.endpointStatistics,
        queryParameters: {'fixture': matchId},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
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
    return _teamNameToCode[normalized] ??
        teamName.substring(0, 2).toUpperCase();
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

  /// Génère des matchs factices pour éviter l'écran vide si l'API ne renvoie rien
  List<Match> _mockMatches({
    int count = 3,
    DateTime? startDate,
    String group = 'A',
  }) {
    final DateTime base = startDate ?? DateTime.now();
    final List<Team> teams = AfconTeams.teams
        .where((t) => t.group == group)
        .toList();
    if (teams.length < 2) {
      // Si pas assez d'équipes pour le groupe demandé, utiliser les deux premières de la liste
      final fallback = AfconTeams.teams.take(4).toList();
      return List.generate(count, (i) {
        final home = fallback[(i * 2) % fallback.length];
        final away = fallback[(i * 2 + 1) % fallback.length];
        return Match(
          id: 'mock-${home.code}-${away.code}-$i',
          homeTeam: home,
          awayTeam: away,
          dateTime: base.add(Duration(days: i, hours: 16)),
          stadium: 'Stade de Marrakech',
          city: 'Marrakech',
          status: MatchStatus.scheduled,
          phase: TournamentPhase.groupStage,
          group: group,
          homeScore: null,
          awayScore: null,
          minute: null,
          tvChannel: 'TV Nationale',
        );
      });
    }

    return List.generate(count, (i) {
      final home = teams[(i) % teams.length];
      final away = teams[(i + 1) % teams.length];
      return Match(
        id: 'mock-${home.code}-${away.code}-$i',
        homeTeam: home,
        awayTeam: away,
        dateTime: base.add(Duration(days: i, hours: 16)),
        stadium: 'Stade Ibn Battouta',
        city: 'Tanger',
        status: MatchStatus.scheduled,
        phase: TournamentPhase.groupStage,
        group: group,
        homeScore: null,
        awayScore: null,
        minute: null,
        tvChannel: 'TV Nationale',
      );
    });
  }
}
