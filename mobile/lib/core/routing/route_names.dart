class RouteNames {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Customer routes
  static const String home = '/';
  static const String categories = '/categories';
  static const String bookings = '/bookings';
  static const String chat = '/chat';
  static const String profile = '/profile';

  // Provider routes
  static const String providerDashboard = '/provider';
  static const String providerServices = '/provider/services';
  static const String providerBookings = '/provider/bookings';
  static const String providerChat = '/provider/chat';

  // Details & Features
  static const String serviceList = '/services';
  static const String serviceDetail = '/services/:id';
  static const String createBooking = '/services/:id/book';
  static const String bookingDetail = '/bookings/:id';
  static const String chatConversation = '/chat/:id';
  static const String notifications = '/notifications';
  static const String favorites = '/favorites';
}
