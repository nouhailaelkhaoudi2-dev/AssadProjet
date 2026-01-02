import 'package:flutter/material.dart';

class AFCONHistoryPage extends StatelessWidget {
  const AFCONHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const deepRed = Color(0xFFD64045);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 40.0 : 20.0;
    
    final winners = [
      {'year': '2024', 'country': 'Ivory Coast', 'flag': '🇨🇮', 'host': 'Ivory Coast'},
      {'year': '2022', 'country': 'Senegal', 'flag': '🇸🇳', 'host': 'Cameroon'},
      {'year': '2019', 'country': 'Algeria', 'flag': '🇩🇿', 'host': 'Egypt'},
      {'year': '2017', 'country': 'Cameroon', 'flag': '🇨🇲', 'host': 'Gabon'},
      {'year': '2015', 'country': 'Ivory Coast', 'flag': '🇨🇮', 'host': 'Equatorial Guinea'},
      {'year': '2013', 'country': 'Nigeria', 'flag': '🇳🇬', 'host': 'South Africa'},
      {'year': '2012', 'country': 'Zambia', 'flag': '🇿🇲', 'host': 'Gabon/Equatorial Guinea'},
    ];
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF1A1F25),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'AFCON History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        itemCount: winners.length,
        itemBuilder: (context, index) {
          final winner = winners[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F25),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [deepRed, deepRed.withValues(alpha: 0.6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      winner['year']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            winner['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              winner['country']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Host: ${winner['host']!}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ],
            ),
          );
        },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
