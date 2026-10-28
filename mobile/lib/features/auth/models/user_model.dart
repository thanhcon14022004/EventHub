class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final String? providerProfileId;
  final String? providerApprovalStatus;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.providerProfileId,
    this.providerApprovalStatus,
  });

  bool get isCustomer => role.toLowerCase() == 'customer';
  bool get isProvider => role.toLowerCase() == 'provider';
  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString() ?? 'Customer',
      providerProfileId: json['providerProfileId']?.toString(),
      providerApprovalStatus: json['providerApprovalStatus']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role,
      'providerProfileId': providerProfileId,
      'providerApprovalStatus': providerApprovalStatus,
    };
  }
}
