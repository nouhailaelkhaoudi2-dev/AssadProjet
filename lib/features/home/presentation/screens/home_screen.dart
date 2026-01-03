import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/services_providers.dart';
import '../../../../core/providers/favorite_team_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_access_card.dart';
import '../widgets/upcoming_match_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingMatchesAsync = ref.watch(prioritizedMatchesProvider);
    final favoriteTeam = ref.watch(favoriteTeamProvider);
    final favoriteTeamPlaysToday = ref.watch(favoriteTeamPlaysTodayProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'CAN 2025',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 60,
                      child: Text(
                        favoriteTeam?.flagEmoji ?? '🇲🇦',
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message de bienvenue
                  Text(
                    favoriteTeam != null 
                        ? 'Bienvenue, supporter ${favoriteTeam.name} ! ${favoriteTeam.flagEmoji}'
                        : 'Bienvenue ! 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Découvrez tout sur la CAN 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Alerte match équipe favorite
                  favoriteTeamPlaysToday.when(
                    data: (match) {
                      if (match == null || favoriteTeam == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.9),
                              AppColors.secondary.withValues(alpha: 0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                favoriteTeam.flagEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🔥 Votre équipe joue aujourd\'hui !',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${match.homeTeam.name} vs ${match.awayTeam.name}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatTime(match.dateTime),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Statistiques rapides
                  const Text(
                    'Aperçu du tournoi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          icon: Icons.sports_soccer,
                          value: '24',
                          label: 'Équipes',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          icon: Icons.stadium,
                          value: '6',
                          label: 'Stades',
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          icon: Icons.calendar_today,
                          value: '52',
                          label: 'Matchs',
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Accès rapide
                  const Text(
                    'Accès rapide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      QuickAccessCard(
                        icon: Icons.chat_bubble,
                        label: 'Chatbot',
                        color: AppColors.primary,
                        onTap: () => context.go(AppRoutes.chatbot),
                      ),
                      QuickAccessCard(
                        icon: Icons.record_voice_over,
                        label: 'Avatar',
                        color: AppColors.secondary,
                        onTap: () => context.push(AppRoutes.avatar),
                      ),
                      QuickAccessCard(
                        icon: Icons.emoji_emotions,
                        label: 'Sentiment',
                        color: AppColors.accent,
                        onTap: () => context.push(AppRoutes.sentiment),
                      ),
                      QuickAccessCard(
                        icon: Icons.confirmation_number,
                        label: 'Billets',
                        color: AppColors.error,
                        onTap: () => context.push(AppRoutes.tickets),
                      ),
                      QuickAccessCard(
                        icon: Icons.stadium,
                        label: 'Stades',
                        color: Colors.purple,
                        onTap: () => context.push(AppRoutes.stadiums),
                      ),
                      QuickAccessCard(
                        icon: Icons.celebration,
                        label: 'Fanzones',
                        color: Colors.orange,
                        onTap: () => context.push(AppRoutes.fanzones),
                      ),
                      QuickAccessCard(
                        icon: Icons.leaderboard,
                        label: 'Classement',
                        color: Colors.teal,
                        onTap: () => context.push(AppRoutes.standings),
                      ),
                      QuickAccessCard(
                        icon: Icons.history,
                        label: 'Historique',
                        color: Colors.brown,
                        onTap: () => context.push(AppRoutes.history),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Prochains matchs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prochains matchs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.matches),
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Liste des matchs depuis l'API
                  upcomingMatchesAsync.when(
                    data: (matches) {
                      if (matches.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Aucun match à venir pour le moment',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        );
                      }
                      
                      // Afficher les 3 premiers matchs
                      return Column(
                        children: matches.take(3).map((match) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: UpcomingMatchCard(
                              homeTeam: match.homeTeam.name,
                              homeFlag: match.homeTeam.flagEmoji,
                              awayTeam: match.awayTeam.name,
                              awayFlag: match.awayTeam.flagEmoji,
                              date: _formatDate(match.dateTime),
                              time: _formatTime(match.dateTime),
                              stadium: match.stadium ?? 'Stade à confirmer',
                              group: match.group ?? '',
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Impossible de charger les matchs',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
