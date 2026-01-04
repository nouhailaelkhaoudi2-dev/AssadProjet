import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/navigation_provider.dart';
import '../router/app_router.dart';

class BackChevronButton extends ConsumerWidget {
  final Color? color;

  const BackChevronButton({super.key, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.chevron_left, color: color),
      splashRadius: 24,
      onPressed: () {
        // Ensure the Home tab is selected in MainScreen
        ref.read(bottomNavIndexProvider.notifier).state = 0;
        // Navigate to the home route
        context.go(AppRoutes.home);
      },
      // No background; color comes from AppBar foregroundColor or Theme
    );
  }
}
