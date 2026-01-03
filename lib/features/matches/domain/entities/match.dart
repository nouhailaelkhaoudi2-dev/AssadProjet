import 'package:equatable/equatable.dart';
import 'team.dart';

/// Statut d'un match
enum MatchStatus {
  scheduled,    // Programmé
  live,         // En cours
  halftime,     // Mi-temps
  finished,     // Terminé
  postponed,    // Reporté
  cancelled,    // Annulé
}

/// Extension pour MatchStatus
extension MatchStatusExtension on MatchStatus {
  String get label {
    switch (this) {
      case MatchStatus.scheduled:
        return 'Programmé';
      case MatchStatus.live:
        return 'En direct';
      case MatchStatus.halftime:
        return 'Mi-temps';
      case MatchStatus.finished:
        return 'Terminé';
      case MatchStatus.postponed:
        return 'Reporté';
      case MatchStatus.cancelled:
        return 'Annulé';
    }
  }

  bool get isLive => this == MatchStatus.live || this == MatchStatus.halftime;
  bool get isFinished => this == MatchStatus.finished;
  bool get isUpcoming => this == MatchStatus.scheduled;
}

/// Phase du tournoi
enum TournamentPhase {
  groupStage,
  roundOf16,
  quarterFinal,
  semiFinal,
  thirdPlace,
  final_,
}

extension TournamentPhaseExtension on TournamentPhase {
  String get label {
    switch (this) {
      case TournamentPhase.groupStage:
        return 'Phase de groupes';
      case TournamentPhase.roundOf16:
        return 'Huitièmes de finale';
      case TournamentPhase.quarterFinal:
        return 'Quarts de finale';
      case TournamentPhase.semiFinal:
        return 'Demi-finales';
      case TournamentPhase.thirdPlace:
        return 'Match pour la 3ème place';
      case TournamentPhase.final_:
        return 'Finale';
    }
  }
}

/// Entité représentant un match
class Match extends Equatable {
  final String id;
  final Team homeTeam;
  final Team awayTeam;
  final DateTime dateTime;
  final String stadium;
  final String city;
  final int? homeScore;
  final int? awayScore;
  final MatchStatus status;
  final String? group;
  final TournamentPhase phase;
  final int? minute;
  final String? tvChannel;

  const Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.dateTime,
    required this.stadium,
    required this.city,
    this.homeScore,
    this.awayScore,
    required this.status,
    this.group,
    required this.phase,
    this.minute,
    this.tvChannel,
  });

  @override
  List<Object?> get props => [
        id,
        homeTeam,
        awayTeam,
        dateTime,
        stadium,
        city,
        homeScore,
        awayScore,
        status,
        group,
        phase,
        minute,
        tvChannel,
      ];

  /// Retourne le score formaté (ex: "2 - 1")
  String get scoreDisplay {
    if (homeScore == null || awayScore == null) {
      return 'vs';
    }
    return '$homeScore - $awayScore';
  }

  /// Vérifie si le match est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Vérifie si le match est demain
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  /// Retourne le label de la date relative
  String get relativeDateLabel {
    if (isToday) return "Aujourd'hui";
    if (isTomorrow) return 'Demain';
    return '';
  }

  Match copyWith({
    String? id,
    Team? homeTeam,
    Team? awayTeam,
    DateTime? dateTime,
    String? stadium,
    String? city,
    int? homeScore,
    int? awayScore,
    MatchStatus? status,
    String? group,
    TournamentPhase? phase,
    int? minute,
    String? tvChannel,
  }) {
    return Match(
      id: id ?? this.id,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      dateTime: dateTime ?? this.dateTime,
      stadium: stadium ?? this.stadium,
      city: city ?? this.city,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      status: status ?? this.status,
      group: group ?? this.group,
      phase: phase ?? this.phase,
      minute: minute ?? this.minute,
      tvChannel: tvChannel ?? this.tvChannel,
    );
  }
}
