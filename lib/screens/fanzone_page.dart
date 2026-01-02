import 'package:flutter/material.dart';

class FanzonePage extends StatelessWidget {
  const FanzonePage({super.key});

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
                    'Fanzone',
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
                Icon(Icons.sports_soccer, size: 60, color: deepRed),
                const SizedBox(height: 16),
                const Text(
                  'Connect with Fans',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share your passion for African football',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            'Live Chats',
            'Join live discussions during matches',
            Icons.chat_bubble,
            deepRed,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Fan Photos',
            'Share your best AFCON moments',
            Icons.photo_camera,
            deepRed,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Predictions',
            'Predict match results and win prizes',
            Icons.lightbulb,
            deepRed,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            'Fan Rankings',
            'Compete with fans worldwide',
            Icons.leaderboard,
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

  Widget _buildFeatureCard(
    String title,
    String description,
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
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
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
