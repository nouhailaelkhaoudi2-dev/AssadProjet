import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/matches/domain/entities/team.dart';

class FavoriteTeamNotifier extends StateNotifier<Team?> {
  static const String _storageKey = 'favorite_team_code';
  
  FavoriteTeamNotifier() : super(null) {
    _loadFavoriteTeam();
  }

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
    } catch (_) {}
  }

  Future<void> setFavoriteTeam(Team team) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, team.code);
      state = team;
    } catch (_) {}
  }

  Future<void> clearFavoriteTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      state = null;
    } catch (_) {}
  }
}

final favoriteTeamProvider = StateNotifierProvider<FavoriteTeamNotifier, Team?>((ref) {
  return FavoriteTeamNotifier();
});

final isTeamFavoriteProvider = Provider.family<bool, String>((ref, teamCode) {
  final favoriteTeam = ref.watch(favoriteTeamProvider);
  return favoriteTeam?.code == teamCode;
});
