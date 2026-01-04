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

/// Custom clipper for concave curve at bottom of header
class _ConcaveCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

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
          SliverToBoxAdapter(
            child: ClipPath(
              clipper: _ConcaveCurveClipper(),
              child: Container(height: 130, color: AppColors.primary),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favoriteTeam != null
                        ? 'Bienvenue, supporter ${favoriteTeam.name} ! ${favoriteTeam.flagEmoji}'
                        : 'Bienvenue ',
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
                  _buildFavoriteTeamAlert(favoriteTeamPlaysToday, favoriteTeam),
                  const Text(
                    'Aperçu De La Compétition',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  const Text(
                    'Nos Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickAccessHorizontalList(context),
                  const SizedBox(height: 24),
                  _buildMatchesHeader(context),
                  const SizedBox(height: 12),
                  _buildMatchesList(upcomingMatchesAsync),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteTeamAlert(
    AsyncValue<dynamic> favoriteTeamPlaysToday,
    dynamic favoriteTeam,
  ) {
    return favoriteTeamPlaysToday.when(
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
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            value: '24',
            label: 'Équipes',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            value: '6',
            label: 'Stades',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            value: '52',
            label: 'Matchs',
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessHorizontalList(BuildContext context) {
    final itemsCount = 8;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: itemsCount,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (ctx, index) {
          switch (index) {
            case 0:
              return SizedBox(
                width: 84,
                child: QuickAccessCard(
                  asset: 'assets/images/AI_Agent.png',
                  label: 'Assistant IA',
                  color: AppColors.primary,
                  onTap: () => context.go(AppRoutes.chatbot),
                ),
              );
            case 1:
              return SizedBox(
                width: 84,
                child: QuickAccessCard(
                  asset: 'assets/images/Capture d\'écran 2025-12-22 221422.png',
                  label: 'Avatar',
                  color: AppColors.secondary,
                  onTap: () => context.push(AppRoutes.avatar),
                ),
              );
            case 2:
              return SizedBox(
                width: 84,
                child: QuickAccessCard(
                  asset: 'assets/images/fans.jpg',
                  label: 'Sentiments',
                  color: AppColors.accent,
                  onTap: () => context.push(AppRoutes.sentiment),
                ),
              );
            case 3:
              return SizedBox(
                width: 84,
                child: QuickAccessCard(
                  // Use image asset instead of icon for Billets
                  asset: 'assets/images/ticket.jpg',
                  label: 'Billets',
                  color: AppColors.error,
                  onTap: () => context.push(AppRoutes.tickets),
                ),
              );
            case 4:
              return SizedBox(
                width: 84,
                child: QuickAccessCard(
                  asset: 'assets/images/stadium.jpg',
                  label: 'Stades',
                  color: Colors.purple,
                  onTap: () => context.push(AppRoutes.stadiums),
                ),
              );
            case 5:
              return SizedBox(
                width: 84,
                child: QuickAccessCard(
                  asset: 'assets/images/fanzone.jpg',
                  label: 'Fanzones',
                  color: Colors.orange,
                  onTap: () => context.push(AppRoutes.fanzones),
                ),
              );
            case 6:
              return SizedBox(
                width: 84,
                child: QuickAccessCard(
                  asset: 'assets/images/groups.jpg',
                  label: 'Classement',
                  color: Colors.teal,
                  onTap: () => context.push(AppRoutes.standings),
                ),
              );
            case 7:
              return SizedBox(
                width: 84,
                child: QuickAccessCard(
                  asset: 'assets/images/history.jpg',
                  label: 'Historique',
                  color: Colors.brown,
                  onTap: () => context.push(AppRoutes.history),
                ),
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildMatchesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Prochains Matchs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () => context.push(AppRoutes.matches),
          child: const Text('Voir Tout'),
        ),
      ],
    );
  }

  Widget _buildMatchesList(AsyncValue<dynamic> upcomingMatchesAsync) {
    return upcomingMatchesAsync.when(
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

        return Column(
          children: matches.take(3).map<Widget>((match) {
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
                homeCode: match.homeTeam.code,
                awayCode: match.awayTeam.code,
                homeFlagUrl: match.homeTeam.flagUrl,
                awayFlagUrl: match.awayTeam.flagUrl,
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
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
