import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/navigation_provider.dart';
import 'home_screen.dart';
import '../../../chatbot/presentation/screens/chatbot_screen.dart';
import '../../../matches/presentation/screens/matches_screen.dart';
import '../../../news/presentation/screens/news_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> screens = const [
      HomeScreen(),
      ChatbotScreen(),
      MatchesScreen(),
      NewsScreen(),
      SettingsScreen(),
    ];

    final List<NavigationDestination> destinations = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Accueil',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: 'Assistant',
      ),
      NavigationDestination(
        icon: Icon(Icons.sports_soccer_outlined),
        selectedIcon: Icon(Icons.sports_soccer),
        label: 'Matchs',
      ),
      NavigationDestination(
        icon: Icon(Icons.newspaper_outlined),
        selectedIcon: Icon(Icons.newspaper),
        label: 'News',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: destinations,
      ),
    );
  }
}
