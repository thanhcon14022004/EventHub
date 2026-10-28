import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/booking_model.dart';

final bookingProvider = StateNotifierProvider<BookingNotifier, List<BookingModel>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authProvider);
  return BookingNotifier(apiClient, authState);
});

class BookingNotifier extends StateNotifier<List<BookingModel>> {
  static const String _sharedStorageKey = 'eventhub_shared_bookings_v4';
  final ApiClient _apiClient;
  final AuthState _authState;
  List<BookingModel> _allBookings = [];
  Future<void>? _loadFuture;
  bool _hasLocalMutation = false;

  BookingNotifier(this._apiClient, this._authState) : super([]) {
    _loadFuture = _initAndLoad();
  }

  List<BookingModel> _filterForCurrentRole(List<BookingModel> source) {
    if (!_authState.isAuthenticated || _authState.user == null) {
      return [];
    }
    final user = _authState.user!;

    // Admin sees all bookings across the entire EventHub platform
    if (_authState.isAdmin) {
      return List<BookingModel>.from(source);
    }

    // Provider sees bookings placed for their services
    if (_authState.isProvider) {
      final provName = user.fullName.trim().toLowerCase();
      final isAnhDuong = user.email.toLowerCase() == 'provider@eventhub.vn' || provName.contains('ánh dương');
      return source.where((b) {
        final bProv = b.providerName.trim().toLowerCase();
        if (b.providerId != null && (b.providerId == user.id || b.providerId == user.providerProfileId)) {
          return true;
        }
        if (bProv == provName) return true;
        if (isAnhDuong && bProv.contains('ánh dương')) return true;
        return false;
      }).toList();
    }

    // Customer sees bookings placed by them
    final custEmail = user.email.trim().toLowerCase();
    final custName = user.fullName.trim().toLowerCase();
    return source.where((b) {
      if (b.customerEmail != null && b.customerEmail!.trim().toLowerCase() == custEmail) {
        return true;
      }
      if (b.customerName.trim().toLowerCase() == custName) {
        return true;
      }
      return false;
    }).toList();
  }

  Future<void> _initAndLoad() async {
    if (!_authState.isAuthenticated) {
      _allBookings = [];
      state = [];
      return;
    }

    _allBookings = List<BookingModel>.from(_initialSharedBookings);
    state = _filterForCurrentRole(_allBookings);
    await _loadFromLocal();
    await fetchFromApi();
  }

  static final List<BookingModel> _initialSharedBookings = [
    BookingModel(
      id: 'pb-confirmed-1',
      code: 'EH-20261028-088',
      serviceId: 's1',
      serviceTitle: 'Gói Trang trí Tiệc Cưới Phong Cách Luxury Floral',
      providerName: 'Ánh Dương Wedding & Decor',
      providerId: 'prv-1',
      packageName: 'Gói Hoa Tươi Cao Cấp',
      packageId: 'pkg-luxury-1',
      date: '05/11/2026',
      time: '17:00 - 22:00',
      price: '25.000.000 ₫',
      rawPrice: 25000000,
      status: 'Confirmed', // Đã duyệt & khách đã chuyển khoản SePay thành công
      paymentGateway: 'SePay - ACB (Đã thanh toán)',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=400&q=80',
      location: 'Khách sạn Melia, 44B Lý Thường Kiệt, Hà Nội',
      guestCount: '180 khách',
      notes: 'Khách yêu cầu tone hoa pastel trắng kem và hồng blush.',
      customerName: 'Hoàng Minh Tuấn',
      customerPhone: '0912 345 678',
      customerEmail: 'hoangminhtuan@gmail.com',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BookingModel(
      id: 'pb-inprogress-1',
      code: 'EH-20261029-055',
      serviceId: 's1',
      serviceTitle: 'Gói Trang Trí Sân Vườn VIP Ngoại Ô',
      providerName: 'Ánh Dương Wedding & Decor',
      providerId: 'prv-1',
      packageName: 'Gói Sân Vườn VIP',
      packageId: 'pkg-vip-1',
      date: '30/10/2026',
      time: '14:00 - 21:00',
      price: '18.000.000 ₫',
      rawPrice: 18000000,
      status: 'InProgress', // Đang trong quá trình tổ chức / triển khai
      paymentGateway: 'SePay - ACB (Đã thanh toán)',
      imageUrl: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=400&q=80',
      location: 'Asean Resort Thạch Thất, Hà Nội',
      guestCount: '150 khách',
      notes: 'Đang thi công rạp ngoài trời và dàn đèn fairy lights.',
      customerName: 'Nguyễn Thu Trang',
      customerPhone: '0988 776 655',
      customerEmail: 'thutrang.decor@gmail.com',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    BookingModel(
      id: 'pb3',
      code: 'EH-20261017-009',
      serviceId: 's1',
      serviceTitle: 'Gói Trang Trí Sân Vườn VIP Ngoại Ô',
      providerName: 'Ánh Dương Wedding & Decor',
      providerId: 'prv-1',
      packageName: 'Gói Sân Vườn VIP',
      packageId: 'pkg-vip-1',
      date: '30/10/2026',
      time: '16:00 - 21:00',
      price: '28.000.000 ₫',
      rawPrice: 28000000,
      status: 'PendingProviderApproval',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=400&q=80',
      location: 'Resort Flamingo Đại Lải (200 khách)',
      guestCount: '200 khách',
      notes: 'Tone màu chủ đạo hồng pastel & trắng',
      customerName: 'Phạm Quỳnh Nga',
      customerPhone: '0948 123 789',
      customerEmail: 'pham.quynh.nga@gmail.com',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    BookingModel(
      id: 'b1',
      code: 'EH-20261016-001',
      serviceId: 's1',
      serviceTitle: 'Gói Trang trí Tiệc Cưới Phong Cách Rustic',
      providerName: 'Ánh Dương Wedding & Decor',
      providerId: 'prv-1',
      packageName: 'Gói Tiêu Chuẩn',
      packageId: 'pkg-1',
      date: '24/10/2026',
      time: '09:00 - 15:00',
      price: '15.000.000 ₫',
      rawPrice: 15000000,
      status: 'Accepted', // Chờ thanh toán
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=400&q=80',
      location: '123 Hoàng Mai, Hà Nội',
      guestCount: '120 khách',
      notes: 'Khách yêu cầu bổ sung 2 trụ hoa tươi ở lối đi',
      customerName: 'Khách hàng Demo',
      customerPhone: '0901 234 567',
      customerEmail: 'customer@eventhub.vn',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    BookingModel(
      id: 'b2',
      code: 'EH-20261010-004',
      serviceId: 's2',
      serviceTitle: 'Quay Phim & Chụp Ảnh Sự Kiện Doanh Nghiệp',
      providerName: 'LensCraft Media Group',
      providerId: 'prv-2',
      packageName: 'Gói Phóng Sự HD',
      packageId: 'pkg-media-1',
      date: '20/10/2026',
      time: '08:00 - 12:00',
      price: '8.500.000 ₫',
      rawPrice: 8500000,
      status: 'Accepted', // Chờ thanh toán
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=400&q=80',
      location: 'Khách sạn JW Marriott, Hà Nội',
      guestCount: '80 khách',
      notes: 'Cần quay 4K và giao clip highlight 60 giây',
      customerName: 'Khách hàng Demo',
      customerPhone: '0901 234 567',
      customerEmail: 'customer@eventhub.vn',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BookingModel(
      id: 'b4',
      code: 'EH-20261012-008',
      serviceId: 's5',
      serviceTitle: 'Hệ Thống Âm Thanh & Ánh Sáng Sân Khấu Tiệc',
      providerName: 'SoundLight Pro Solution',
      providerId: 'prv-4',
      packageName: 'Gói Hội Trường 200 Khách',
      packageId: 'pkg-sound-1',
      date: '20/10/2026',
      time: '07:30 - 13:00',
      price: '6.000.000 ₫',
      rawPrice: 6000000,
      status: 'Accepted', // Chờ thanh toán
      imageUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=400&q=80',
      location: 'Trung tâm Hội nghị Quốc Gia, Hà Nội',
      guestCount: '200 khách',
      notes: 'Cần 4 mic không dây và 2 loa sub',
      customerName: 'Khách hàng Demo',
      customerPhone: '0901 234 567',
      customerEmail: 'customer@eventhub.vn',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    BookingModel(
      id: 'b3',
      code: 'EH-20260925-012',
      serviceId: 's3',
      serviceTitle: 'Buffet Tiệc Cao Cấp & Tiệc Trà Teabreak',
      providerName: 'Royal Catering Saigon',
      providerId: 'prv-royal',
      packageName: 'Gói Finger Food VIP',
      packageId: 'pkg-buffet-1',
      date: '28/09/2026',
      time: '14:00 - 18:00',
      price: '12.000.000 ₫',
      rawPrice: 12000000,
      status: 'Completed',
      paymentGateway: 'SePay - ACB',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=400&q=80',
      location: 'Villa Thảo Điền, TP. Thủ Đức',
      guestCount: '60 khách',
      notes: 'Khách đã đánh giá 5 sao',
      customerName: 'Khách hàng Demo',
      customerPhone: '0901 234 567',
      customerEmail: 'customer@eventhub.vn',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    BookingModel(
      id: 'b5',
      code: 'EH-20261005-018',
      serviceId: 's4',
      serviceTitle: 'Hội Trường Sự Kiện & Hội Nghị Grand Ballroom',
      providerName: 'Skyline Convention Hall',
      providerId: 'prv-skyline',
      packageName: 'Gói Hội Nghị Doanh Nghiệp',
      packageId: 'pkg-hall-1',
      date: '18/10/2026',
      time: '08:00 - 17:00',
      price: '15.000.000 ₫',
      rawPrice: 15000000,
      status: 'Confirmed',
      paymentGateway: 'SePay - ACB',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=400&q=80',
      location: 'Tòa nhà FPT Tower, Cầu Giấy, Hà Nội',
      guestCount: '250 khách',
      notes: 'Đã thanh toán 100% qua SePay VietQR',
      customerName: 'Công ty CP FPT Software',
      customerPhone: '0247 300 7300',
      customerEmail: 'fpt.software@eventhub.vn',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  /// Load shared bookings across Customer, Provider and Admin from SharedPreferences
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_sharedStorageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> rawList = jsonDecode(jsonStr);
        final list = rawList.map((item) => BookingModel.fromJson(item as Map<String, dynamic>)).toList();
        if (list.isNotEmpty && !_hasLocalMutation) {
          _allBookings = list;
          state = _filterForCurrentRole(_allBookings);
          return;
        }
      }

      if (!_hasLocalMutation) {
        _allBookings = List<BookingModel>.from(_initialSharedBookings);
        state = _filterForCurrentRole(_allBookings);
        await _saveToLocal();
      }
    } catch (_) {}
  }

  /// Save shared platform bookings state to SharedPreferences
  Future<void> _saveToLocal() async {
    if (!_authState.isAuthenticated) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _allBookings.map((b) => b.toJson()).toList();
      await prefs.setString(_sharedStorageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Try fetching latest bookings from Backend REST API
  Future<void> fetchFromApi() async {
    if (!_authState.isAuthenticated) return;
    try {
      final response = await _apiClient.dio.get('${ApiConstants.bookings}/my');
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        List<dynamic> items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          items = rawData['data'];
        }

        if (items.isNotEmpty) {
          final serverBookings = items.map((i) => BookingModel.fromJson(i as Map<String, dynamic>)).toList();
          final existingIds = serverBookings.map((b) => b.id).toSet();
          final localOnly = _allBookings.where((b) => !existingIds.contains(b.id)).toList();
          _allBookings = [...serverBookings, ...localOnly];
          state = _filterForCurrentRole(_allBookings);
          await _saveToLocal();
        }
      }
    } catch (_) {}
  }

  /// Add a newly created booking by customer
  BookingModel addBooking({
    required String serviceId,
    required String serviceTitle,
    required String providerName,
    String? providerId,
    required String packageName,
    String? packageId,
    required String date,
    required String time,
    required int rawPrice,
    required String location,
    required String guestCount,
    String? notes,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    final randomSuffix = (100 + (now.millisecondsSinceEpoch % 900)).toString();
    final dateCode = DateFormat('yyyyMMdd').format(now);
    final code = 'EH-$dateCode-$randomSuffix';
    final id = 'booking-${now.millisecondsSinceEpoch}';

    final formattedPrice = NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(rawPrice);

    final newBooking = BookingModel(
      id: id,
      code: code,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      providerName: providerName,
      providerId: providerId,
      packageName: packageName,
      packageId: packageId,
      date: date,
      time: time,
      price: formattedPrice,
      rawPrice: rawPrice,
      status: 'PendingProviderApproval',
      imageUrl: imageUrl ?? 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=400&q=80',
      location: location,
      guestCount: guestCount,
      notes: notes,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail ?? _authState.user?.email,
      createdAt: now,
    );

    _hasLocalMutation = true;
    _allBookings = [newBooking, ..._allBookings];
    state = _filterForCurrentRole(_allBookings);
    _saveToLocal();
    _syncBookingToBackend(newBooking);

    return newBooking;
  }

  Future<void> _syncBookingToBackend(BookingModel booking) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.bookings,
        data: {
          'bookingCode': booking.code,
          'serviceId': booking.serviceId,
          'packageId': booking.packageId,
          'packageNameSnapshot': booking.packageName,
          'packagePriceSnapshot': booking.rawPrice,
          'totalAmount': booking.rawPrice,
          'eventDate': booking.date,
          'eventAddress': booking.location,
          'guestCount': int.tryParse(booking.guestCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 100,
          'specialRequirements': booking.notes,
          'customerName': booking.customerName,
          'customerPhone': booking.customerPhone,
        },
      );
    } catch (_) {}
  }

  /// Customer pays for multiple selected bookings at once (Bulk checkout)
  Future<bool> payMultipleBookings(List<String> bookingIds, String gateway) async {
    await _loadFuture;
    _hasLocalMutation = true;
    _allBookings = _allBookings.map((b) {
      if (bookingIds.contains(b.id)) {
        return b.copyWith(status: 'Confirmed', paymentGateway: gateway);
      }
      return b;
    }).toList();
    state = _filterForCurrentRole(_allBookings);
    await _saveToLocal();

    // Async sync to Backend Payments Checkout
    try {
      await _apiClient.dio.post(
        '${ApiConstants.payments}/checkout',
        data: {'bookingIds': bookingIds, 'paymentGateway': gateway},
      );
    } catch (_) {}

    return true;
  }

  /// Customer pays for a single booking
  Future<bool> paySingleBooking(String bookingId, String gateway) async {
    return payMultipleBookings([bookingId], gateway);
  }

  /// Automatically check SePay balance changes for a booking
  Future<bool> checkSepayPayment(String bookingId) async {
    await _loadFuture;
    final existing = getBookingById(bookingId);
    if (existing != null && (existing.status == 'Confirmed' || existing.status == 'Completed')) {
      return true;
    }

    // 1. Check with Backend first
    try {
      final response = await _apiClient.dio.get('${ApiConstants.sepay}/check/$bookingId');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['isPaid'] == true) {
          _hasLocalMutation = true;
          _allBookings = _allBookings.map((b) {
            if (b.id == bookingId || b.code == bookingId) {
              return b.copyWith(status: 'Confirmed', paymentGateway: 'SePay - ACB');
            }
            return b;
          }).toList();
          state = _filterForCurrentRole(_allBookings);
          await _saveToLocal();
          return true;
        }
      }
    } catch (_) {}

    // 2. Direct SePay Cloud API check as backup
    try {
      final sepayDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      )..httpClientAdapter = _apiClient.dio.httpClientAdapter;
      final sepayRes = await sepayDio.get(
        'https://my.sepay.vn/userapi/transactions/list?limit=30',
        options: Options(headers: {
          'Authorization': 'Bearer XWPNYEIQU6QXFEML5HU2XKVZSBGOQBRMNDTBA7NG2CZCYUISIVPLDKMKGFDKOJYI',
        }),
      );
      if (sepayRes.statusCode == 200 && sepayRes.data != null) {
        final txs = sepayRes.data['transactions'] as List<dynamic>?;
        if (txs != null) {
          final booking = getBookingById(bookingId);
          if (booking != null) {
            final normCode = booking.code.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
            for (final tx in txs) {
              final content = (tx['transaction_content'] ?? '').toString().toLowerCase();
              final cleanContent = content.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
              final amountIn = double.tryParse((tx['amount_in'] ?? '0').toString()) ?? 0;
              if (cleanContent.contains(normCode) && amountIn > 0) {
                _hasLocalMutation = true;
                _allBookings = _allBookings.map((b) {
                  if (b.id == bookingId) {
                    return b.copyWith(status: 'Confirmed', paymentGateway: 'SePay - ACB');
                  }
                  return b;
                }).toList();
                state = _filterForCurrentRole(_allBookings);
                await _saveToLocal();
                return true;
              }
            }
          }
        }
      }
    } catch (_) {}

    return false;
  }

  /// Customer cancels a booking
  void cancelBooking(String bookingId) {
    _allBookings = _allBookings.map((b) {
      if (b.id == bookingId) {
        return b.copyWith(status: 'Cancelled');
      }
      return b;
    }).toList();
    state = _filterForCurrentRole(_allBookings);
    _saveToLocal();

    _safeApiCall(() => _apiClient.dio.post(
      '${ApiConstants.bookings}/$bookingId/cancel',
      data: {'reason': 'Khách hàng yêu cầu hủy'},
    ));
  }

  /// Permanently delete a booking from local storage and backend
  void deleteBooking(String bookingId) {
    _allBookings = _allBookings.where((b) => b.id != bookingId).toList();
    state = _filterForCurrentRole(_allBookings);
    _saveToLocal();

    _safeApiCall(() => _apiClient.dio.delete(
      '${ApiConstants.bookings}/$bookingId',
    ));
  }

  /// Provider accepts a booking request
  void acceptProviderBooking(String bookingId) {
    _allBookings = _allBookings.map((b) {
      if (b.id == bookingId) {
        return b.copyWith(status: 'Accepted');
      }
      return b;
    }).toList();
    state = _filterForCurrentRole(_allBookings);
    _saveToLocal();

    _safeApiCall(() => _apiClient.dio.post(
      '${ApiConstants.providerBookings}/$bookingId/accept',
    ));
  }

  /// Provider rejects a booking request
  void rejectProviderBooking(String bookingId, String reason) {
    _allBookings = _allBookings.map((b) {
      if (b.id == bookingId) {
        final currentNotes = b.notes ?? '';
        final updatedNotes = currentNotes.isEmpty
            ? 'Lý do từ chối: $reason'
            : '$currentNotes | Lý do từ chối: $reason';
        return b.copyWith(status: 'Rejected', notes: updatedNotes);
      }
      return b;
    }).toList();
    state = _filterForCurrentRole(_allBookings);
    _saveToLocal();

    _safeApiCall(() => _apiClient.dio.post(
      '${ApiConstants.providerBookings}/$bookingId/reject',
      data: {'rejectionReason': reason},
    ));
  }

  /// Provider updates booking status (e.g. InProgress, Completed, Confirmed)
  void updateProviderBookingStatus(String bookingId, String newStatus) {
    _allBookings = _allBookings.map((b) {
      if (b.id == bookingId) {
        return b.copyWith(status: newStatus);
      }
      return b;
    }).toList();
    state = _filterForCurrentRole(_allBookings);
    _saveToLocal();

    _safeApiCall(() => _apiClient.dio.post(
      '${ApiConstants.providerBookings}/$bookingId/status',
      data: {'status': newStatus},
    ));
  }

  /// Provider sets booking into InProgress (Đang diễn ra)
  void setBookingInProgress(String bookingId) {
    updateProviderBookingStatus(bookingId, 'InProgress');
  }

  /// Provider marks booking as completed
  void completeProviderBooking(String bookingId) {
    updateProviderBookingStatus(bookingId, 'Completed');
  }

  /// Customer confirms completion and submits star rating & review
  void submitBookingReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) {
    _hasLocalMutation = true;
    _allBookings = _allBookings.map((b) {
      if (b.id == bookingId) {
        return b.copyWith(
          status: 'Completed',
          rating: rating,
          reviewComment: comment,
          reviewedAt: DateTime.now(),
        );
      }
      return b;
    }).toList();
    state = _filterForCurrentRole(_allBookings);
    _saveToLocal();

    _safeApiCall(() => _apiClient.dio.post(
      '${ApiConstants.bookings}/$bookingId/review',
      data: {
        'rating': rating,
        'comment': comment,
      },
    ));
  }

  Future<void> _safeApiCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (_) {}
  }

  BookingModel? getBookingById(String id) {
    for (final b in state) {
      if (b.id == id) return b;
    }
    for (final b in _allBookings) {
      if (b.id == id) return b;
    }
    return null;
  }
}
