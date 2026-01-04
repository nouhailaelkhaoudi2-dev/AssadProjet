import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_chevron_button.dart';
import '../../data/models/fanzone.dart';

class FanzonesScreen extends StatelessWidget {
  const FanzonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackChevronButton(),
        title: const Text('Fanzones'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AfconFanZones.fanzones.length,
        itemBuilder: (context, index) {
          return _FanzoneCard(fanzone: AfconFanZones.fanzones[index]);
        },
      ),
    );
  }
}

class _FanzoneCard extends StatelessWidget {
  final FanZone fanzone;

  const _FanzoneCard({required this.fanzone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              // Use image background for Casablanca, Rabat, Marrakech, Tanger, Fès and Agadir; gradient for others
              image:
                  (fanzone.city.toLowerCase() == 'casablanca' ||
                      fanzone.city.toLowerCase() == 'rabat' ||
                      fanzone.city.toLowerCase() == 'marrakech' ||
                      fanzone.city.toLowerCase() == 'tanger' ||
                      fanzone.city.toLowerCase() == 'fès' ||
                      fanzone.city.toLowerCase() == 'fes' ||
                      fanzone.city.toLowerCase() == 'agadir')
                  ? DecorationImage(
                      image: AssetImage(
                        fanzone.city.toLowerCase() == 'casablanca'
                            ? 'assets/images/fanzonecasa.jpg'
                            : (fanzone.city.toLowerCase() == 'rabat'
                                  ? 'assets/images/fanzonerabat.jpg'
                                  : (fanzone.city.toLowerCase() == 'marrakech'
                                        ? 'assets/images/fanzonemarrakech.jpg'
                                        : (fanzone.city.toLowerCase() ==
                                                  'tanger'
                                              ? 'assets/images/fanzonetanger.jpg'
                                              : (fanzone.city.toLowerCase() ==
                                                        'agadir'
                                                    ? 'assets/images/fanzoneagadir.jpg'
                                                    : 'assets/images/fanzonefes.jpg')))),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient:
                  (fanzone.city.toLowerCase() == 'casablanca' ||
                      fanzone.city.toLowerCase() == 'rabat' ||
                      fanzone.city.toLowerCase() == 'marrakech' ||
                      fanzone.city.toLowerCase() == 'tanger' ||
                      fanzone.city.toLowerCase() == 'fès' ||
                      fanzone.city.toLowerCase() == 'fes' ||
                      fanzone.city.toLowerCase() == 'agadir')
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Pattern décoratif
                if (!(fanzone.city.toLowerCase() == 'casablanca' ||
                    fanzone.city.toLowerCase() == 'rabat' ||
                    fanzone.city.toLowerCase() == 'marrakech' ||
                    fanzone.city.toLowerCase() == 'tanger' ||
                    fanzone.city.toLowerCase() == 'fès' ||
                    fanzone.city.toLowerCase() == 'fes' ||
                    fanzone.city.toLowerCase() == 'agadir')) ...[
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],

                // Contenu
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Small image removed to keep only text on header
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fanzone.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fanzone.city,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Détails
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fanzone.description != null) ...[
                  Text(
                    fanzone.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Infos
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.people,
                      label: fanzone.capacity ?? 'N/A',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.access_time,
                      label: fanzone.openingHours ?? 'N/A',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Équipements
                if (fanzone.amenities.isNotEmpty) ...[
                  const Text(
                    'Équipements',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: fanzone.amenities.map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          amenity,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Adresse et bouton Maps
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adresse',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fanzone.address,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openMaps(fanzone),
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Maps'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
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

  void _openMaps(FanZone fanzone) {
    launchUrl(
      Uri.parse(fanzone.googleMapsUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
