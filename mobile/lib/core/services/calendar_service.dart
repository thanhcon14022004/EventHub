import 'package:flutter/services.dart';

class CalendarService {
  static const MethodChannel _channel = MethodChannel('com.eventhub.app/momo');

  /// Mở ứng dụng Lịch (Google Calendar trên Android) để thêm sự kiện
  static Future<bool> addEventToCalendar({
    required String title,
    String description = '',
    String location = '',
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final start = startTime ?? DateTime.now().add(const Duration(days: 1));
      final end = endTime ?? start.add(const Duration(hours: 4));

      final success = await _channel.invokeMethod<bool>('addCalendarEvent', {
        'title': title,
        'description': description,
        'location': location,
        'startTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
      });

      return success ?? true;
    } catch (e) {
      return false;
    }
  }
}

