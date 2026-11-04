import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppBgColor {
  white,  // Trắng (Mặc định)
  gray,   // Xám
  blue,   // Xanh dương
  green,  // Xanh lá
  red,    // Đỏ
  yellow, // Vàng
}

extension AppBgColorExt on AppBgColor {
  String get nameVi {
    switch (this) {
      case AppBgColor.white:
        return 'Trắng (Mặc định)';
      case AppBgColor.gray:
        return 'Xám';
      case AppBgColor.blue:
        return 'Xanh dương';
      case AppBgColor.green:
        return 'Xanh lá';
      case AppBgColor.red:
        return 'Đỏ';
      case AppBgColor.yellow:
        return 'Vàng';
    }
  }

  String get nameEn {
    switch (this) {
      case AppBgColor.white:
        return 'White (Default)';
      case AppBgColor.gray:
        return 'Gray';
      case AppBgColor.blue:
        return 'Blue';
      case AppBgColor.green:
        return 'Green';
      case AppBgColor.red:
        return 'Red';
      case AppBgColor.yellow:
        return 'Yellow';
    }
  }

  String get descriptionVi {
    switch (this) {
      case AppBgColor.white:
        return 'Nền trắng nguyên bản, sáng rõ tiêu chuẩn';
      case AppBgColor.gray:
        return 'Nền xám dịu mắt, sang trọng';
      case AppBgColor.blue:
        return 'Nền xanh pastel dịu êm, thanh lịch';
      case AppBgColor.green:
        return 'Nền xanh lá thiên nhiên tươi mát';
      case AppBgColor.red:
        return 'Nền đỏ pastel ấm áp, nổi bật';
      case AppBgColor.yellow:
        return 'Nền vàng kem pastel nhẹ nhàng, tươi sáng';
    }
  }

  String get descriptionEn {
    switch (this) {
      case AppBgColor.white:
        return 'Original crisp white, clean standard';
      case AppBgColor.gray:
        return 'Soft eye-friendly modern gray';
      case AppBgColor.blue:
        return 'Serene pastel blue, elegant look';
      case AppBgColor.green:
        return 'Refreshing nature-inspired pastel green';
      case AppBgColor.red:
        return 'Warm soft pastel rose red';
      case AppBgColor.yellow:
        return 'Gentle sunny pastel cream yellow';
    }
  }

  Color get color {
    switch (this) {
      case AppBgColor.white:
        return const Color(0xFFFFFFFF);
      case AppBgColor.gray:
        return const Color(0xFFE2E8F0); // Modern neutral soft gray
      case AppBgColor.blue:
        return const Color(0xFFE0F2FE); // Soft pastel sky blue
      case AppBgColor.green:
        return const Color(0xFFDCFCE7); // Soft pastel fresh mint green
      case AppBgColor.red:
        return const Color(0xFFFEE2E2); // Soft pastel warm rose red
      case AppBgColor.yellow:
        return const Color(0xFFFEF9C3); // Soft pastel warm cream yellow
    }
  }

  Color get previewColor {
    switch (this) {
      case AppBgColor.white:
        return const Color(0xFFFFFFFF);
      case AppBgColor.gray:
        return const Color(0xFF94A3B8);
      case AppBgColor.blue:
        return const Color(0xFF38BDF8);
      case AppBgColor.green:
        return const Color(0xFF4ADE80);
      case AppBgColor.red:
        return const Color(0xFFEF4444);
      case AppBgColor.yellow:
        return const Color(0xFFEAB308);
    }
  }
}

class AppBgColorNotifier extends StateNotifier<AppBgColor> {
  static const String _prefKey = 'app_background_color_setting';

  AppBgColorNotifier() : super(AppBgColor.white) {
    _loadBgColor();
  }

  Future<void> _loadBgColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      switch (saved) {
        case 'gray':
          state = AppBgColor.gray;
          break;
        case 'blue':
          state = AppBgColor.blue;
          break;
        case 'green':
          state = AppBgColor.green;
          break;
        case 'red':
          state = AppBgColor.red;
          break;
        case 'yellow':
          state = AppBgColor.yellow;
          break;
        default:
          state = AppBgColor.white;
      }
    } catch (_) {}
  }

  Future<void> setBgColor(AppBgColor color) async {
    state = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, color.name);
    } catch (_) {}
  }
}

final appBgColorProvider = StateNotifierProvider<AppBgColorNotifier, AppBgColor>((ref) {
  return AppBgColorNotifier();
});
