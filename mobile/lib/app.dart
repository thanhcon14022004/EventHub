import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_locale_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/background_color_provider.dart';
import 'core/theme/theme_provider.dart';

class EventHubApp extends ConsumerWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final bgColor = ref.watch(appBgColorProvider);
    final currentLanguage = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'EventHub',
      debugShowCheckedModeBanner: false,
      locale: currentLanguage.locale,
      theme: AppTheme.getLightTheme(bgColor),
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
