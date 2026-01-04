import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/flag_square.dart';

class UpcomingMatchCard extends StatelessWidget {
  final String homeTeam;
  final String homeFlag; // emoji for fallback
  final String awayTeam;
  final String awayFlag; // emoji for fallback
  final String date;
  final String time;
  final String stadium;
  final String group;
  final String homeCode;
  final String awayCode;
  final String? homeFlagUrl;
  final String? awayFlagUrl;

  const UpcomingMatchCard({
    super.key,
    required this.homeTeam,
    required this.homeFlag,
    required this.awayTeam,
    required this.awayFlag,
    required this.date,
    required this.time,
    required this.stadium,
    required this.group,
    required this.homeCode,
    required this.awayCode,
    this.homeFlagUrl,
    this.awayFlagUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header centré: Nom du stade · date, heure
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stadium, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$stadium · $date, $time',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Équipes
          Row(
            children: [
              // Équipe domicile
              Expanded(
                child: Column(
                  children: [
                    FlagSquare(
                      code: homeCode,
                      emoji: homeFlag,
                      imageUrl: homeFlagUrl,
                      size: 44,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      homeTeam,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // VS et heure
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'vs',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Équipe extérieur
              Expanded(
                child: Column(
                  children: [
                    FlagSquare(
                      code: awayCode,
                      emoji: awayFlag,
                      imageUrl: awayFlagUrl,
                      size: 44,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      awayTeam,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Ligne d'information sous les équipes (phase ou groupe)
          Text(
            group.isNotEmpty ? 'Groupe $group' : 'Round of 16',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // flags via FlagSquare
}
