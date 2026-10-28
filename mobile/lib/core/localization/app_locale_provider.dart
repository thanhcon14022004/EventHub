import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';

enum AppLanguage {
  vi,
  en,
}

extension AppLanguageExt on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.vi:
        return 'Tiếng Việt';
      case AppLanguage.en:
        return 'English';
    }
  }

  String get flagEmoji {
    switch (this) {
      case AppLanguage.vi:
        return '🇻🇳';
      case AppLanguage.en:
        return '🇬🇧';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.vi:
        return const Locale('vi', 'VN');
      case AppLanguage.en:
        return const Locale('en', 'US');
    }
  }
}

class AppLocaleNotifier extends StateNotifier<AppLanguage> {
  static const String _prefKey = 'app_language_setting';

  AppLocaleNotifier() : super(AppLanguage.vi) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'en') {
        state = AppLanguage.en;
      } else {
        state = AppLanguage.vi;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language == AppLanguage.en ? 'en' : 'vi');
    } catch (_) {}
  }

  bool get isEnglish => state == AppLanguage.en;
  bool get isVietnamese => state == AppLanguage.vi;
}

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, AppLanguage>((ref) {
  return AppLocaleNotifier();
});

/// Reactive translation lookup provider
final trProvider = Provider<String Function(String key)>((ref) {
  final lang = ref.watch(appLocaleProvider);
  return (String key) => AppTranslations.translate(key, lang);
});

/// Reactive bilingual text helper provider
final bilingualProvider = Provider<String Function(String vi, String en)>((ref) {
  final lang = ref.watch(appLocaleProvider);
  return (String vi, String en) => lang == AppLanguage.en ? en : vi;
});

