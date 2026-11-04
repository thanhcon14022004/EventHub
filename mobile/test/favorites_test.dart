import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:event_hub/core/theme/app_theme.dart';
import 'package:event_hub/features/favorites/providers/favorites_provider.dart';
import 'package:event_hub/features/favorites/screens/favorites_screen.dart';
import 'package:event_hub/features/services/screens/service_detail_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('FavoritesNotifier & Provider Unit Tests', () {
    test('Initializes with default favorite services', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final favIds = container.read(favoritesProvider);
      expect(favIds.contains('s1'), isTrue);
      expect(favIds.contains('s2'), isTrue);
      expect(container.read(favoritesProvider.notifier).isFavorite('s1'), isTrue);
      expect(container.read(favoritesProvider.notifier).isFavorite('unknown-id'), isFalse);
    });

    test('toggleFavorite toggles membership and returns current status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);

      // Remove s1
      final status1 = notifier.toggleFavorite('s1');
      expect(status1, isFalse);
      expect(container.read(favoritesProvider).contains('s1'), isFalse);

      // Re-add s1
      final status2 = notifier.toggleFavorite('s1');
      expect(status2, isTrue);
      expect(container.read(favoritesProvider).contains('s1'), isTrue);
    });

    test('addFavorite, removeFavorite, clearAll work properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);

      notifier.addFavorite('s3');
      expect(container.read(favoritesProvider).contains('s3'), isTrue);

      notifier.removeFavorite('s3');
      expect(container.read(favoritesProvider).contains('s3'), isFalse);

      notifier.clearAll();
      expect(container.read(favoritesProvider).isEmpty, isTrue);
    });

    test('favoriteProductsProvider resolves products matching favorite IDs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final products = container.read(favoriteProductsProvider);
      expect(products.isNotEmpty, isTrue);
      expect(products.any((p) => p.id == 's1' || p.id == 'ps1'), isTrue);
    });
  });

  group('Favorites UI & Widget Tests', () {
    testWidgets('FavoritesScreen renders saved items, stats and controls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FavoritesScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify Screen Title and Top Banner
      expect(find.text('Dịch vụ yêu thích'), findsOneWidget);
      expect(find.textContaining('dịch vụ đã lưu'), findsOneWidget);

      // Verify initial cards
      expect(find.byType(ListView), findsWidgets);
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

      // Remove all items to test Empty State
      container.read(favoritesProvider.notifier).clearAll();
      await tester.pump();

      expect(find.text('Chưa có dịch vụ yêu thích'), findsOneWidget);
      expect(find.text('Khám phá dịch vụ ngay'), findsOneWidget);
    });

    testWidgets('ServiceDetailScreen heart button toggles favorite state', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 2800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially s1 is favorite
      expect(container.read(favoritesProvider).contains('s1'), isTrue);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ServiceDetailScreen(serviceId: 's1'),
          ),
        ),
      );
      await tester.pump();

      // Find the favorite icon in AppBar action (initially favorited -> filled heart)
      final favBtn = find.byIcon(Icons.favorite_rounded);
      expect(favBtn, findsOneWidget);

      // Tap to un-favorite
      await tester.tap(favBtn);
      await tester.pump();

      expect(container.read(favoritesProvider).contains('s1'), isFalse);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      // Tap again to re-favorite
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pump();

      expect(container.read(favoritesProvider).contains('s1'), isTrue);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });
  });
}
