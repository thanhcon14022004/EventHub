import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Base API URL dynamically configured depending on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        // Android Emulator uses 10.0.2.2 to reach host machine localhost
        return 'http://10.0.2.2:5000/api';
      } else if (Platform.isIOS || Platform.isMacOS || Platform.isWindows) {
        return 'http://localhost:5000/api';
      }
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';

  static const String categories = '/categories';
  static const String services = '/services';
  static const String bookings = '/bookings';
  static const String payments = '/payments';
  static const String sepay = '/sepay';
  static const String reviews = '/reviews';
  static const String conversations = '/conversations';
  static const String notifications = '/notifications';

  static const String providerServices = '/provider/services';
  static const String providerBookings = '/provider/bookings';
  static const String providerAvailability = '/provider/availability';
  static const String providerRevenue = '/provider/reports/revenue';
}
