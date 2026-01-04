import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_chevron_button.dart';

class NewsDetailScreen extends StatelessWidget {
  final String articleId;

  const NewsDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    // Données de démonstration
    final article = _demoArticle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Image en header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: const BackChevronButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.newspaper,
                        size: 80,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Titre
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      article['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
                  // Métadonnées
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article['source']!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article['date']!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Contenu de l'article
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['description']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          article['content']!,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bouton lire l'article original
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _openOriginalArticle(article['url']!),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Lire l\'article original'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton partager
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité de partage à venir'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Partager'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Articles similaires
                  const Text(
                    'Articles similaires',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ..._similarArticles.map(
                    (similar) => _buildSimilarArticleCard(
                      context,
                      title: similar['title']!,
                      source: similar['source']!,
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

  Widget _buildSimilarArticleCard(
    BuildContext context, {
    required String title,
    required String source,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.article, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  void _openOriginalArticle(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Map<String, String> get _demoArticle => {
    'title': 'Le Maroc fin prêt pour accueillir la CAN 2025',
    'description':
        'Le pays hôte a finalisé tous les préparatifs pour accueillir la plus grande compétition de football africain.',
    'content':
        '''Le Maroc se prépare à accueillir la Coupe d'Afrique des Nations 2025, un événement qui marquera un tournant dans l'histoire du football africain. Les six stades sélectionnés pour le tournoi ont été rénovés et mis aux normes internationales.

Le Stade Mohammed V de Casablanca, qui accueillera la finale, a bénéficié d'une rénovation complète avec une capacité portée à 67 000 places. Les infrastructures de transport ont également été améliorées avec l'extension du réseau de tramway et la mise en service de nouvelles lignes de bus.

Les autorités marocaines ont également travaillé sur l'hébergement des supporters, avec plus de 100 000 chambres d'hôtel disponibles dans les villes hôtes. Des fanzones seront installées dans chaque ville pour permettre aux supporters de vivre l'événement même sans billet.

La sécurité sera assurée par un dispositif exceptionnel, avec la mobilisation de forces de l'ordre et l'installation de systèmes de vidéosurveillance de dernière génération.

Le tournoi débutera le 21 décembre 2025 avec le match d'ouverture entre le Maroc et une équipe du groupe A, et se terminera le 18 janvier 2026 avec la grande finale à Casablanca.''',
    'source': 'CAF Official',
    'date': 'Il y a 2 heures',
    'url': 'https://www.cafonline.com',
  };

  List<Map<String, String>> get _similarArticles => [
    {
      'title': 'Les Lions de l\'Atlas dévoilent leur liste de 26 joueurs',
      'source': 'Sport24',
    },
    {
      'title': 'Billetterie CAN 2025 : tout ce qu\'il faut savoir',
      'source': 'Foot Maroc',
    },
    {
      'title': 'Les favoris du tournoi selon les experts',
      'source': 'Africa Football',
    },
  ];
}
