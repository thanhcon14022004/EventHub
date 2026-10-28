import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_hub/core/network/api_client.dart';
import 'package:event_hub/core/routing/app_router.dart';
import 'package:event_hub/core/theme/app_theme.dart';
import 'package:event_hub/features/admin/providers/admin_provider.dart';
import 'package:event_hub/features/admin/screens/admin_dashboard_screen.dart';
import 'package:event_hub/features/auth/providers/auth_provider.dart';
import 'package:event_hub/features/bookings/models/booking_model.dart';
import 'package:event_hub/features/bookings/providers/booking_provider.dart';
import 'package:event_hub/features/notifications/providers/notification_provider.dart';
import 'package:event_hub/features/provider/screens/provider_dashboard_screen.dart';
import 'package:event_hub/features/provider/screens/provider_services_screen.dart';
import 'package:event_hub/features/services/providers/product_approval_provider.dart';
import 'package:event_hub/features/services/screens/service_detail_screen.dart';

void main() {
  testWidgets('ProviderServicesScreen renders all provider services under AppTheme.lightTheme', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProviderServicesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Kho Dịch vụ của bạn'), findsOneWidget);
    expect(find.text('Tất cả (2)'), findsOneWidget);
    expect(find.textContaining('Pastel Dream'), findsOneWidget);
    expect(find.textContaining('Rustic Sang Trọng'), findsOneWidget);

    // Filter tabs work cleanly
    await tester.tap(find.text('Đang hoạt động (1)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Rustic Sang Trọng'), findsOneWidget);
    expect(find.textContaining('Pastel Dream'), findsNothing);

    await tester.ensureVisible(find.text('Chờ duyệt (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chờ duyệt (1)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pastel Dream'), findsOneWidget);
    expect(find.textContaining('Rustic Sang Trọng'), findsNothing);
  });

  testWidgets('ProviderDashboardScreen only displays net revenue after 10% Admin commission', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final sampleBooking = BookingModel(
      id: 'b1',
      code: 'EH-001',
      serviceId: 's1',
      serviceTitle: 'Test Service',
      providerName: 'NCC',
      packageName: 'VIP',
      date: '29/10/2026',
      time: '09:00',
      price: '15.000.000 ₫',
      rawPrice: 15000000,
      status: 'Accepted',
      imageUrl: '',
      location: 'HN',
      guestCount: '100',
      customerName: 'Customer',
      customerPhone: '0900000000',
      createdAt: DateTime(2026, 10, 29),
    );
    expect(sampleBooking.providerNetRawPrice, 13500000);
    expect(sampleBooking.providerNetPrice, '13.500.000 ₫');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProviderDashboardScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Doanh thu thực nhận'), findsOneWidget);
    expect(find.text('40.500.000 ₫'), findsOneWidget);
    expect(find.text('45.000.000 ₫'), findsNothing);
  });

  testWidgets('Add Service dialog allows provider to upload extra service images', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProviderServicesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Add Service bottom sheet
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Thêm dịch vụ sự kiện mới'), findsOneWidget);
    expect(find.text('Hình ảnh dịch vụ'), findsOneWidget);
    expect(find.text('Đã tải 0/6 ảnh'), findsOneWidget);
    expect(find.text('Thư viện'), findsOneWidget);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    expect(find.text('URL'), findsOneWidget);
    expect(find.text('Nhấn để tải ảnh thực tế của dịch vụ lên'), findsOneWidget);
  });

  testWidgets(
    '6 End-to-End Business Flows: Catalog Sync, Shared Bookings, Dynamic SePay Revenue & Admin Approval/Lock',
    timeout: const Timeout(Duration(seconds: 15)),
    (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(1440, 2800);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final offlineApiClient = ApiClient()
      ..dio.options.connectTimeout = null
      ..dio.options.receiveTimeout = null
      ..dio.httpClientAdapter = _InstantOfflineAdapter();
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(offlineApiClient),
      ],
    );
    addTearDown(container.dispose);

    // FLOW 1: NCC adds service -> Pending (not in public catalog) -> Admin approves -> In public catalog & Detail screen
    container.read(productApprovalProvider.notifier).addProduct(
          providerId: 'prv-1',
          providerName: 'Ánh Dương Wedding & Decor',
          title: 'Gói Hoa Tươi Pha Lê Hoàng Gia 2026',
          category: 'Trang trí sự kiện',
          price: '32.000.000 ₫',
          priceNum: 32000000,
          description: 'Thiết kế hoa lan hồ điệp nhập khẩu cao cấp.',
          imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
        );
    final createdId = container.read(productApprovalProvider).products.first.id;
    expect(
      container.read(productApprovalProvider).approvedPublicCatalog.any((p) => p.id == createdId),
      isFalse,
    );

    container.read(productApprovalProvider.notifier).approveProduct(createdId);
    expect(
      container.read(productApprovalProvider).approvedPublicCatalog.any((p) => p.id == createdId),
      isTrue,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ServiceDetailScreen(serviceId: createdId),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Gói Hoa Tươi Pha Lê Hoàng Gia 2026'), findsOneWidget);
    expect(find.text('32.000.000 ₫'), findsWidgets);

    // FLOW 4 & 5: Register as Provider -> starts as Customer + Pending App -> Admin approves -> Login promotes to Provider -> Lock blocks login
    await tester.runAsync(() async {
      final regOk = await container.read(authProvider.notifier).register(
            fullName: 'Lê Minh Tuấn',
            email: 'tuan.decor@eventhub.vn',
            password: 'password123',
            phoneNumber: '0988777666',
            role: 'Provider',
            businessName: 'Tuấn Luxury Event',
          );
      expect(regOk, isTrue);
      expect(container.read(authProvider).isProvider, isFalse); // Must wait for Admin approval!

      final pendingApp = container
          .read(adminProvider.notifier)
          .findApplicationForUser(container.read(authProvider).user!.id, 'tuan.decor@eventhub.vn');
      expect(pendingApp, isNotNull);
      expect(pendingApp!.isPending, isTrue);

      // Admin approves application
      container.read(adminProvider.notifier).approveApplication(pendingApp.id);
      await container.read(authProvider.notifier).logout();

      // Next login promotes user to Provider!
      final loginAfterApprove = await container.read(authProvider.notifier).login('tuan.decor@eventhub.vn', 'password123');
      expect(loginAfterApprove, isTrue);
      expect(container.read(authProvider).isProvider, isTrue);

      // Admin locks user -> login is blocked!
      final managedUser = container.read(adminProvider.notifier).findUserByEmail('tuan.decor@eventhub.vn')!;
      container.read(adminProvider.notifier).toggleUserStatus(managedUser.id);
      await container.read(authProvider.notifier).logout();
      final loginWhenLocked = await container.read(authProvider.notifier).login('tuan.decor@eventhub.vn', 'password123');
      expect(loginWhenLocked, isFalse);
      expect(container.read(authProvider).errorMessage, contains('tạm khóa'));

      // FLOW 2 & 3: Shared bookings & Dynamic Admin SePay Revenue
      await container.read(authProvider.notifier).login('customer@eventhub.vn', '1234567');
      await container.read(bookingProvider.notifier).paySingleBooking('b1', 'SePay'); // Pay 15.000.000 ₫ order
      await container.read(authProvider.notifier).login('admin@eventhub.vn', '1234567');
      container.read(bookingProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminDashboardScreen(),
        ),
      ),
    );
    await tester.pump();

    // Initial 70M (4 paid orders: b3 12M, b5 15M, pb-confirmed-1 25M, pb-inprogress-1 18M) + 15M newly paid order b1 = 85.000.000 ₫ (5 đơn đã thanh toán), 10% = +8.500.000 ₫, 90% = 76.500.000 ₫
    expect(find.text('85.000.000 ₫'), findsOneWidget);
    expect(find.text('5 đơn đã thanh toán'), findsOneWidget);
    expect(find.text('+8.500.000 ₫'), findsOneWidget);
    expect(find.text('76.500.000 ₫'), findsOneWidget);
  });

  testWidgets(
    'SePay check payment success automatically navigates to HomeScreen and displays Đặt đơn thành công notification',
    timeout: const Timeout(Duration(seconds: 15)),
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sepayMockAdapter = _SepayTransactionMockAdapter(
        paidTransferContent: 'EH EH20261016001',
        amountIn: 15000000,
      );
      final apiClient = ApiClient()
        ..dio.options.connectTimeout = null
        ..dio.options.receiveTimeout = null
        ..dio.httpClientAdapter = sepayMockAdapter;

      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(apiClient),
        ],
      );
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await container.read(authProvider.notifier).login('customer@eventhub.vn', '1234567');
        container.read(bookingProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      final router = container.read(routerProvider);
      final bookingB1 = container.read(bookingProvider).firstWhere((b) => b.id == 'b1');
      expect(bookingB1.status, 'Accepted');
      expect(container.read(notificationProvider).unreadCount, 2);

      // Start on MyBookings directly before mounting router
      router.go('/bookings');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();

      // Push SePay Payment Screen
      router.push('/bookings/b1/sepay', extra: bookingB1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Thanh toán tự động SePay'), findsOneWidget);

      // Tap "Tôi đã chuyển khoản (Kiểm tra ngay)" -> SePay detects payment -> auto-jumps to Home ('/')
      final checkBtn = find.text('Tôi đã chuyển khoản (Kiểm tra ngay)');
      await tester.ensureVisible(checkBtn);
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(checkBtn);
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Verify: SepayPaymentScreen closed automatically without blocking modal, landed on HomeScreen
      expect(find.text('Thanh toán tự động SePay'), findsNothing);
      expect(find.text('Danh mục dịch vụ'), findsOneWidget);

      // Verify: Prominent "Đặt đơn thành công" banner & SnackBar displayed on HomeScreen + Bell badge updated
      expect(find.text('Đặt đơn thành công! 🎉'), findsOneWidget);
      expect(find.textContaining('Đặt đơn thành công! Đơn EH-20261016-001'), findsOneWidget);
      expect(container.read(notificationProvider).unreadCount, 3);
      expect(container.read(notificationProvider).items.first.title, 'Đặt đơn thành công! 🎉');
      expect(
        container.read(bookingProvider).firstWhere((b) => b.id == 'b1').status,
        'Confirmed',
      );
    },
  );

  test('BookingModel handles InProgress status and helper getters properly', () {
    final booking = BookingModel(
      id: 'test-inprogress-1',
      code: 'EH-20261030-999',
      serviceId: 's1',
      serviceTitle: 'Dịch vụ trang trí hoa cưới',
      providerName: 'Ánh Dương Wedding & Decor',
      packageName: 'Gói VIP',
      date: '30/10/2026',
      time: '18:00',
      price: '20.000.000 ₫',
      rawPrice: 20000000,
      status: 'InProgress',
      imageUrl: 'https://example.com/test.jpg',
      location: 'Hà Nội',
      guestCount: '100',
      customerName: 'Nguyễn Văn A',
      customerPhone: '0987654321',
      createdAt: DateTime(2026, 10, 30),
    );

    expect(booking.isInProgress, isTrue);
    expect(booking.isPaid, isTrue);
    expect(booking.statusLabel, 'Đang diễn ra');
    expect(booking.statusColor, const Color(0xFF6366F1));
    expect(booking.providerNetRawPrice, 18000000); // 20M - 10% = 18M
  });

  test('BookingNotifier allows Provider to switch status between InProgress and Completed', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          ApiClient()
            ..dio.options.connectTimeout = null
            ..dio.options.receiveTimeout = null
            ..dio.httpClientAdapter = _InstantOfflineAdapter(),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Login as Provider
    await container.read(authProvider.notifier).login('provider@eventhub.vn', '1234567');
    final bookingNotifier = container.read(bookingProvider.notifier);

    // Initial state: Ánh Dương has bookings including pb-confirmed-1
    var bookings = container.read(bookingProvider);
    final confirmedBooking = bookings.firstWhere((b) => b.id == 'pb-confirmed-1');
    expect(confirmedBooking.status, 'Confirmed');

    // Switch confirmed booking to InProgress (Đang diễn ra)
    bookingNotifier.setBookingInProgress('pb-confirmed-1');
    bookings = container.read(bookingProvider);
    final inProgressBooking = bookings.firstWhere((b) => b.id == 'pb-confirmed-1');
    expect(inProgressBooking.status, 'InProgress');
    expect(inProgressBooking.isInProgress, isTrue);

    // Switch from InProgress to Completed (Hoàn thành)
    bookingNotifier.completeProviderBooking('pb-confirmed-1');
    bookings = container.read(bookingProvider);
    final completedBooking = bookings.firstWhere((b) => b.id == 'pb-confirmed-1');
    expect(completedBooking.status, 'Completed');
    expect(completedBooking.isCompleted, isTrue);
  });

  test('Customer submits star rating and review after Provider marks order Completed', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          ApiClient()
            ..dio.options.connectTimeout = null
            ..dio.options.receiveTimeout = null
            ..dio.httpClientAdapter = _InstantOfflineAdapter(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).login('customer@eventhub.vn', '1234567');
    final bookingNotifier = container.read(bookingProvider.notifier);

    // Initial booking
    var bookings = container.read(bookingProvider);
    final targetBooking = bookings.firstWhere((b) => b.id == 'b1');

    // Simulate completion
    bookingNotifier.completeProviderBooking(targetBooking.id);
    bookings = container.read(bookingProvider);
    var updated = bookings.firstWhere((b) => b.id == targetBooking.id);
    expect(updated.status, 'Completed');
    expect(updated.isReviewed, isFalse);
    expect(updated.needsCustomerCompletion, isTrue);

    // Customer clicks Hoàn thành and submits review
    bookingNotifier.submitBookingReview(
      bookingId: targetBooking.id,
      rating: 5,
      comment: 'Dịch vụ trang trí hoa tươi cực kỳ lộng lẫy và đúng giờ!',
    );

    bookings = container.read(bookingProvider);
    updated = bookings.firstWhere((b) => b.id == targetBooking.id);
    expect(updated.status, 'Completed');
    expect(updated.isReviewed, isTrue);
    expect(updated.rating, 5);
    expect(updated.reviewComment, 'Dịch vụ trang trí hoa tươi cực kỳ lộng lẫy và đúng giờ!');
    expect(updated.needsCustomerCompletion, isFalse);
  });

  test('MomoPaymentScreen processes payment from VU THI MAI ANH to HA TRUNG THANH and updates booking', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          ApiClient()
            ..dio.options.connectTimeout = null
            ..dio.options.receiveTimeout = null
            ..dio.httpClientAdapter = _InstantOfflineAdapter(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).login('customer@eventhub.vn', '1234567');
    final bookingNotifier = container.read(bookingProvider.notifier);

    final bookings = container.read(bookingProvider);
    expect(bookings.isNotEmpty, isTrue);
    final target = bookings.first;

    // Simulate Momo payment call
    await bookingNotifier.paySingleBooking(
      target.id,
      'MoMo (0862460313 -> 0364663787)',
    );

    final updatedList = container.read(bookingProvider);
    final paid = updatedList.firstWhere((b) => b.id == target.id);
    expect(paid.status, 'Confirmed');
    expect(paid.paymentGateway, contains('0364663787'));
  });
}

class _SepayTransactionMockAdapter implements HttpClientAdapter {
  final String paidTransferContent;
  final int amountIn;

  _SepayTransactionMockAdapter({
    required this.paidTransferContent,
    required this.amountIn,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.host == 'my.sepay.vn') {
      final payload = jsonEncode({
        'transactions': [
          {
            'transaction_content': paidTransferContent,
            'amount_in': '$amountIn',
          },
        ],
      });
      return ResponseBody.fromString(
        payload,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'Offline test environment',
    );
  }

  @override
  void close({bool force = false}) {}
}

class _InstantOfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'Offline test environment',
    );
  }

  @override
  void close({bool force = false}) {}
}
