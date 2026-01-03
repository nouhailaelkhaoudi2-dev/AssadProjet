import 'package:equatable/equatable.dart';
import 'team.dart';

/// Entité représentant le classement d'une équipe dans un groupe
class Standing extends Equatable {
  final int rank;
  final Team team;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final String group;

  const Standing({
    required this.rank,
    required this.team,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    required this.group,
  });

  @override
  List<Object?> get props => [
        rank,
        team,
        played,
        won,
        drawn,
        lost,
        goalsFor,
        goalsAgainst,
        points,
        group,
      ];

  /// Différence de buts
  int get goalDifference => goalsFor - goalsAgainst;

  /// Affichage de la différence de buts
  String get goalDifferenceDisplay {
    final diff = goalDifference;
    if (diff > 0) return '+$diff';
    return '$diff';
  }

  /// Forme récente (pour affichage V-N-D)
  /// Cette propriété serait normalement alimentée par l'API
  List<String> get recentForm => [];

  Standing copyWith({
    int? rank,
    Team? team,
    int? played,
    int? won,
    int? drawn,
    int? lost,
    int? goalsFor,
    int? goalsAgainst,
    int? points,
    String? group,
  }) {
    return Standing(
      rank: rank ?? this.rank,
      team: team ?? this.team,
      played: played ?? this.played,
      won: won ?? this.won,
      drawn: drawn ?? this.drawn,
      lost: lost ?? this.lost,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      points: points ?? this.points,
      group: group ?? this.group,
    );
  }
}

/// Représente le classement complet d'un groupe
class GroupStanding extends Equatable {
  final String group;
  final List<Standing> standings;

  const GroupStanding({
    required this.group,
    required this.standings,
  });

  @override
  List<Object?> get props => [group, standings];

  /// Retourne les équipes qualifiées (top 2)
  List<Standing> get qualifiedTeams {
    if (standings.length < 2) return standings;
    return standings.take(2).toList();
  }

  /// Retourne le meilleur 3ème potentiel
  Standing? get thirdPlace {
    if (standings.length < 3) return null;
    return standings[2];
  }
}
