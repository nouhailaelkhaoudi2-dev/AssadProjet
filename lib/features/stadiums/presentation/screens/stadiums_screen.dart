import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StadiumsScreen extends StatelessWidget {
  const StadiumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Stades CAN 2025')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _StadiumCard(
            name: 'Stade Mohammed V',
            city: 'Casablanca',
            capacity: '45 000',
            matches: 'Finale, Demi-finales, Phase de groupes',
            imagePath: 'assets/images/stadecasa.jpg',
            description:
                'Le plus grand stade du Maroc, rénové pour la CAN 2025. Il accueillera la finale et les matchs les plus importants.',
          ),
          _StadiumCard(
            name: 'Stade Prince Moulay Abdellah',
            city: 'Rabat',
            capacity: '53 000',
            matches: 'Demi-finale, Quarts, Phase de groupes',
            imagePath: 'assets/images/stadium2.jpg',
            description:
                'Situé dans la capitale, ce stade moderne accueillera plusieurs matchs de la phase à élimination directe.',
          ),
          _StadiumCard(
            name: 'Grand Stade de Marrakech',
            city: 'Marrakech',
            capacity: '45 000',
            matches: 'Quarts de finale, Phase de groupes',
            imagePath: 'assets/images/stademarrakech.jpg',
            description:
                'Au cœur de la ville ocre, ce stade offre une atmosphère unique pour les matchs de la CAN.',
          ),
          _StadiumCard(
            name: 'Grand Stade de Tanger',
            city: 'Tanger',
            capacity: '45 000',
            matches: 'Huitièmes, Phase de groupes',
            imagePath: 'assets/images/stadetanger.jpg',
            description:
                'Stade Ibn Batouta, situé dans le nord du Maroc, avec vue sur le détroit de Gibraltar.',
          ),
          _StadiumCard(
            name: 'Stade de Fès',
            city: 'Fès',
            capacity: '35 000',
            matches: 'Phase de groupes',
            imagePath: 'assets/images/stadefes.jpg',
            description:
                'Dans la ville impériale de Fès, ce stade accueillera les matchs de la phase de groupes.',
          ),
          _StadiumCard(
            name: 'Stade d\'Agadir',
            city: 'Agadir',
            capacity: '45 000',
            matches: 'Phase de groupes',
            imagePath: 'assets/images/stadeagadir.jpg',
            description:
                'Stade Adrar, situé dans le sud du Maroc, près de l\'océan Atlantique.',
          ),
        ],
      ),
    );
  }
}

class _StadiumCard extends StatelessWidget {
  final String name;
  final String city;
  final String capacity;
  final String matches;
  final String? imagePath;
  final String description;

  const _StadiumCard({
    required this.name,
    required this.city,
    required this.capacity,
    required this.matches,
    this.imagePath,
    required this.description,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du stade
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: imagePath != null
                ? Image.asset(
                    imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),

          // Infos
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      city,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$capacity places',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    matches,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏟️', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            Text(
              city,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
