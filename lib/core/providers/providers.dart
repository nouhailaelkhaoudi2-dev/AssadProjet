import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';

/// Provider pour le client Dio
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Provider pour le thème (clair/sombre)
final themeModeProvider = StateProvider<bool>((ref) {
  return false; // false = light, true = dark
});

/// Provider pour la langue
final languageProvider = StateProvider<String>((ref) {
  return 'fr'; // Langue par défaut
});

/// Provider pour l'équipe favorite
final favoriteTeamProvider = StateProvider<String?>((ref) {
  return null;
});

/// Provider pour l'état de connexion
final isOnlineProvider = StateProvider<bool>((ref) {
  return true;
});
