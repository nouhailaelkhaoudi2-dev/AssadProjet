import 'package:equatable/equatable.dart';

/// Entité représentant une équipe nationale
class Team extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? flagUrl;
  final String group;
  final String? coach;
  final int? fifaRanking;

  const Team({
    required this.id,
    required this.name,
    required this.code,
    this.flagUrl,
    required this.group,
    this.coach,
    this.fifaRanking,
  });

  @override
  List<Object?> get props => [id, name, code, flagUrl, group, coach, fifaRanking];

  /// Retourne l'emoji du drapeau basé sur le code pays
  String get flagEmoji {
    // Convertit le code pays en emoji drapeau
    if (code.length != 2) return '🏳️';
    final int firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCodes([firstLetter, secondLetter]);
  }

  Team copyWith({
    String? id,
    String? name,
    String? code,
    String? flagUrl,
    String? group,
    String? coach,
    int? fifaRanking,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      flagUrl: flagUrl ?? this.flagUrl,
      group: group ?? this.group,
      coach: coach ?? this.coach,
      fifaRanking: fifaRanking ?? this.fifaRanking,
    );
  }
}

/// Liste des équipes qualifiées pour la CAN 2025
class AfconTeams {
  AfconTeams._();

  static const List<Team> teams = [
    // Groupe A
    Team(id: '1', name: 'Maroc', code: 'MA', group: 'A'),
    Team(id: '2', name: 'Mali', code: 'ML', group: 'A'),
    Team(id: '3', name: 'Zambie', code: 'ZM', group: 'A'),
    Team(id: '4', name: 'Comores', code: 'KM', group: 'A'),

    // Groupe B
    Team(id: '5', name: 'Égypte', code: 'EG', group: 'B'),
    Team(id: '6', name: 'Afrique du Sud', code: 'ZA', group: 'B'),
    Team(id: '7', name: 'Angola', code: 'AO', group: 'B'),
    Team(id: '8', name: 'Zimbabwe', code: 'ZW', group: 'B'),

    // Groupe C
    Team(id: '9', name: 'Nigeria', code: 'NG', group: 'C'),
    Team(id: '10', name: 'Tunisie', code: 'TN', group: 'C'),
    Team(id: '11', name: 'Ouganda', code: 'UG', group: 'C'),
    Team(id: '12', name: 'Tanzanie', code: 'TZ', group: 'C'),

    // Groupe D
    Team(id: '13', name: 'Sénégal', code: 'SN', group: 'D'),
    Team(id: '14', name: 'RD Congo', code: 'CD', group: 'D'),
    Team(id: '15', name: 'Bénin', code: 'BJ', group: 'D'),
    Team(id: '16', name: 'Botswana', code: 'BW', group: 'D'),

    // Groupe E
    Team(id: '17', name: 'Algérie', code: 'DZ', group: 'E'),
    Team(id: '18', name: 'Burkina Faso', code: 'BF', group: 'E'),
    Team(id: '19', name: 'Guinée Équatoriale', code: 'GQ', group: 'E'),
    Team(id: '20', name: 'Soudan', code: 'SD', group: 'E'),

    // Groupe F
    Team(id: '21', name: 'Côte d\'Ivoire', code: 'CI', group: 'F'),
    Team(id: '22', name: 'Cameroun', code: 'CM', group: 'F'),
    Team(id: '23', name: 'Gabon', code: 'GA', group: 'F'),
    Team(id: '24', name: 'Mozambique', code: 'MZ', group: 'F'),
  ];

  static Team? getTeamById(String id) {
    try {
      return teams.firstWhere((team) => team.id == id);
    } catch (_) {
      return null;
    }
  }

  static Team? getTeamByCode(String code) {
    try {
      return teams.firstWhere((team) => team.code == code);
    } catch (_) {
      return null;
    }
  }

  static List<Team> getTeamsByGroup(String group) {
    return teams.where((team) => team.group == group).toList();
  }
}
