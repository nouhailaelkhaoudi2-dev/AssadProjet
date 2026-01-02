import 'package:flutter/material.dart';

class BuyTicketsPage extends StatelessWidget {
  const BuyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const deepRed = Color(0xFFD64045);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 40.0 : 20.0;
    
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
                    'Buy Tickets',
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
              child: ListView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Column(
              children: [
                Icon(Icons.confirmation_number, size: 60, color: deepRed),
                const SizedBox(height: 16),
                const Text(
                  'AFCON 2025 Tickets',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Book your tickets for the matches',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTicketCategory(
            'Group Stage',
            'From \$50',
            Icons.sports_soccer,
            deepRed,
          ),
          const SizedBox(height: 16),
          _buildTicketCategory(
            'Quarter Finals',
            'From \$120',
            Icons.emoji_events,
            deepRed,
          ),
          const SizedBox(height: 16),
          _buildTicketCategory(
            'Semi Finals',
            'From \$200',
            Icons.military_tech,
            deepRed,
          ),
          const SizedBox(height: 16),
          _buildTicketCategory(
            'Final',
            'From \$350',
            Icons.workspace_premium,
            deepRed,
          ),
        ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCategory(
    String title,
    String price,
    IconData icon,
    Color deepRed,
  ) {
    return Container(
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
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
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
  }
}
