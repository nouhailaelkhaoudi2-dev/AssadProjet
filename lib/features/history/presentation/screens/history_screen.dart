import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique CAN'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HistoryCard(
            year: '2023',
            host: 'Côte d\'Ivoire',
            hostFlag: '🇨🇮',
            winner: 'Côte d\'Ivoire',
            winnerFlag: '🇨🇮',
            runnerUp: 'Nigeria',
            runnerUpFlag: '🇳🇬',
            finalScore: '2-1',
            topScorer: 'Emilio Nsue (5 buts)',
          ),
          _HistoryCard(
            year: '2021',
            host: 'Cameroun',
            hostFlag: '🇨🇲',
            winner: 'Sénégal',
            winnerFlag: '🇸🇳',
            runnerUp: 'Égypte',
            runnerUpFlag: '🇪🇬',
            finalScore: '0-0 (4-2 tab)',
            topScorer: 'Vincent Aboubakar (8 buts)',
          ),
          _HistoryCard(
            year: '2019',
            host: 'Égypte',
            hostFlag: '🇪🇬',
            winner: 'Algérie',
            winnerFlag: '🇩🇿',
            runnerUp: 'Sénégal',
            runnerUpFlag: '🇸🇳',
            finalScore: '1-0',
            topScorer: 'Sadio Mané (3 buts)',
          ),
          _HistoryCard(
            year: '2017',
            host: 'Gabon',
            hostFlag: '🇬🇦',
            winner: 'Cameroun',
            winnerFlag: '🇨🇲',
            runnerUp: 'Égypte',
            runnerUpFlag: '🇪🇬',
            finalScore: '2-1',
            topScorer: 'Junior Kabananga (3 buts)',
          ),
          _HistoryCard(
            year: '2015',
            host: 'Guinée Équatoriale',
            hostFlag: '🇬🇶',
            winner: 'Côte d\'Ivoire',
            winnerFlag: '🇨🇮',
            runnerUp: 'Ghana',
            runnerUpFlag: '🇬🇭',
            finalScore: '0-0 (9-8 tab)',
            topScorer: 'Thievy Bifouma (3 buts)',
          ),
          _HistoryCard(
            year: '2013',
            host: 'Afrique du Sud',
            hostFlag: '🇿🇦',
            winner: 'Nigeria',
            winnerFlag: '🇳🇬',
            runnerUp: 'Burkina Faso',
            runnerUpFlag: '🇧🇫',
            finalScore: '1-0',
            topScorer: 'Emmanuel Emenike (4 buts)',
          ),
          
          SizedBox(height: 20),
          
          _PalmaresSummary(),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String year;
  final String host;
  final String hostFlag;
  final String winner;
  final String winnerFlag;
  final String runnerUp;
  final String runnerUpFlag;
  final String finalScore;
  final String topScorer;

  const _HistoryCard({
    required this.year,
    required this.host,
    required this.hostFlag,
    required this.winner,
    required this.winnerFlag,
    required this.runnerUp,
    required this.runnerUpFlag,
    required this.finalScore,
    required this.topScorer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CAN $year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(hostFlag, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      host,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Finale
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  '🏆 FINALE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Winner
                    Column(
                      children: [
                        Text(winnerFlag, style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 4),
                        Text(
                          winner,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'CHAMPION',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Score
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          finalScore,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Runner-up
                    Column(
                      children: [
                        Text(runnerUpFlag, style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 4),
                        Text(
                          runnerUp,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'FINALISTE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_soccer, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Meilleur buteur: $topScorer',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PalmaresSummary extends StatelessWidget {
  const _PalmaresSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '🏆 PALMARÈS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PalmaresItem(country: '🇪🇬', name: 'Égypte', titles: '7'),
              _PalmaresItem(country: '🇨🇲', name: 'Cameroun', titles: '5'),
              _PalmaresItem(country: '🇬🇭', name: 'Ghana', titles: '4'),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PalmaresItem(country: '🇳🇬', name: 'Nigeria', titles: '3'),
              _PalmaresItem(country: '🇨🇮', name: 'Côte d\'Ivoire', titles: '3'),
              _PalmaresItem(country: '🇩🇿', name: 'Algérie', titles: '2'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PalmaresItem extends StatelessWidget {
  final String country;
  final String name;
  final String titles;

  const _PalmaresItem({
    required this.country,
    required this.name,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(country, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          '$titles titres',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

