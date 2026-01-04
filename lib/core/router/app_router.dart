import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/main_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/matches/presentation/screens/matches_screen.dart';
import '../../features/matches/presentation/screens/match_detail_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/news/presentation/screens/news_detail_screen.dart';
import '../../features/chatbot/presentation/screens/chatbot_screen.dart';
import '../../features/avatar/presentation/screens/avatar_screen.dart';
import '../../features/sentiment/presentation/screens/sentiment_screen.dart';
import '../../features/fanzones/presentation/screens/fanzones_screen.dart';
import '../../features/tickets/presentation/screens/tickets_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/stadiums/presentation/screens/stadiums_screen.dart';
import '../../features/standings/presentation/screens/standings_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
// Removed unused direct profile screen import; profile route links to Settings.

/// Routes de l'application
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';

  // Main
  static const String home = '/';
  static const String matches = '/matches';
  static const String matchDetail = '/matches/:id';
  static const String news = '/news';
  static const String newsDetail = '/news/:id';
  static const String chatbot = '/chatbot';
  static const String avatar = '/avatar';
  static const String sentiment = '/sentiment';
  static const String fanzones = '/fanzones';
  static const String tickets = '/tickets';
  static const String settings = '/settings';
  static const String stadiums = '/stadiums';
  static const String standings = '/standings';
  static const String history = '/history';
  static const String profile = '/profile';
}

/// Configuration du router
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app avec navigation bar
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),

      // Matches
      GoRoute(
        path: AppRoutes.matches,
        name: 'matches',
        builder: (context, state) => const MatchesScreen(),
      ),
      GoRoute(
        path: AppRoutes.matchDetail,
        name: 'matchDetail',
        builder: (context, state) {
          final matchId = state.pathParameters['id'] ?? '';
          return MatchDetailScreen(matchId: matchId);
        },
      ),

      // News
      GoRoute(
        path: AppRoutes.news,
        name: 'news',
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.newsDetail,
        name: 'newsDetail',
        builder: (context, state) {
          final articleId = state.pathParameters['id'] ?? '';
          return NewsDetailScreen(articleId: articleId);
        },
      ),

      // Chatbot & Avatar
      GoRoute(
        path: AppRoutes.chatbot,
        name: 'chatbot',
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: AppRoutes.avatar,
        name: 'avatar',
        builder: (context, state) => const AvatarScreen(),
      ),

      // Other features
      GoRoute(
        path: AppRoutes.sentiment,
        name: 'sentiment',
        builder: (context, state) => const SentimentScreen(),
      ),
      GoRoute(
        path: AppRoutes.fanzones,
        name: 'fanzones',
        builder: (context, state) => const FanzonesScreen(),
      ),
      GoRoute(
        path: AppRoutes.tickets,
        name: 'tickets',
        builder: (context, state) => const TicketsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.stadiums,
        name: 'stadiums',
        builder: (context, state) => const StadiumsScreen(),
      ),
      GoRoute(
        path: AppRoutes.standings,
        name: 'standings',
        builder: (context, state) => const StandingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      // Profile
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // Gestion des erreurs de navigation
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('${state.uri}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),

    // Redirection basée sur l'auth (à implémenter)
    redirect: (context, state) {
      // NOTE: La logique de redirection basée sur l'authentification sera implémentée ultérieurement
      // final isLoggedIn = authProvider.isLoggedIn;
      // final isAuthRoute = state.matchedLocation == AppRoutes.login ||
      //     state.matchedLocation == AppRoutes.register ||
      //     state.matchedLocation == AppRoutes.welcome;

      // if (!isLoggedIn && !isAuthRoute) {
      //   return AppRoutes.welcome;
      // }
      // if (isLoggedIn && isAuthRoute) {
      //   return AppRoutes.home;
      // }

      return null;
    },
  );
}

/// Extension pour faciliter la navigation
extension GoRouterExtension on BuildContext {
  void goToMatch(String matchId) => go('/matches/$matchId');
  void goToNews(String articleId) => go('/news/$articleId');
  void goToHome() => go(AppRoutes.home);
  void goToChatbot() => go(AppRoutes.chatbot);
  void goToAvatar() => go(AppRoutes.avatar);
}

/// Provider Riverpod pour le router
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});
