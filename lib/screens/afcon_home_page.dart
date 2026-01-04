import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

class AFCONHomePage extends StatefulWidget {
  const AFCONHomePage({super.key});

  @override
  State<AFCONHomePage> createState() => _AFCONHomePageState();
}

class _AFCONHomePageState extends State<AFCONHomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;

  final List<Widget> _pages = [
    const HomePageContent(),
    const AIChatPage(),
    const LionPage(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 0, primaryColor),
            _buildNavItem(Icons.bookmark_outline, 1, primaryColor),
            _buildNavItem(Icons.settings_outlined, 2, primaryColor),
            _buildNavItem(Icons.person_outline, 3, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, Color primaryColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _fabAnimationController.reset();
          _fabAnimationController.forward();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
          size: 26,
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final quickAccess = [
      {
        'name': 'Chatbot',
        'icon': Icons.chat_bubble_outline,
        'color': const Color(0xFFE74C3C),
        'route': '/chatbot',
      },
      {
        'name': 'Avatar',
        'icon': Icons.person_outline,
        'color': const Color(0xFF9B59B6),
        'route': '/avatar',
      },
      {
        'name': 'Sentiment',
        'icon': Icons.emoji_emotions_outlined,
        'color': const Color(0xFFF39C12),
        'route': '/sentiment',
      },
      {
        'name': 'Billets',
        // Custom image for tickets quick access
        'asset': 'assets/images/ticket.jpg',
        'color': const Color(0xFF3498DB),
        'route': '/tickets',
      },
      {
        'name': 'Stades',
        'icon': Icons.stadium_outlined,
        // Use a custom image for the stadiums quick access
        'asset': 'assets/images/stadium_access.png',
        'color': const Color(0xFF1ABC9C),
        'route': '/stadiums',
      },
      {
        'name': 'Fanzones',
        'icon': Icons.groups_outlined,
        'color': const Color(0xFFE67E22),
        'route': '/fanzones',
      },
      {
        'name': 'Classement',
        'icon': Icons.emoji_events_outlined,
        'color': const Color(0xFFEAB308),
        'route': '/standings',
      },
      {
        'name': 'Historique',
        'icon': Icons.history_outlined,
        'color': const Color(0xFF8B5CF6),
        'route': '/history',
      },
    ];

    final matchCards = [
      {'title': 'Morocco vs Egypt', 'subtitle': 'Stade Mohammed V • 20:00'},
      {'title': 'Senegal vs Nigeria', 'subtitle': 'Stade de Olembe • 18:00'},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push(AppRoutes.settings),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      const Text(
                        'Casablanca, MA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F25),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: Colors.grey[800],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Accès rapide Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F25),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Categories List (Accès rapide)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: quickAccess.length,
                  itemBuilder: (context, index) {
                    final item = quickAccess[index];
                    return GestureDetector(
                      onTap: () {
                        try {
                          Navigator.pushNamed(context, item['route'] as String);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${item['name']} - Bientôt disponible',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: item['color'] as Color,
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: (item['color'] as Color).withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (item['color'] as Color).withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child:
                                  (item.containsKey('asset') &&
                                      item['asset'] != null)
                                  ? ClipOval(
                                      child: Image.asset(
                                        item['asset'] as String,
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) {
                                          // If image fails and no icon is provided, render nothing
                                          final dynIcon = item['icon'];
                                          if (dynIcon is IconData) {
                                            return Icon(
                                              dynIcon,
                                              color: item['color'] as Color,
                                              size: 30,
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    )
                                  : (() {
                                      final dynIcon = item['icon'];
                                      if (dynIcon is IconData) {
                                        return Icon(
                                          dynIcon,
                                          color: item['color'] as Color,
                                          size: 30,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    })(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1F25),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Match Cards
              ...matchCards.map(
                (match) => Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            colors: [Colors.red[700]!, Colors.green[700]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.sports_soccer,
                                size: 80,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.bookmark_outline,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    match['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1F25),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          match['subtitle'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A1F25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder pages
class AIChatPage extends StatelessWidget {
  const AIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('AI Chat', style: TextStyle(fontSize: 24)));
  }
}

class LionPage extends StatelessWidget {
  const LionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Lion Page', style: TextStyle(fontSize: 24)),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile', style: TextStyle(fontSize: 24)));
  }
}

// Removed unused ProfilePage placeholder; SettingsScreen is used for the tab.
