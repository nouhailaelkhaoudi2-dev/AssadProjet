import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/flag_square.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Historique CAN')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HistoryCard(
            year: '2023',
            date: '11/02/24',
            winner: 'Côte d\'Ivoire',
            winnerCode: 'CI',
            winnerScore: 2,
            runnerUp: 'Nigeria',
            runnerUpCode: 'NG',
            runnerUpScore: 1,
          ),
          _HistoryCard(
            year: '2021',
            date: '06/02/22',
            winner: 'Sénégal',
            winnerCode: 'SN',
            winnerScore: 0,
            runnerUp: 'Égypte',
            runnerUpCode: 'EG',
            runnerUpScore: 0,
            penalties: '4-2',
          ),
          _HistoryCard(
            year: '2019',
            date: '19/07/19',
            winner: 'Algérie',
            winnerCode: 'DZ',
            winnerScore: 1,
            runnerUp: 'Sénégal',
            runnerUpCode: 'SN',
            runnerUpScore: 0,
          ),
          _HistoryCard(
            year: '2017',
            date: '05/02/17',
            winner: 'Cameroun',
            winnerCode: 'CM',
            winnerScore: 2,
            runnerUp: 'Égypte',
            runnerUpCode: 'EG',
            runnerUpScore: 1,
          ),
          _HistoryCard(
            year: '2015',
            date: '08/02/15',
            winner: 'Côte d\'Ivoire',
            winnerCode: 'CI',
            winnerScore: 0,
            runnerUp: 'Ghana',
            runnerUpCode: 'GH',
            runnerUpScore: 0,
            penalties: '9-8',
          ),
          _HistoryCard(
            year: '2013',
            date: '10/02/13',
            winner: 'Nigeria',
            winnerCode: 'NG',
            winnerScore: 1,
            runnerUp: 'Burkina Faso',
            runnerUpCode: 'BF',
            runnerUpScore: 0,
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
  final String date;
  final String winner;
  final String winnerCode;
  final int winnerScore;
  final String runnerUp;
  final String runnerUpCode;
  final int runnerUpScore;
  final String? penalties;

  const _HistoryCard({
    required this.year,
    required this.date,
    required this.winner,
    required this.winnerCode,
    required this.winnerScore,
    required this.runnerUp,
    required this.runnerUpCode,
    required this.runnerUpScore,
    this.penalties,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header: CAN · date | Terminé
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CAN · $date',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  'Terminé',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Score row: Flag Score - Score Flag
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Runner-up (left side)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: FlagSquare(
                            code: runnerUpCode,
                            emoji: '',
                            size: 48,
                            aspectRatio: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        runnerUp,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Score
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$runnerUpScore',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '-',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Text(
                        '$winnerScore',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Winner (right side)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: FlagSquare(
                            code: winnerCode,
                            emoji: '',
                            size: 48,
                            aspectRatio: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        winner,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Finale label
            Text(
              penalties != null ? 'Finale (tab $penalties)' : 'Finale',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
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
            'PALMARÈS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PalmaresItem(country: 'EG', name: 'Égypte', titles: '7'),
              _PalmaresItem(country: 'CM', name: 'Cameroun', titles: '5'),
              _PalmaresItem(country: 'GH', name: 'Ghana', titles: '4'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PalmaresItem(country: 'NG', name: 'Nigeria', titles: '3'),
              _PalmaresItem(country: 'CI', name: 'Côte d\'Ivoire', titles: '3'),
              _PalmaresItem(country: 'DZ', name: 'Algérie', titles: '2'),
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54, width: 2),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: FlagSquare(
              code: country,
              emoji: '',
              size: 44,
              aspectRatio: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$titles titres',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
