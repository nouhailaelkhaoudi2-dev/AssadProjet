import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/back_chevron_button.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  static const List<Map<String, dynamic>> _ticketCategories = [
    {
      'phase': 'Phase de groupes',
      'price': 'À partir de 550 MAD',
      'description': 'Accès aux 36 matchs de la phase de groupes',
      'icon': Icons.group,
      'color': Color(0xFF4CAF50),
    },
    {
      'phase': 'Huitièmes de finale',
      'price': 'À partir de 880 MAD',
      'description': 'Accès aux 8 matchs des huitièmes',
      'icon': Icons.looks_one,
      'color': Color(0xFF2196F3),
    },
    {
      'phase': 'Quarts de finale',
      'price': 'À partir de 1320 MAD',
      'description': 'Accès aux 4 matchs des quarts',
      'icon': Icons.looks_two,
      'color': Color(0xFF9C27B0),
    },
    {
      'phase': 'Demi-finales',
      'price': 'À partir de 2200 MAD',
      'description': 'Accès aux 2 demi-finales',
      'icon': Icons.looks_3,
      'color': Color(0xFFFF9800),
    },
    {
      'phase': 'Finale',
      'price': 'À partir de 3850 MAD',
      'description': 'La grande finale de la CAN 2025',
      'icon': Icons.emoji_events,
      'color': Color(0xFFC9A227),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar avec design
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            surfaceTintColor: Colors.transparent,
            leading: const BackChevronButton(),
            centerTitle: true,
            title: const Text(
              'Billetterie',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catégories De Billets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Liste des catégories
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = _ticketCategories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: _TicketCard(
                  phase: category['phase'],
                  price: category['price'],
                  description: category['description'],
                  icon: category['icon'],
                  color: category['color'],
                ),
              );
            }, childCount: _ticketCategories.length),
          ),

          // Bouton d'achat
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _openTicketing(),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text(
                        'Acheter sur le site officiel CAF',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Infos pratiques (compact + modern style)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(
                                  alpha: 0.06,
                                ),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.help_outline_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Informations pratiques',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          icon: Icons.credit_card,
                          text: 'Paiement sécurisé par carte bancaire',
                        ),
                        _InfoRow(
                          icon: Icons.qr_code,
                          text: 'Billets électroniques (e-tickets)',
                        ),
                        _InfoRow(
                          icon: Icons.person,
                          text: 'Billets nominatifs avec pièce d\'identité',
                        ),
                        _InfoRow(
                          icon: Icons.child_care,
                          text: 'Tarifs réduits pour les enfants (-12 ans)',
                        ),
                        _InfoRow(
                          icon: Icons.accessible,
                          text: 'Places PMR disponibles dans tous les stades',
                        ),
                      ],
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

  void _openTicketing() {
    launchUrl(
      Uri.parse(AppConstants.ticketingUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String phase;
  final String price;
  final String description;
  final IconData icon;
  final Color color;

  const _TicketCard({
    required this.phase,
    required this.price,
    required this.description,
    required this.icon,
    required this.color,
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
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              price,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
