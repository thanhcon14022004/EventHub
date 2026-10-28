import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bookings/models/booking_model.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final String category; // 'order' | 'promo' | 'payment'
  final String? bookingId;
  final String? bookingCode;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.category,
    this.bookingId,
    this.bookingCode,
  });

  AppNotificationItem copyWith({
    bool? isRead,
  }) {
    return AppNotificationItem(
      id: id,
      title: title,
      body: body,
      time: time,
      isRead: isRead ?? this.isRead,
      category: category,
      bookingId: bookingId,
      bookingCode: bookingCode,
    );
  }

  IconData get icon {
    switch (category) {
      case 'promo':
        return Icons.local_offer_rounded;
      case 'payment':
        return Icons.verified_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  Color get color {
    switch (category) {
      case 'promo':
        return const Color(0xFFF59E0B);
      case 'payment':
        return const Color(0xFF4F46E5);
      default:
        return const Color(0xFF10B981);
    }
  }

  Color get bg {
    switch (category) {
      case 'promo':
        return const Color(0xFFFFFBEB);
      case 'payment':
        return const Color(0xFFEEF2FF);
      default:
        return const Color(0xFFECFDF5);
    }
  }

  List<Color> get gradient {
    switch (category) {
      case 'promo':
        return const [Color(0xFFF59E0B), Color(0xFFD97706)];
      case 'payment':
        return const [Color(0xFF4F46E5), Color(0xFF7C3AED)];
      default:
        return const [Color(0xFF10B981), Color(0xFF059669)];
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'promo':
        return 'Ưu đãi';
      default:
        return 'Đơn đặt';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time,
        'isRead': isRead,
        'category': category,
        'bookingId': bookingId,
        'bookingCode': bookingCode,
      };

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      isRead: json['isRead'] == true,
      category: (json['category'] ?? 'order').toString(),
      bookingId: json['bookingId']?.toString(),
      bookingCode: json['bookingCode']?.toString(),
    );
  }
}

class NotificationState {
  final List<AppNotificationItem> items;
  final BookingModel? activeHomeSuccessBooking;
  final BookingModel? pendingSnackBarBooking;
  final String lastPaymentGateway;

  const NotificationState({
    required this.items,
    this.activeHomeSuccessBooking,
    this.pendingSnackBarBooking,
    this.lastPaymentGateway = 'MoMo',
  });

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<AppNotificationItem>? items,
    BookingModel? activeHomeSuccessBooking,
    bool clearActiveHomeSuccess = false,
    BookingModel? pendingSnackBarBooking,
    bool clearPendingSnackBar = false,
    String? lastPaymentGateway,
  }) {
    return NotificationState(
      items: items ?? this.items,
      activeHomeSuccessBooking:
          clearActiveHomeSuccess ? null : (activeHomeSuccessBooking ?? this.activeHomeSuccessBooking),
      pendingSnackBarBooking:
          clearPendingSnackBar ? null : (pendingSnackBarBooking ?? this.pendingSnackBarBooking),
      lastPaymentGateway: lastPaymentGateway ?? this.lastPaymentGateway,
    );
  }
}

const List<AppNotificationItem> _initialNotifications = [
  AppNotificationItem(
    id: 'notif-1',
    title: 'Đơn đặt được chấp nhận! 🎉',
    body: 'Nhà cung cấp Ánh Dương Wedding & Decor đã chấp nhận đơn đặt EH-20261016-001 của bạn.',
    time: '10 phút trước',
    isRead: false,
    category: 'order',
    bookingId: 'b1',
    bookingCode: 'EH-20261016-001',
  ),
  AppNotificationItem(
    id: 'notif-2',
    title: 'Khuyến mãi mùa cưới giảm 15% 💍',
    body: 'Giảm ngay 15% cho tất cả các gói dịch vụ chụp ảnh & quay phim sự kiện khi đặt trước ngày 30/10.',
    time: '2 giờ trước',
    isRead: false,
    category: 'promo',
  ),
  AppNotificationItem(
    id: 'notif-3',
    title: 'Thanh toán đặt cọc thành công ⚡',
    body: 'Giao dịch thanh toán SePay VietQR 15.000.000 ₫ cho tiệc cưới Rustic đã được ghi nhận tức thì.',
    time: 'Hôm qua',
    isRead: true,
    category: 'payment',
  ),
  AppNotificationItem(
    id: 'notif-4',
    title: 'Nhắc nhở lịch hẹn khảo sát 📅',
    body: 'Đội ngũ kỹ thuật LensCraft Media sẽ có mặt lúc 14:00 chiều nay để khảo sát sân khấu.',
    time: '2 ngày trước',
    isRead: true,
    category: 'order',
  ),
];

class NotificationNotifier extends StateNotifier<NotificationState> {
  static const String _storageKey = 'eventhub_notifications_v1';
  bool _hasLocalMutation = false;
  Timer? _homeSuccessAutoDismissTimer;

  NotificationNotifier() : super(const NotificationState(items: _initialNotifications)) {
    _loadFromLocal();
  }

  @override
  void dispose() {
    _homeSuccessAutoDismissTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null && saved.isNotEmpty) {
        final decoded = jsonDecode(saved) as List<dynamic>;
        final loaded = decoded
            .map((e) => AppNotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if (loaded.isNotEmpty && !_hasLocalMutation) {
          state = state.copyWith(items: loaded);
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  /// Triggered automatically when payment is confirmed (SePay / MoMo)
  void notifyBookingPaymentSuccess(BookingModel booking, {String gatewayName = 'MoMo'}) {
    _hasLocalMutation = true;
    final newItem = AppNotificationItem(
      id: 'notif-pay-${booking.id}-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Đặt đơn thành công! 🎉',
      body: 'Đơn đặt ${booking.code} - ${booking.serviceTitle} (${booking.price}) đã thanh toán $gatewayName thành công.',
      time: 'Vừa xong',
      isRead: false,
      category: 'order',
      bookingId: booking.id,
      bookingCode: booking.code,
    );

    state = state.copyWith(
      items: [newItem, ...state.items],
      activeHomeSuccessBooking: booking,
      pendingSnackBarBooking: booking,
      lastPaymentGateway: gatewayName,
    );
    _saveToLocal();

    // Tự động tắt thông báo sau đúng 10 giây
    _homeSuccessAutoDismissTimer?.cancel();
    _homeSuccessAutoDismissTimer = Timer(const Duration(seconds: 10), () {
      dismissHomeSuccessBanner();
    });
  }

  void consumePendingSnackBar() {
    if (state.pendingSnackBarBooking != null) {
      state = state.copyWith(clearPendingSnackBar: true);
    }
  }

  void dismissHomeSuccessBanner() {
    _homeSuccessAutoDismissTimer?.cancel();
    if (state.activeHomeSuccessBooking != null) {
      state = state.copyWith(clearActiveHomeSuccess: true);
    }
  }

  void markAsRead(String id) {
    _hasLocalMutation = true;
    state = state.copyWith(
      items: state.items.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
    _saveToLocal();
  }

  void markAllAsRead() {
    _hasLocalMutation = true;
    state = state.copyWith(
      items: state.items.map((n) => n.copyWith(isRead: true)).toList(),
    );
    _saveToLocal();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

