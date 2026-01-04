import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/services_providers.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(standingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: standingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Erreur de chargement'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(standingsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (standings) {
          if (standings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Classement non disponible',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les classements seront affichés\ndès le début de la compétition',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: standings.length,
            itemBuilder: (context, index) {
              final groupName = standings.keys.elementAt(index);
              final teams = standings[groupName]!;
              return _GroupCard(groupName: groupName, teams: teams);
            },
          );
        },
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String groupName;
  final List<Map<String, dynamic>> teams;

  const _GroupCard({required this.groupName, required this.teams});

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
          // Header du groupe
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // En-tête du tableau
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: const Row(
              children: [
                SizedBox(width: 30, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Équipe', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 30, child: Text('J', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 30, child: Text('G', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 30, child: Text('N', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 30, child: Text('P', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 40, child: Text('Pts', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          
          // Équipes
          ...teams.asMap().entries.map((entry) {
            final index = entry.key;
            final team = entry.value;
            final isQualified = index < 2;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isQualified ? AppColors.secondary.withValues(alpha: 0.05) : null,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isQualified ? AppColors.secondary : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${team['rank'] ?? index + 1}',
                          style: TextStyle(
                            color: isQualified ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      team['team'] ?? 'Équipe',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: 30, child: Text('${team['played'] ?? 0}', textAlign: TextAlign.center)),
                  SizedBox(width: 30, child: Text('${team['won'] ?? 0}', textAlign: TextAlign.center)),
                  SizedBox(width: 30, child: Text('${team['draw'] ?? 0}', textAlign: TextAlign.center)),
                  SizedBox(width: 30, child: Text('${team['lost'] ?? 0}', textAlign: TextAlign.center)),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${team['points'] ?? 0}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}




