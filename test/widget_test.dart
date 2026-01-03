import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikitaka/main.dart';

void main() {
  testWidgets('App should start without errors', (WidgetTester tester) async {
    // Build the app with ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: CANApp(),
      ),
    );

    // Verify the app starts
    await tester.pumpAndSettle();

    // Basic smoke test - app should render without crashing
    expect(find.byType(CANApp), findsOneWidget);
  });
}
