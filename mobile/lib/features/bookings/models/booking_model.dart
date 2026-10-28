import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BookingModel {
  /// Tỷ lệ hoa hồng nền tảng Admin thu trên mỗi đơn hàng (10%)
  static const double adminCommissionRate = 0.10;

  static String formatVnd(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return '${amount < 0 ? '-' : ''}${buffer.toString()} ₫';
  }

  final String id;
  final String code;
  final String serviceId;
  final String serviceTitle;
  final String providerName;
  final String packageName;
  final String? packageId;
  final String date;
  final String time;
  final String price;
  final int rawPrice;
  final String status; // 'PendingProviderApproval', 'Accepted', 'Confirmed', 'Completed', 'Cancelled', 'Rejected'
  final String imageUrl;
  final String location;
  final String guestCount;
  final String? notes;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? providerId;
  final String? paymentGateway;
  final DateTime createdAt;
  final int? rating;
  final String? reviewComment;
  final DateTime? reviewedAt;

  const BookingModel({
    required this.id,
    required this.code,
    required this.serviceId,
    required this.serviceTitle,
    required this.providerName,
    required this.packageName,
    this.packageId,
    required this.date,
    required this.time,
    required this.price,
    required this.rawPrice,
    required this.status,
    required this.imageUrl,
    required this.location,
    required this.guestCount,
    this.notes,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    this.providerId,
    this.paymentGateway,
    required this.createdAt,
    this.rating,
    this.reviewComment,
    this.reviewedAt,
  });

  bool get canBePaid => status == 'Accepted' || status == 'AwaitingPayment';
  bool get isInProgress => status == 'InProgress';
  bool get isConfirmed => status == 'Confirmed';
  bool get isCompleted => status == 'Completed';
  bool get isPaid => status == 'Confirmed' || status == 'InProgress' || status == 'Completed';
  bool get isReviewed => rating != null && rating! > 0;
  bool get needsCustomerCompletion => status == 'Completed' && !isReviewed;
  String get specialRequirements => notes ?? '';

  /// Số tiền thực nhận của Nhà cung cấp sau khi đã trừ % hoa hồng cho Admin
  int get providerNetRawPrice {
    final baseAmount = rawPrice > 0
        ? rawPrice
        : int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return (baseAmount * (1 - adminCommissionRate)).round();
  }

  String get providerNetPrice => formatVnd(providerNetRawPrice);

  String get statusLabel {
    switch (status) {
      case 'PendingProviderApproval':
      case 'Pending':
        return 'Chờ nhà cung cấp duyệt';
      case 'Accepted':
        return 'Đã duyệt (Chờ thanh toán)';
      case 'Confirmed':
        return 'Đã xác nhận & Thanh toán';
      case 'InProgress':
        return 'Đang diễn ra';
      case 'Completed':
        return 'Đã hoàn thành';
      case 'Cancelled':
        return 'Đã hủy';
      case 'Rejected':
        return 'Đã từ chối';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'PendingProviderApproval':
      case 'Pending':
        return AppColors.pending;
      case 'Accepted':
        return AppColors.info;
      case 'Confirmed':
        return AppColors.success;
      case 'InProgress':
        return const Color(0xFF6366F1); // Indigo tím hiện đại
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
      case 'Rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get statusBg {
    switch (status) {
      case 'PendingProviderApproval':
      case 'Pending':
        return AppColors.pendingLight;
      case 'Accepted':
        return AppColors.infoLight;
      case 'Confirmed':
        return AppColors.successLight;
      case 'InProgress':
        return const Color(0xFFEEF2FF);
      case 'Completed':
        return AppColors.successLight;
      case 'Cancelled':
      case 'Rejected':
        return AppColors.errorLight;
      default:
        return AppColors.secondary;
    }
  }

  BookingModel copyWith({
    String? id,
    String? code,
    String? serviceId,
    String? serviceTitle,
    String? providerName,
    String? packageName,
    String? packageId,
    String? date,
    String? time,
    String? price,
    int? rawPrice,
    String? status,
    String? imageUrl,
    String? location,
    String? guestCount,
    String? notes,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? providerId,
    String? paymentGateway,
    DateTime? createdAt,
    int? rating,
    String? reviewComment,
    DateTime? reviewedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      code: code ?? this.code,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      providerName: providerName ?? this.providerName,
      packageName: packageName ?? this.packageName,
      packageId: packageId ?? this.packageId,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      rawPrice: rawPrice ?? this.rawPrice,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      guestCount: guestCount ?? this.guestCount,
      notes: notes ?? this.notes,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      providerId: providerId ?? this.providerId,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      reviewComment: reviewComment ?? this.reviewComment,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'providerName': providerName,
      'packageName': packageName,
      'packageId': packageId,
      'date': date,
      'time': time,
      'price': price,
      'rawPrice': rawPrice,
      'status': status,
      'imageUrl': imageUrl,
      'location': location,
      'guestCount': guestCount,
      'notes': notes,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'providerId': providerId,
      'paymentGateway': paymentGateway,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'reviewComment': reviewComment,
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? json['bookingCode']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      serviceTitle: json['serviceTitle']?.toString() ?? 'Dịch vụ sự kiện',
      providerName: json['providerName']?.toString() ?? 'Nhà cung cấp EventHub',
      packageName: json['packageName']?.toString() ?? json['packageNameSnapshot']?.toString() ?? 'Gói dịch vụ',
      packageId: json['packageId']?.toString(),
      date: json['date']?.toString() ?? (json['eventDate'] != null ? json['eventDate'].toString().split('T').first : ''),
      time: json['time']?.toString() ?? '09:00 - 15:00',
      price: json['price']?.toString() ?? '${json['totalAmount'] ?? json['packagePriceSnapshot'] ?? 0} ₫',
      rawPrice: (json['rawPrice'] as num?)?.toInt() ?? (json['totalAmount'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'PendingProviderApproval',
      imageUrl: json['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=400&q=80',
      location: json['location']?.toString() ?? json['eventAddress']?.toString() ?? '',
      guestCount: json['guestCount']?.toString() ?? '100 khách',
      notes: json['notes']?.toString() ?? json['specialRequirements']?.toString(),
      customerName: json['customerName']?.toString() ?? 'Khách hàng',
      customerPhone: json['customerPhone']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString(),
      providerId: json['providerId']?.toString(),
      paymentGateway: json['paymentGateway']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      rating: (json['rating'] as num?)?.toInt(),
      reviewComment: json['reviewComment']?.toString(),
      reviewedAt: json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt'].toString()) : null,
    );
  }
}
