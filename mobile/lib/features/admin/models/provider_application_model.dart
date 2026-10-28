class ProviderApplicationModel {
  final String id;
  final String userId;
  final String applicantName;
  final String businessName;
  final String email;
  final String phoneNumber;
  final String category;
  final String address;
  final String city;
  final int experienceYears;
  final String description;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? taxOrIdNumber;
  final List<String> samplePhotos;

  ProviderApplicationModel({
    required this.id,
    required this.userId,
    required this.applicantName,
    required this.businessName,
    required this.email,
    required this.phoneNumber,
    required this.category,
    required this.address,
    required this.city,
    required this.experienceYears,
    required this.description,
    this.status = 'Pending',
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
    this.taxOrIdNumber,
    this.samplePhotos = const [],
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  ProviderApplicationModel copyWith({
    String? id,
    String? userId,
    String? applicantName,
    String? businessName,
    String? email,
    String? phoneNumber,
    String? category,
    String? address,
    String? city,
    int? experienceYears,
    String? description,
    String? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? rejectionReason,
    String? taxOrIdNumber,
    List<String>? samplePhotos,
  }) {
    return ProviderApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      applicantName: applicantName ?? this.applicantName,
      businessName: businessName ?? this.businessName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      category: category ?? this.category,
      address: address ?? this.address,
      city: city ?? this.city,
      experienceYears: experienceYears ?? this.experienceYears,
      description: description ?? this.description,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      taxOrIdNumber: taxOrIdNumber ?? this.taxOrIdNumber,
      samplePhotos: samplePhotos ?? this.samplePhotos,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'applicantName': applicantName,
    'businessName': businessName,
    'email': email,
    'phoneNumber': phoneNumber,
    'category': category,
    'address': address,
    'city': city,
    'experienceYears': experienceYears,
    'description': description,
    'status': status,
    'submittedAt': submittedAt.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
    'rejectionReason': rejectionReason,
    'taxOrIdNumber': taxOrIdNumber,
    'samplePhotos': samplePhotos,
  };

  factory ProviderApplicationModel.fromMap(Map<String, dynamic> map) => ProviderApplicationModel(
    id: map['id']?.toString() ?? '',
    userId: map['userId']?.toString() ?? '',
    applicantName: map['applicantName']?.toString() ?? '',
    businessName: map['businessName']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    phoneNumber: map['phoneNumber']?.toString() ?? '',
    category: map['category']?.toString() ?? 'Trang trí sự kiện',
    address: map['address']?.toString() ?? '',
    city: map['city']?.toString() ?? 'Hà Nội',
    experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 1,
    description: map['description']?.toString() ?? '',
    status: map['status']?.toString() ?? 'Pending',
    submittedAt: DateTime.tryParse(map['submittedAt']?.toString() ?? '') ?? DateTime.now(),
    reviewedAt: map['reviewedAt'] != null ? DateTime.tryParse(map['reviewedAt'].toString()) : null,
    rejectionReason: map['rejectionReason']?.toString(),
    taxOrIdNumber: map['taxOrIdNumber']?.toString(),
    samplePhotos: (map['samplePhotos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
  );
}

