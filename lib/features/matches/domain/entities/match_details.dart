import 'package:equatable/equatable.dart';

/// Événement d'un match (but, carton, remplacement)
class MatchEvent extends Equatable {
  final int minute;
  final int? extraMinute;
  final String teamName;
  final String playerName;
  final String? assistName;
  final EventType type;
  final String? detail;

  const MatchEvent({
    required this.minute,
    this.extraMinute,
    required this.teamName,
    required this.playerName,
    this.assistName,
    required this.type,
    this.detail,
  });

  @override
  List<Object?> get props => [minute, extraMinute, teamName, playerName, type];

  String get timeDisplay {
    if (extraMinute != null && extraMinute! > 0) {
      return "$minute'+$extraMinute";
    }
    return "$minute'";
  }

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    final time = json['time'];
    final team = json['team'];
    final player = json['player'];
    final assist = json['assist'];

    return MatchEvent(
      minute: time['elapsed'] ?? 0,
      extraMinute: time['extra'],
      teamName: team['name'] ?? '',
      playerName: player['name'] ?? 'Inconnu',
      assistName: assist?['name'],
      type: _parseEventType(json['type']),
      detail: json['detail'],
    );
  }

  static EventType _parseEventType(String? type) {
    switch (type?.toLowerCase()) {
      case 'goal':
        return EventType.goal;
      case 'card':
        return EventType.card;
      case 'subst':
        return EventType.substitution;
      case 'var':
        return EventType.var_;
      default:
        return EventType.other;
    }
  }
}

enum EventType {
  goal,
  card,
  substitution,
  var_,
  other,
}

extension EventTypeExtension on EventType {
  String get emoji {
    switch (this) {
      case EventType.goal:
        return '⚽';
      case EventType.card:
        return '🟨';
      case EventType.substitution:
        return '🔄';
      case EventType.var_:
        return '📺';
      case EventType.other:
        return '•';
    }
  }
}

/// Joueur dans une composition
class LineupPlayer extends Equatable {
  final int? number;
  final String name;
  final String position;
  final String? grid;

  const LineupPlayer({
    this.number,
    required this.name,
    required this.position,
    this.grid,
  });

  @override
  List<Object?> get props => [number, name, position];

  factory LineupPlayer.fromJson(Map<String, dynamic> json) {
    final player = json['player'];
    return LineupPlayer(
      number: player['number'],
      name: player['name'] ?? '',
      position: player['pos'] ?? '',
      grid: player['grid'],
    );
  }
}

/// Composition d'une équipe
class TeamLineup extends Equatable {
  final String teamName;
  final String formation;
  final String? coachName;
  final List<LineupPlayer> startingXI;
  final List<LineupPlayer> substitutes;

  const TeamLineup({
    required this.teamName,
    required this.formation,
    this.coachName,
    required this.startingXI,
    required this.substitutes,
  });

  @override
  List<Object?> get props => [teamName, formation, startingXI];

  factory TeamLineup.fromJson(Map<String, dynamic> json) {
    final team = json['team'];
    final coach = json['coach'];
    final startXI = json['startXI'] as List? ?? [];
    final subs = json['substitutes'] as List? ?? [];

    return TeamLineup(
      teamName: team['name'] ?? '',
      formation: json['formation'] ?? '4-3-3',
      coachName: coach?['name'],
      startingXI: startXI.map((p) => LineupPlayer.fromJson(p)).toList(),
      substitutes: subs.map((p) => LineupPlayer.fromJson(p)).toList(),
    );
  }
}

/// Statistique individuelle d'un match
class MatchStatistic extends Equatable {
  final String type;
  final dynamic homeValue;
  final dynamic awayValue;

  const MatchStatistic({
    required this.type,
    required this.homeValue,
    required this.awayValue,
  });

  @override
  List<Object?> get props => [type, homeValue, awayValue];

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'shots on goal':
        return 'Tirs cadrés';
      case 'shots off goal':
        return 'Tirs non cadrés';
      case 'total shots':
        return 'Total tirs';
      case 'blocked shots':
        return 'Tirs bloqués';
      case 'shots insidebox':
        return 'Tirs dans la surface';
      case 'shots outsidebox':
        return 'Tirs hors surface';
      case 'fouls':
        return 'Fautes';
      case 'corner kicks':
        return 'Corners';
      case 'offsides':
        return 'Hors-jeu';
      case 'ball possession':
        return 'Possession';
      case 'yellow cards':
        return 'Cartons jaunes';
      case 'red cards':
        return 'Cartons rouges';
      case 'goalkeeper saves':
        return 'Arrêts gardien';
      case 'total passes':
        return 'Passes totales';
      case 'passes accurate':
        return 'Passes réussies';
      case 'passes %':
        return 'Précision passes';
      default:
        return type;
    }
  }
}

/// Statistiques complètes d'un match
class MatchStatistics extends Equatable {
  final String homeTeam;
  final String awayTeam;
  final List<MatchStatistic> stats;

  const MatchStatistics({
    required this.homeTeam,
    required this.awayTeam,
    required this.stats,
  });

  @override
  List<Object?> get props => [homeTeam, awayTeam, stats];

  factory MatchStatistics.fromJson(List<dynamic> json) {
    if (json.length < 2) {
      return const MatchStatistics(homeTeam: '', awayTeam: '', stats: []);
    }

    final homeData = json[0];
    final awayData = json[1];
    final homeStats = homeData['statistics'] as List? ?? [];
    final awayStats = awayData['statistics'] as List? ?? [];

    final stats = <MatchStatistic>[];
    for (int i = 0; i < homeStats.length; i++) {
      stats.add(MatchStatistic(
        type: homeStats[i]['type'] ?? '',
        homeValue: homeStats[i]['value'],
        awayValue: i < awayStats.length ? awayStats[i]['value'] : null,
      ));
    }

    return MatchStatistics(
      homeTeam: homeData['team']['name'] ?? '',
      awayTeam: awayData['team']['name'] ?? '',
      stats: stats,
    );
  }
}

/// Meilleur buteur
class TopScorer extends Equatable {
  final String playerName;
  final String teamName;
  final String? teamLogo;
  final String? playerPhoto;
  final int goals;
  final int assists;
  final int matchesPlayed;

  const TopScorer({
    required this.playerName,
    required this.teamName,
    this.teamLogo,
    this.playerPhoto,
    required this.goals,
    required this.assists,
    required this.matchesPlayed,
  });

  @override
  List<Object?> get props => [playerName, teamName, goals, assists];

  factory TopScorer.fromJson(Map<String, dynamic> json) {
    final player = json['player'];
    final stats = json['statistics'] as List? ?? [];
    final firstStat = stats.isNotEmpty ? stats[0] : {};
    final team = firstStat['team'] ?? {};
    final goals = firstStat['goals'] ?? {};

    return TopScorer(
      playerName: player['name'] ?? '',
      teamName: team['name'] ?? '',
      teamLogo: team['logo'],
      playerPhoto: player['photo'],
      goals: goals['total'] ?? 0,
      assists: goals['assists'] ?? 0,
      matchesPlayed: firstStat['games']?['appearences'] ?? 0,
    );
  }
}

/// Confrontation directe (Head-to-Head)
class HeadToHead extends Equatable {
  final String team1;
  final String team2;
  final int team1Wins;
  final int team2Wins;
  final int draws;
  final List<H2HMatch> recentMatches;

  const HeadToHead({
    required this.team1,
    required this.team2,
    required this.team1Wins,
    required this.team2Wins,
    required this.draws,
    required this.recentMatches,
  });

  @override
  List<Object?> get props => [team1, team2, team1Wins, team2Wins, draws];

  int get totalMatches => team1Wins + team2Wins + draws;
}

class H2HMatch extends Equatable {
  final DateTime date;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String competition;

  const H2HMatch({
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.competition,
  });

  @override
  List<Object?> get props => [date, homeTeam, awayTeam, homeScore, awayScore];

  factory H2HMatch.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'];
    final teams = json['teams'];
    final goals = json['goals'];
    final league = json['league'];

    return H2HMatch(
      date: DateTime.parse(fixture['date']),
      homeTeam: teams['home']['name'] ?? '',
      awayTeam: teams['away']['name'] ?? '',
      homeScore: goals['home'] ?? 0,
      awayScore: goals['away'] ?? 0,
      competition: league['name'] ?? '',
    );
  }
}


