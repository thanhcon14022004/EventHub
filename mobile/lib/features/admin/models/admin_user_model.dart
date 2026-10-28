class AdminUserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role; // 'Customer', 'Provider', 'Admin'
  final bool isActive;
  final DateTime createdAt;
  final int bookingCount;
  final String? businessName;
  final String? notes;

  AdminUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.bookingCount = 0,
    this.businessName,
    this.notes,
  });

  bool get isCustomer => role.toLowerCase() == 'customer';
  bool get isProvider => role.toLowerCase() == 'provider';
  bool get isAdmin => role.toLowerCase() == 'admin';

  AdminUserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    int? bookingCount,
    String? businessName,
    String? notes,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      bookingCount: bookingCount ?? this.bookingCount,
      businessName: businessName ?? this.businessName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'avatarUrl': avatarUrl,
    'role': role,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'bookingCount': bookingCount,
    'businessName': businessName,
    'notes': notes,
  };

  factory AdminUserModel.fromMap(Map<String, dynamic> map) => AdminUserModel(
    id: map['id']?.toString() ?? '',
    fullName: map['fullName']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    phoneNumber: map['phoneNumber']?.toString(),
    avatarUrl: map['avatarUrl']?.toString(),
    role: map['role']?.toString() ?? 'Customer',
    isActive: map['isActive'] as bool? ?? true,
    createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    bookingCount: (map['bookingCount'] as num?)?.toInt() ?? 0,
    businessName: map['businessName']?.toString(),
    notes: map['notes']?.toString(),
  );
}

