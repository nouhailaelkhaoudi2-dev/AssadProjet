import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/services_providers.dart';

class SentimentScreen extends ConsumerStatefulWidget {
  const SentimentScreen({super.key});

  @override
  ConsumerState<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends ConsumerState<SentimentScreen> {
  @override
  void initState() {
    super.initState();
    // Lancer l'analyse automatiquement au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sentimentProvider.notifier).analyzeCanSentiment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentimentState = ref.watch(sentimentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sentiment CAN 2025'),
        actions: [
          // Bouton pour rafraîchir l'analyse
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: sentimentState.isLoading
                ? null
                : () => ref
                      .read(sentimentProvider.notifier)
                      .analyzeCanSentiment(),
          ),
        ],
      ),
      body: _buildBody(sentimentState),
    );
  }

  Widget _buildBody(SentimentState sentimentState) {
    if (sentimentState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 20),
            Text(
              'Analyse des actualités en cours...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Récupération des données depuis GNews\net analyse via Groq AI',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (sentimentState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.negative,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                sentimentState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(sentimentProvider.notifier).analyzeCanSentiment(),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (sentimentState.sentiment == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Analysez le sentiment autour de la CAN 2025',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(sentimentProvider.notifier).analyzeCanSentiment(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Lancer l\'analyse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Calcul des pourcentages basés sur le score
    final score = sentimentState.score ?? 0.5;
    final positivePercent = (score * 100).round();
    final negativePercent = ((1 - score) * 50).round();
    final neutralPercent = 100 - positivePercent - negativePercent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec source
          Container(
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
            child: const Text(
              'Analyse de sentiment CAN 2025',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 24),

          // Graphique Pie Chart
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          value: positivePercent.toDouble(),
                          color: AppColors.positive,
                          title: '$positivePercent%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: neutralPercent.toDouble(),
                          color: AppColors.neutral,
                          title: '$neutralPercent%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: negativePercent.toDouble(),
                          color: AppColors.negative,
                          title: '$negativePercent%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendItem(
                      color: AppColors.positive,
                      label: 'Positif',
                      value: '$positivePercent%',
                    ),
                    _LegendItem(
                      color: AppColors.neutral,
                      label: 'Neutre',
                      value: '$neutralPercent%',
                    ),
                    _LegendItem(
                      color: AppColors.negative,
                      label: 'Négatif',
                      value: '$negativePercent%',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Indicateur de tendance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _getGradientForSentiment(sentimentState.sentiment!),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForSentiment(sentimentState.sentiment!),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sentiment global',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSentimentLabel(sentimentState.sentiment!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(score * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Résumé de l'analyse
          if (sentimentState.summary != null)
            _buildSection(
              title: 'Résumé de l\'analyse',
              child: Text(
                sentimentState.summary!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Mots-clés extraits
          if (sentimentState.keywords != null &&
              sentimentState.keywords!.isNotEmpty)
            _buildSection(
              title: 'Mots-clés Extraits',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sentimentState.keywords!.map((keyword) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      keyword,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  LinearGradient _getGradientForSentiment(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positif':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        );
      case 'négatif':
        return const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFF616161)],
        );
    }
  }

  IconData _getIconForSentiment(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positif':
        return Icons.trending_up;
      case 'négatif':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  String _getSentimentLabel(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positif':
        return 'Très positif';
      case 'négatif':
        return 'Négatif';
      default:
        return 'Neutre';
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
