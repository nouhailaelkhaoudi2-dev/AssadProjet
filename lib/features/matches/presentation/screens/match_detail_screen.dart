import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_chevron_button.dart';
import '../../../../core/widgets/flag_square.dart';
import '../../domain/entities/match.dart';
import '../../domain/entities/team.dart';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    // Données de démonstration
    final match = Match(
      id: matchId,
      homeTeam: AfconTeams.teams.firstWhere((t) => t.code == 'MA'),
      awayTeam: AfconTeams.teams.firstWhere((t) => t.code == 'ML'),
      dateTime: DateTime(2025, 1, 15, 20, 0),
      stadium: 'Stade Mohammed V',
      city: 'Casablanca',
      status: MatchStatus.scheduled,
      phase: TournamentPhase.groupStage,
      group: 'A',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar avec gradient
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: const BackChevronButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Phase et groupe
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${match.phase.label} - Groupe ${match.group}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Équipes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Équipe domicile
                          Expanded(
                            child: Column(
                              children: [
                                FlagSquare(
                                  code: match.homeTeam.code,
                                  imageUrl: match.homeTeam.flagUrl,
                                  emoji: match.homeTeam.flagEmoji,
                                  size: 44,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  match.homeTeam.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          // Score ou VS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              match.status == MatchStatus.scheduled
                                  ? 'VS'
                                  : '${match.homeScore} - ${match.awayScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Équipe extérieure
                          Expanded(
                            child: Column(
                              children: [
                                FlagSquare(
                                  code: match.awayTeam.code,
                                  imageUrl: match.awayTeam.flagUrl,
                                  emoji: match.awayTeam.flagEmoji,
                                  size: 44,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  match.awayTeam.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Infos du match
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date et heure',
                    value: _formatDateTime(match.dateTime),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.stadium,
                    title: 'Stade',
                    value: match.stadium,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Ville',
                    value: match.city,
                  ),

                  const SizedBox(height: 24),

                  // Statistiques (données fictives)
                  const Text(
                    'Statistiques',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Possession', 55, 45),
                  _buildStatRow('Tirs', 12, 8),
                  _buildStatRow('Tirs cadrés', 5, 3),
                  _buildStatRow('Corners', 6, 4),
                  _buildStatRow('Fautes', 10, 12),

                  const SizedBox(height: 24),

                  // Bouton acheter billets
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigation vers billetterie
                      },
                      icon: const Icon(Icons.confirmation_number),
                      label: const Text(
                        'Acheter des billets',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int home, int away) {
    final total = home + away;
    final homePercent = total > 0 ? home / total : 0.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$home',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '$away',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: (homePercent * 100).round(),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: ((1 - homePercent) * 100).round(),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
