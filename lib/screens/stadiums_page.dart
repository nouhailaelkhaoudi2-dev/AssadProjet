import 'package:flutter/material.dart';

class StadiumsPage extends StatelessWidget {
  const StadiumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const deepRed = Color(0xFFD64045);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 40.0 : 20.0;
    
    final stadiums = [
      {'name': 'Stade Mohammed V', 'city': 'Casablanca', 'capacity': '67,000', 'country': '🇲🇦'},
      {'name': 'Stade d\'Olembe', 'city': 'Yaoundé', 'capacity': '60,000', 'country': '🇨🇲'},
      {'name': 'Stade Félix Houphouët', 'city': 'Abidjan', 'capacity': '35,000', 'country': '🇨🇮'},
      {'name': 'Stade du 5 Juillet', 'city': 'Algiers', 'capacity': '64,000', 'country': '🇩🇿'},
      {'name': 'Stade Diamniadio', 'city': 'Dakar', 'capacity': '50,000', 'country': '🇸🇳'},
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
                    'Stadiums',
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
        itemCount: stadiums.length,
        itemBuilder: (context, index) {
          final stadium = stadiums[index];
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
                  child: const Icon(Icons.stadium, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stadium['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            stadium['country']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stadium['city']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stadium['capacity']} seats',
                        style: TextStyle(
                          fontSize: 13,
                          color: deepRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 18),
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
