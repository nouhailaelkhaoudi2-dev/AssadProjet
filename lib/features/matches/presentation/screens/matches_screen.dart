import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/back_chevron_button.dart';
import '../../../../core/widgets/flag_square.dart';
import '../../../../core/providers/services_providers.dart' hide ChatMessage;
import '../../domain/entities/match.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGroup = 'Tous';

  final List<String> _groups = ['Tous', 'A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Match> _filterByGroup(List<Match> matches) {
    if (_selectedGroup == 'Tous') return matches;
    return matches.where((m) => m.group == _selectedGroup).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer les données depuis les providers
    final upcomingAsync = ref.watch(upcomingMatchesProvider);
    final liveAsync = ref.watch(liveMatchesProvider);
    final resultsAsync = ref.watch(resultsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackChevronButton(),
        title: const Text('Matchs'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'En direct'),
            Tab(text: 'Terminés'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtres par groupe
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                final isSelected = _selectedGroup == group;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(group == 'Tous' ? 'Tous' : 'Groupe $group'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGroup = group;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Contenu des tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAsyncMatchList(upcomingAsync, 'Aucun match à venir'),
                _buildAsyncMatchList(liveAsync, 'Aucun match en cours'),
                _buildAsyncMatchList(resultsAsync, 'Aucun match terminé'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncMatchList(
    AsyncValue<List<Match>> asyncValue,
    String emptyMessage,
  ) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(upcomingMatchesProvider);
                ref.invalidate(liveMatchesProvider);
                ref.invalidate(resultsProvider);
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
      data: (matches) => _buildMatchList(_filterByGroup(matches), emptyMessage),
    );
  }

  Widget _buildMatchList(List<Match> matches, String emptyMessage) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return _MatchCard(match: matches[index]);
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Match match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Top line: Stadium · date, time
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stadium, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${match.stadium} · ${_topDateLabel(match.dateTime)}, ${_formatTime(match.dateTime)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Teams row with square flags and names, VS in middle
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlagSquare(
                      code: match.homeTeam.code,
                      imageUrl: match.homeTeam.flagUrl,
                      emoji: match.homeTeam.flagEmoji,
                      size: 44,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      match.homeTeam.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  match.status.isFinished ? match.scoreDisplay : 'vs',
                  style: TextStyle(
                    color: match.status.isFinished
                        ? AppColors.textPrimary
                        : Colors.grey[700],
                    fontSize: match.status.isFinished ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlagSquare(
                      code: match.awayTeam.code,
                      imageUrl: match.awayTeam.flagUrl,
                      emoji: match.awayTeam.flagEmoji,
                      size: 44,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      match.awayTeam.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Tournament phase centered under
          Text(
            _phaseLabel(match.phase),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _phaseLabel(TournamentPhase phase) {
    switch (phase) {
      case TournamentPhase.roundOf16:
        return 'Round of 16';
      case TournamentPhase.quarterFinal:
        return 'Quarter-finals';
      case TournamentPhase.semiFinal:
        return 'Semi-finals';
      case TournamentPhase.final_:
        return 'Final';
      case TournamentPhase.thirdPlace:
        return 'Third place';
      case TournamentPhase.groupStage:
        return match.group != null ? 'Group ${match.group}' : 'Group stage';
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _topDateLabel(DateTime dt) {
    final today = DateTime.now();
    final isSameDay =
        dt.year == today.year && dt.month == today.month && dt.day == today.day;
    if (isSameDay) return 'Aujourd\'hui';
    return _formatDate(dt);
  }
}
