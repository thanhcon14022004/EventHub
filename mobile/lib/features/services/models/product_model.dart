import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum ProductApprovalStatus {
  pending, // Chờ duyệt
  approved, // Đang hoạt động / Đã duyệt
  rejected, // Bị từ chối
  hidden, // Tạm ẩn bởi NCC
}

class ProductPackageItem {
  final String name;
  final String price;
  final String description;
  final List<String> includes;

  const ProductPackageItem({
    required this.name,
    required this.price,
    required this.description,
    this.includes = const [],
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'description': description,
    'includes': includes,
  };

  factory ProductPackageItem.fromMap(Map<String, dynamic> map) => ProductPackageItem(
    name: map['name'] ?? '',
    price: map['price'] ?? '',
    description: map['description'] ?? '',
    includes: List<String>.from(map['includes'] ?? []),
  );
}

class ProductModel {
  final String id;
  final String providerId;
  final String providerName;
  final String? providerAvatar;
  final String? providerPhone;
  final String? providerEmail;
  final String title;
  final String category;
  final String price; // Formatted price (e.g. 15.000.000 ₫)
  final double priceNum; // Numeric price
  final String description;
  final String imageUrl;
  final List<String> galleryUrls;
  final int packagesCount;
  final List<ProductPackageItem> packages;
  final ProductApprovalStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? adminNotes;
  final int views;
  final int inquiriesCount;
  final double rating;
  final int reviewsCount;

  const ProductModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    this.providerAvatar,
    this.providerPhone,
    this.providerEmail,
    required this.title,
    required this.category,
    required this.price,
    required this.priceNum,
    required this.description,
    required this.imageUrl,
    this.galleryUrls = const [],
    this.packagesCount = 1,
    this.packages = const [],
    this.status = ProductApprovalStatus.pending,
    required this.createdAt,
    this.reviewedAt,
    this.rejectionReason,
    this.adminNotes,
    this.views = 0,
    this.inquiriesCount = 0,
    this.rating = 5.0,
    this.reviewsCount = 0,
  });

  bool get isPending => status == ProductApprovalStatus.pending;
  bool get isApproved => status == ProductApprovalStatus.approved;
  bool get isRejected => status == ProductApprovalStatus.rejected;
  bool get isHidden => status == ProductApprovalStatus.hidden;

  String get statusLabel {
    switch (status) {
      case ProductApprovalStatus.pending:
        return 'Chờ quản trị duyệt';
      case ProductApprovalStatus.approved:
        return 'Đang hoạt động';
      case ProductApprovalStatus.rejected:
        return 'Bị từ chối';
      case ProductApprovalStatus.hidden:
        return 'Tạm ẩn';
    }
  }

  Color get statusColor {
    switch (status) {
      case ProductApprovalStatus.pending:
        return AppColors.pending;
      case ProductApprovalStatus.approved:
        return AppColors.success;
      case ProductApprovalStatus.rejected:
        return const Color(0xFFEF4444);
      case ProductApprovalStatus.hidden:
        return AppColors.textMuted;
    }
  }

  Color get statusBg {
    switch (status) {
      case ProductApprovalStatus.pending:
        return AppColors.pendingLight;
      case ProductApprovalStatus.approved:
        return AppColors.successLight;
      case ProductApprovalStatus.rejected:
        return const Color(0xFFFEE2E2);
      case ProductApprovalStatus.hidden:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ProductApprovalStatus.pending:
        return Icons.hourglass_top_rounded;
      case ProductApprovalStatus.approved:
        return Icons.check_circle_rounded;
      case ProductApprovalStatus.rejected:
        return Icons.cancel_rounded;
      case ProductApprovalStatus.hidden:
        return Icons.visibility_off_rounded;
    }
  }

  String get timeFormatted {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes <= 0 ? 1 : diff.inMinutes}p trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  ProductModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? providerAvatar,
    String? providerPhone,
    String? providerEmail,
    String? title,
    String? category,
    String? price,
    double? priceNum,
    String? description,
    String? imageUrl,
    List<String>? galleryUrls,
    int? packagesCount,
    List<ProductPackageItem>? packages,
    ProductApprovalStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? rejectionReason,
    String? adminNotes,
    int? views,
    int? inquiriesCount,
    double? rating,
    int? reviewsCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerAvatar: providerAvatar ?? this.providerAvatar,
      providerPhone: providerPhone ?? this.providerPhone,
      providerEmail: providerEmail ?? this.providerEmail,
      title: title ?? this.title,
      category: category ?? this.category,
      price: price ?? this.price,
      priceNum: priceNum ?? this.priceNum,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      packagesCount: packagesCount ?? this.packagesCount,
      packages: packages ?? this.packages,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
      views: views ?? this.views,
      inquiriesCount: inquiriesCount ?? this.inquiriesCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'providerId': providerId,
    'providerName': providerName,
    'providerAvatar': providerAvatar,
    'providerPhone': providerPhone,
    'providerEmail': providerEmail,
    'title': title,
    'category': category,
    'price': price,
    'priceNum': priceNum,
    'description': description,
    'imageUrl': imageUrl,
    'galleryUrls': galleryUrls,
    'packagesCount': packagesCount,
    'packages': packages.map((p) => p.toMap()).toList(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
    'rejectionReason': rejectionReason,
    'adminNotes': adminNotes,
    'views': views,
    'inquiriesCount': inquiriesCount,
    'rating': rating,
    'reviewsCount': reviewsCount,
  };

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final statusStr = map['status']?.toString() ?? 'pending';
    final parsedStatus = ProductApprovalStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => ProductApprovalStatus.pending,
    );
    return ProductModel(
      id: map['id']?.toString() ?? '',
      providerId: map['providerId']?.toString() ?? '',
      providerName: map['providerName']?.toString() ?? '',
      providerAvatar: map['providerAvatar']?.toString(),
      providerPhone: map['providerPhone']?.toString(),
      providerEmail: map['providerEmail']?.toString(),
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Trang trí sự kiện',
      price: map['price']?.toString() ?? '0 ₫',
      priceNum: (map['priceNum'] as num?)?.toDouble() ?? 0,
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      galleryUrls: (map['galleryUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      packagesCount: (map['packagesCount'] as num?)?.toInt() ?? 1,
      packages: (map['packages'] as List<dynamic>?)
              ?.map((e) => ProductPackageItem.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      status: parsedStatus,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      reviewedAt: map['reviewedAt'] != null ? DateTime.tryParse(map['reviewedAt'].toString()) : null,
      rejectionReason: map['rejectionReason']?.toString(),
      adminNotes: map['adminNotes']?.toString(),
      views: (map['views'] as num?)?.toInt() ?? 0,
      inquiriesCount: (map['inquiriesCount'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

