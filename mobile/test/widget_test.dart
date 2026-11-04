import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:event_hub/app.dart';

void main() {
  testWidgets('EventHub App smoke test - launches, renders splash, and transitions to Home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: EventHubApp(),
      ),
    );

    // Initial frame on splash screen - displays EventHub brand
    await tester.pump();
    expect(find.text('Event'), findsOneWidget);
    expect(find.text('Hub'), findsOneWidget);

    // Advance time past the splash delay (2s) to finish splash transition
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));

    // Verify navigation transitions to Home screen in Guest mode
    expect(find.text('Chào mừng bạn 👋'), findsOneWidget);
    expect(find.text('Danh mục dịch vụ'), findsOneWidget);
    expect(find.text('Dịch vụ thịnh hành'), findsOneWidget);
  });
}
