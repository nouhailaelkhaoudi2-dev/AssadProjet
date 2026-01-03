import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/matches/domain/entities/team.dart';

/// Provider pour l'équipe favorite de l'utilisateur
class FavoriteTeamNotifier extends StateNotifier<Team?> {
  static const String _storageKey = 'favorite_team_code';
  
  FavoriteTeamNotifier() : super(null) {
    _loadFavoriteTeam();
  }

  /// Charge l'équipe favorite depuis le stockage local
  Future<void> _loadFavoriteTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teamCode = prefs.getString(_storageKey);
      
      if (teamCode != null) {
        final team = AfconTeams.getTeamByCode(teamCode);
        if (team != null) {
          state = team;
        }
      }
    } catch (e) {
      // Ignorer les erreurs de chargement
    }
  }

  /// Définit l'équipe favorite
  Future<void> setFavoriteTeam(Team team) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, team.code);
      state = team;
    } catch (e) {
      // Ignorer les erreurs de sauvegarde
    }
  }

  /// Supprime l'équipe favorite
  Future<void> clearFavoriteTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      state = null;
    } catch (e) {
      // Ignorer les erreurs
    }
  }
}

/// Provider pour l'équipe favorite
final favoriteTeamProvider = StateNotifierProvider<FavoriteTeamNotifier, Team?>((ref) {
  return FavoriteTeamNotifier();
});

/// Provider pour vérifier si une équipe est favorite
final isTeamFavoriteProvider = Provider.family<bool, String>((ref, teamCode) {
  final favoriteTeam = ref.watch(favoriteTeamProvider);
  return favoriteTeam?.code == teamCode;
});

