import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_hub/app.dart';

void main() {
  testWidgets('EventHub App smoke test - launches, renders splash, and transitions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EventHubApp(),
      ),
    );

    // Initial frame on splash screen
    await tester.pump();
    expect(find.text('EventHub'), findsOneWidget);

    // Advance time past the splash delay (1.8s) to finish all pending timers
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify navigation transitions to Home screen in Guest mode
    expect(find.text('Chào mừng đến EventHub 👋'), findsOneWidget);
  });
}
