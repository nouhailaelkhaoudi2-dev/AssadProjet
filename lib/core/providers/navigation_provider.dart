import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the selected index of the bottom navigation bar.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
