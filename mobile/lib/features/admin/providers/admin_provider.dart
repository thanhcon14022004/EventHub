import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_user_model.dart';
import '../models/provider_application_model.dart';

class AdminState {
  final List<AdminUserModel> users;
  final List<ProviderApplicationModel> applications;
  final String userSearchQuery;
  final String userRoleFilter; // 'All', 'Customer', 'Provider', 'Admin'
  final String userStatusFilter; // 'All', 'Active', 'Inactive'
  final String appSearchQuery;
  final String appStatusFilter; // 'All', 'Pending', 'Approved', 'Rejected'
  final bool isLoading;

  const AdminState({
    this.users = const [],
    this.applications = const [],
    this.userSearchQuery = '',
    this.userRoleFilter = 'All',
    this.userStatusFilter = 'All',
    this.appSearchQuery = '',
    this.appStatusFilter = 'All',
    this.isLoading = false,
  });

  // KPI Getters
  int get totalUsersCount => users.length;
  int get customersCount => users.where((u) => u.isCustomer).length;
  int get providersCount => users.where((u) => u.isProvider).length;
  int get activeUsersCount => users.where((u) => u.isActive).length;
  int get lockedUsersCount => users.where((u) => !u.isActive).length;

  int get totalApplicationsCount => applications.length;
  int get pendingApplicationsCount => applications.where((a) => a.isPending).length;
  int get approvedApplicationsCount => applications.where((a) => a.isApproved).length;
  int get rejectedApplicationsCount => applications.where((a) => a.isRejected).length;

  // Filtered Lists
  List<AdminUserModel> get filteredUsers {
    return users.where((u) {
      // Search filter
      if (userSearchQuery.isNotEmpty) {
        final query = userSearchQuery.toLowerCase();
        final matchName = u.fullName.toLowerCase().contains(query);
        final matchEmail = u.email.toLowerCase().contains(query);
        final matchPhone = u.phoneNumber?.contains(query) ?? false;
        final matchBiz = u.businessName?.toLowerCase().contains(query) ?? false;
        if (!matchName && !matchEmail && !matchPhone && !matchBiz) return false;
      }
      // Role filter
      if (userRoleFilter != 'All' && u.role.toLowerCase() != userRoleFilter.toLowerCase()) {
        return false;
      }
      // Status filter
      if (userStatusFilter == 'Active' && !u.isActive) return false;
      if (userStatusFilter == 'Inactive' && u.isActive) return false;

      return true;
    }).toList();
  }

  List<ProviderApplicationModel> get filteredApplications {
    return applications.where((a) {
      // Search filter
      if (appSearchQuery.isNotEmpty) {
        final query = appSearchQuery.toLowerCase();
        final matchBiz = a.businessName.toLowerCase().contains(query);
        final matchApp = a.applicantName.toLowerCase().contains(query);
        final matchEmail = a.email.toLowerCase().contains(query);
        final matchCat = a.category.toLowerCase().contains(query);
        final matchCity = a.city.toLowerCase().contains(query);
        if (!matchBiz && !matchApp && !matchEmail && !matchCat && !matchCity) return false;
      }
      // Status filter
      if (appStatusFilter != 'All' && a.status.toLowerCase() != appStatusFilter.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  AdminState copyWith({
    List<AdminUserModel>? users,
    List<ProviderApplicationModel>? applications,
    String? userSearchQuery,
    String? userRoleFilter,
    String? userStatusFilter,
    String? appSearchQuery,
    String? appStatusFilter,
    bool? isLoading,
  }) {
    return AdminState(
      users: users ?? this.users,
      applications: applications ?? this.applications,
      userSearchQuery: userSearchQuery ?? this.userSearchQuery,
      userRoleFilter: userRoleFilter ?? this.userRoleFilter,
      userStatusFilter: userStatusFilter ?? this.userStatusFilter,
      appSearchQuery: appSearchQuery ?? this.appSearchQuery,
      appStatusFilter: appStatusFilter ?? this.appStatusFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});

class AdminNotifier extends StateNotifier<AdminState> {
  static const String _usersStorageKey = 'eventhub_admin_users_v1';
  static const String _appsStorageKey = 'eventhub_admin_apps_v1';

  AdminNotifier() : super(const AdminState()) {
    _loadInitialData();
    _loadFromLocal();
  }

  void _loadInitialData() {
    state = state.copyWith(
      users: _initialUsers,
      applications: _initialApplications,
    );
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersStorageKey);
      final appsJson = prefs.getString(_appsStorageKey);

      List<AdminUserModel>? loadedUsers;
      List<ProviderApplicationModel>? loadedApps;

      if (usersJson != null && usersJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(usersJson);
        loadedUsers = decoded.map((e) => AdminUserModel.fromMap(Map<String, dynamic>.from(e as Map))).toList();
      }
      if (appsJson != null && appsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(appsJson);
        loadedApps = decoded.map((e) => ProviderApplicationModel.fromMap(Map<String, dynamic>.from(e as Map))).toList();
      }

      if ((loadedUsers != null && loadedUsers.isNotEmpty) || (loadedApps != null && loadedApps.isNotEmpty)) {
        state = state.copyWith(
          users: (loadedUsers != null && loadedUsers.isNotEmpty) ? loadedUsers : state.users,
          applications: (loadedApps != null && loadedApps.isNotEmpty) ? loadedApps : state.applications,
        );
      }
    } catch (_) {}
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersStorageKey, jsonEncode(state.users.map((u) => u.toMap()).toList()));
      await prefs.setString(_appsStorageKey, jsonEncode(state.applications.map((a) => a.toMap()).toList()));
    } catch (_) {}
  }

  AdminUserModel? findUserByEmail(String email) {
    final clean = email.trim().toLowerCase();
    for (final u in state.users) {
      if (u.email.trim().toLowerCase() == clean) return u;
    }
    return null;
  }

  ProviderApplicationModel? findApplicationForUser(String userId, String email) {
    final clean = email.trim().toLowerCase();
    for (final a in state.applications) {
      if (a.userId == userId || a.email.trim().toLowerCase() == clean) return a;
    }
    return null;
  }

  void registerLocalUser({
    required String id,
    required String fullName,
    required String email,
    String? phoneNumber,
    String role = 'Customer',
    String? businessName,
  }) {
    final existingIdx = state.users.indexWhere((u) => u.email.trim().toLowerCase() == email.trim().toLowerCase());
    if (existingIdx >= 0) return;

    final newUser = AdminUserModel(
      id: id,
      fullName: fullName,
      email: email.trim().toLowerCase(),
      phoneNumber: phoneNumber,
      role: role,
      businessName: businessName,
      isActive: true,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(users: [newUser, ...state.users]);
    _saveToLocal();
  }

  void submitApplication({
    required String userId,
    required String applicantName,
    required String businessName,
    required String email,
    required String phoneNumber,
    required String category,
    String address = 'Văn phòng đối tác EventHub',
    String city = 'Hà Nội',
    int experienceYears = 3,
    String description = 'Cam kết cung cấp dịch vụ sự kiện chuyên nghiệp, đúng tiến độ và chất lượng tiêu chuẩn EventHub.',
    String? taxOrIdNumber,
    List<String> samplePhotos = const [],
  }) {
    final now = DateTime.now();
    final cleanEmail = email.trim().toLowerCase();
    final existingIdx = state.applications.indexWhere(
      (a) => a.userId == userId || a.email.trim().toLowerCase() == cleanEmail,
    );

    final newApp = ProviderApplicationModel(
      id: existingIdx >= 0
          ? state.applications[existingIdx].id
          : 'APP-${now.year}-${(100 + now.millisecondsSinceEpoch % 900)}',
      userId: userId,
      applicantName: applicantName,
      businessName: businessName,
      email: cleanEmail,
      phoneNumber: phoneNumber,
      category: category,
      address: address,
      city: city,
      experienceYears: experienceYears,
      description: description,
      status: 'Pending',
      submittedAt: now,
      taxOrIdNumber: taxOrIdNumber,
      samplePhotos: samplePhotos.isNotEmpty
          ? samplePhotos
          : const ['https://images.unsplash.com/photo-1519741497674-611481863552?w=800'],
    );

    final updatedApps = [...state.applications];
    if (existingIdx >= 0) {
      updatedApps.removeAt(existingIdx);
    }
    updatedApps.insert(0, newApp);

    state = state.copyWith(applications: updatedApps);
    _saveToLocal();
  }

  // --- User Management Actions ---
  void searchUsers(String query) {
    state = state.copyWith(userSearchQuery: query);
  }

  void filterUserRole(String role) {
    state = state.copyWith(userRoleFilter: role);
  }

  void filterUserStatus(String status) {
    state = state.copyWith(userStatusFilter: status);
  }

  void toggleUserStatus(String userId) {
    final updated = state.users.map((u) {
      if (u.id == userId) {
        return u.copyWith(isActive: !u.isActive);
      }
      return u;
    }).toList();
    state = state.copyWith(users: updated);
    _saveToLocal();
  }

  void updateUserRole(String userId, String newRole) {
    final updated = state.users.map((u) {
      if (u.id == userId) {
        return u.copyWith(role: newRole);
      }
      return u;
    }).toList();
    state = state.copyWith(users: updated);
    _saveToLocal();
  }

  void deleteUser(String userId) {
    final updated = state.users.where((u) => u.id != userId).toList();
    state = state.copyWith(users: updated);
    _saveToLocal();
  }

  // --- Provider Application Actions ---
  void searchApplications(String query) {
    state = state.copyWith(appSearchQuery: query);
  }

  void filterApplicationStatus(String status) {
    state = state.copyWith(appStatusFilter: status);
  }

  void approveApplication(String applicationId) {
    final now = DateTime.now();
    ProviderApplicationModel? approvedApp;

    final updatedApps = state.applications.map((app) {
      if (app.id == applicationId) {
        approvedApp = app.copyWith(
          status: 'Approved',
          reviewedAt: now,
          rejectionReason: null,
        );
        return approvedApp!;
      }
      return app;
    }).toList();

    // Auto promote or add user as Provider
    List<AdminUserModel> updatedUsers = [...state.users];
    if (approvedApp != null) {
      final existingIndex = updatedUsers.indexWhere(
        (u) => u.id == approvedApp!.userId || u.email.trim().toLowerCase() == approvedApp!.email.trim().toLowerCase(),
      );
      if (existingIndex >= 0) {
        final existing = updatedUsers[existingIndex];
        updatedUsers[existingIndex] = existing.copyWith(
          role: 'Provider',
          businessName: approvedApp!.businessName,
        );
      } else {
        updatedUsers.insert(
          0,
          AdminUserModel(
            id: approvedApp!.userId,
            fullName: approvedApp!.applicantName,
            email: approvedApp!.email,
            phoneNumber: approvedApp!.phoneNumber,
            role: 'Provider',
            businessName: approvedApp!.businessName,
            createdAt: now,
            isActive: true,
          ),
        );
      }
    }

    state = state.copyWith(
      applications: updatedApps,
      users: updatedUsers,
    );
    _saveToLocal();
  }

  void rejectApplication(String applicationId, String reason) {
    final now = DateTime.now();
    final updatedApps = state.applications.map((app) {
      if (app.id == applicationId) {
        return app.copyWith(
          status: 'Rejected',
          reviewedAt: now,
          rejectionReason: reason.trim().isEmpty ? 'Hồ sơ chưa đạt yêu cầu tiêu chuẩn nền tảng' : reason.trim(),
        );
      }
      return app;
    }).toList();

    state = state.copyWith(applications: updatedApps);
    _saveToLocal();
  }

  // --- Initial Mock Data ---
  static final List<AdminUserModel> _initialUsers = [
    AdminUserModel(
      id: '33333333-3333-3333-3333-333333333334',
      fullName: 'Hà Trung Thành',
      email: 'admin.ha@eventhub.vn',
      phoneNumber: '0988776655',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      role: 'Admin',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      bookingCount: 0,
      notes: 'Super Admin - Quản trị viên tối cao',
    ),
    AdminUserModel(
      id: '33333333-3333-3333-3333-333333333333',
      fullName: 'Quản trị viên Hệ thống',
      email: 'admin@eventhub.vn',
      phoneNumber: '0912345678',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      role: 'Admin',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      bookingCount: 0,
    ),
    AdminUserModel(
      id: '22222222-2222-2222-2222-222222222222',
      fullName: 'Vũ Thị Minh Anh',
      email: 'provider@eventhub.vn',
      phoneNumber: '0987654321',
      avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
      role: 'Provider',
      businessName: 'Ánh Dương Wedding & Decor',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      bookingCount: 38,
    ),
    AdminUserModel(
      id: '22222222-2222-2222-2222-222222222223',
      fullName: 'Trần Quang Huy',
      email: 'media.glow@eventhub.vn',
      phoneNumber: '0933112233',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      role: 'Provider',
      businessName: 'Glow Media & Studio',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      bookingCount: 26,
    ),
    AdminUserModel(
      id: '22222222-2222-2222-2222-222222222224',
      fullName: 'Nguyễn Tấn Đạt',
      email: 'sound.vibe@eventhub.vn',
      phoneNumber: '0911224466',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      role: 'Provider',
      businessName: 'Vibe Audio & Lighting Systems',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
      bookingCount: 19,
    ),
    AdminUserModel(
      id: '22222222-2222-2222-2222-222222222225',
      fullName: 'Phạm Hồng Phúc',
      email: 'catering.lotus@eventhub.vn',
      phoneNumber: '0944556677',
      avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
      role: 'Provider',
      businessName: 'Lotus Banquet & Event Catering',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      bookingCount: 15,
    ),
    AdminUserModel(
      id: '11111111-1111-1111-1111-111111111111',
      fullName: 'Khách hàng Demo',
      email: 'customer@eventhub.vn',
      phoneNumber: '0901234567',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      role: 'Customer',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 110)),
      bookingCount: 6,
    ),
    AdminUserModel(
      id: '11111111-1111-1111-1111-111111111112',
      fullName: 'Nguyễn Văn An',
      email: 'nguyen.van.an@gmail.com',
      phoneNumber: '0913579246',
      avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
      role: 'Customer',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      bookingCount: 3,
    ),
    AdminUserModel(
      id: '11111111-1111-1111-1111-111111111113',
      fullName: 'Trần Thị Mai',
      email: 'tran.thi.mai@gmail.com',
      phoneNumber: '0924681357',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      role: 'Customer',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      bookingCount: 2,
    ),
    AdminUserModel(
      id: '11111111-1111-1111-1111-111111111114',
      fullName: 'Lê Hoàng Nam',
      email: 'le.hoang.nam@gmail.com',
      phoneNumber: '0936912151',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      role: 'Customer',
      isActive: false, // Locked account for testing
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      bookingCount: 1,
      notes: 'Bị tạm khóa do hủy đơn liên tiếp không báo trước',
    ),
    AdminUserModel(
      id: '11111111-1111-1111-1111-111111111122',
      fullName: 'Công ty CP FPT Software',
      email: 'fpt.software@eventhub.vn',
      phoneNumber: '02473007300',
      avatarUrl: 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=150',
      role: 'Customer',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      bookingCount: 12,
      notes: 'Khách hàng Doanh nghiệp VIP',
    ),
  ];

  static final List<ProviderApplicationModel> _initialApplications = [
    ProviderApplicationModel(
      id: 'APP-2026-001',
      userId: '11111111-1111-1111-1111-111111111131',
      applicantName: 'Đỗ Quốc Cường',
      businessName: 'Royal Elegance Wedding Studio',
      email: 'cuong.royal@gmail.com',
      phoneNumber: '0983112244',
      category: 'Trang trí sự kiện & Hoa tươi',
      address: 'Số 88 Phố Huế, Q. Hai Bà Trưng',
      city: 'Hà Nội',
      experienceYears: 6,
      description: 'Chuyên thiết kế và thi công trang trí tiệc cưới phong cách Âu cổ điển, hoa tươi nhập khẩu 100%, kinh nghiệm tổ chức trên 200 sự kiện cao cấp tại các khách sạn 5 sao.',
      status: 'Pending',
      submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
      taxOrIdNumber: '0108992341',
      samplePhotos: [
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
      ],
    ),
    ProviderApplicationModel(
      id: 'APP-2026-002',
      userId: '11111111-1111-1111-1111-111111111132',
      applicantName: 'Lê Minh Quân',
      businessName: 'V-Sound Pro Stage & Lighting',
      email: 'quan.vsound@gmail.com',
      phoneNumber: '0908776655',
      category: 'Âm thanh & Ánh sáng sân khấu',
      address: '142 Nguyễn Thị Minh Khai, Phường 6, Quận 3',
      city: 'TP. Hồ Chí Minh',
      experienceYears: 8,
      description: 'Cung cấp hệ thống loa Line Array JBL, màn hình LED P3.91 trong nhà & ngoài trời, đèn Beam/Spot tiêu chuẩn quốc tế cho festival, countdown, hội nghị khách hàng quy mô 500 - 3000 khách.',
      status: 'Pending',
      submittedAt: DateTime.now().subtract(const Duration(hours: 14)),
      taxOrIdNumber: '0315667788',
      samplePhotos: [
        'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800',
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      ],
    ),
    ProviderApplicationModel(
      id: 'APP-2026-003',
      userId: '11111111-1111-1111-1111-111111111133',
      applicantName: 'Nguyễn Hữu Thắng',
      businessName: 'Chef Thắng - Tiệc VIP & Fine Dining',
      email: 'thang.chef@gmail.com',
      phoneNumber: '0918223344',
      category: 'Ẩm thực & Catering',
      address: '45 Võ Văn Tần, P. Mỹ An, Q. Ngũ Hành Sơn',
      city: 'Đà Nẵng',
      experienceYears: 10,
      description: 'Catering tiệc trà Teabreak cao cấp, tiệc Canape, Finger food, BBQ bãi biển và Set Menu Á - Âu tiêu chuẩn bếp trưởng khách sạn 5 sao. Cam kết VSATTP 100%.',
      status: 'Pending',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      taxOrIdNumber: '0401889922',
      samplePhotos: [
        'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
        'https://images.unsplash.com/photo-1543007630-9710e4a00a20?w=800',
      ],
    ),
    ProviderApplicationModel(
      id: 'APP-2026-004',
      userId: '11111111-1111-1111-1111-111111111134',
      applicantName: 'Bùi Anh Tuấn',
      businessName: 'Cinematic Vision Media & Flycam',
      email: 'tuan.cinematic@gmail.com',
      phoneNumber: '0977665544',
      category: 'Chụp ảnh & Quay phim',
      address: '25 Hoàng Cầu, Q. Đống Đa',
      city: 'Hà Nội',
      experienceYears: 5,
      description: 'Ekip quay phim phóng sự cưới chuyên nghiệp, sử dụng máy quay Sony FX3 / FX6 và Flycam DJI Mavic 3 Cine. Đội ngũ gồm 6 quay phim và 4 photographer chuyên môn cao.',
      status: 'Pending',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      taxOrIdNumber: '0109554433',
      samplePhotos: [
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
        'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800',
      ],
    ),
    ProviderApplicationModel(
      id: 'APP-2026-000',
      userId: '22222222-2222-2222-2222-222222222222',
      applicantName: 'Vũ Thị Minh Anh',
      businessName: 'Ánh Dương Wedding & Decor',
      email: 'provider@eventhub.vn',
      phoneNumber: '0987654321',
      category: 'Trang trí sự kiện',
      address: '15 Tố Hữu, Q. Thanh Xuân',
      city: 'Hà Nội',
      experienceYears: 7,
      description: 'Đã hoàn tất kiểm duyệt hồ sơ thành công.',
      status: 'Approved',
      submittedAt: DateTime.now().subtract(const Duration(days: 120)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 119)),
    ),
    ProviderApplicationModel(
      id: 'APP-2026-099',
      userId: '11111111-1111-1111-1111-111111111135',
      applicantName: 'Hoàng Văn Toàn',
      businessName: 'Dịch vụ Decor Giá Siêu Rẻ 24/7',
      email: 'toan.decor@gmail.com',
      phoneNumber: '0933998877',
      category: 'Trang trí sự kiện',
      address: 'Xã Tân Hội, Huyện Đan Phượng',
      city: 'Hà Nội',
      experienceYears: 1,
      description: 'Hồ sơ bị từ chối do không cung cấp hình ảnh sản phẩm thực tế và không có địa chỉ văn phòng đại diện rõ ràng.',
      status: 'Rejected',
      submittedAt: DateTime.now().subtract(const Duration(days: 15)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 14)),
      rejectionReason: 'Hồ sơ thiếu ảnh chụp thực tế dự án đã làm và chưa cung cấp số CCCD người đại diện pháp luật.',
    ),
  ];
}

