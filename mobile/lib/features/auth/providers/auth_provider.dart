import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../admin/providers/admin_provider.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isProvider => user?.isProvider ?? false;
  bool get isCustomer => user?.isCustomer ?? false;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(apiClient, ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  static const String _localPasswordsKey = 'eventhub_local_passwords_v1';
  final ApiClient _apiClient;
  final Ref _ref;

  AuthNotifier(this._apiClient, this._ref) : super(const AuthState()) {
    checkAuth();
  }

  /// Check stored credentials on app startup
  Future<void> checkAuth() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      if (token == 'demo-token-customer') {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          user: UserModel(
            id: 'demo-customer-id',
            fullName: 'Khách hàng Demo',
            email: 'customer@eventhub.vn',
            phoneNumber: '0901234567',
            role: 'Customer',
          ),
        );
        return;
      } else if (token == 'demo-token-provider') {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          user: UserModel(
            id: 'demo-provider-id',
            fullName: 'Ánh Dương Wedding & Decor',
            email: 'provider@eventhub.vn',
            phoneNumber: '0987654321',
            role: 'Provider',
            providerProfileId: 'demo-provider-profile-id',
          ),
        );
        return;
      }

      state = state.copyWith(status: AuthStatus.loading, token: token);
      final response = await _apiClient.dio.get(ApiConstants.me);

      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
        );
      } else {
        await TokenStorage.clear();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final userId = await TokenStorage.getUserId();
      final adminUsers = _ref.read(adminProvider).users;

      UserModel? matchedUser;
      for (final au in adminUsers) {
        if (au.id == userId) {
          if (!au.isActive) {
            await TokenStorage.clear();
            state = const AuthState(status: AuthStatus.unauthenticated);
            return;
          }
          matchedUser = UserModel(
            id: au.id,
            fullName: au.isProvider && (au.businessName?.isNotEmpty ?? false)
                ? au.businessName!
                : au.fullName,
            email: au.email,
            phoneNumber: au.phoneNumber,
            role: au.role,
            providerProfileId: au.isProvider ? au.id : null,
            providerApprovalStatus: au.isProvider ? 'Approved' : null,
          );
          break;
        }
      }

      if (matchedUser == null) {
        for (final u in _seedUsers.values) {
          if (u.id == userId) {
            matchedUser = u;
            break;
          }
        }
      }
      matchedUser ??= _seedUsers['customer@eventhub.vn'];

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        user: matchedUser,
      );
    }
  }

  static final Map<String, UserModel> _seedUsers = {
    'admin@eventhub.vn': UserModel(
      id: '33333333-3333-3333-3333-333333333333',
      fullName: 'Quản trị viên Hệ thống',
      email: 'admin@eventhub.vn',
      phoneNumber: '0912345678',
      role: 'Admin',
    ),
    'admin.ha@eventhub.vn': UserModel(
      id: '33333333-3333-3333-3333-333333333334',
      fullName: 'Hà Trung Thành (Super Admin)',
      email: 'admin.ha@eventhub.vn',
      phoneNumber: '0988776655',
      role: 'Admin',
    ),
    'support@eventhub.vn': UserModel(
      id: '33333333-3333-3333-3333-333333333335',
      fullName: 'Bộ phận Hỗ trợ EventHub',
      email: 'support@eventhub.vn',
      phoneNumber: '19006868',
      role: 'Admin',
    ),
    'customer@eventhub.vn': UserModel(
      id: '11111111-1111-1111-1111-111111111111',
      fullName: 'Khách hàng Demo',
      email: 'customer@eventhub.vn',
      phoneNumber: '0901234567',
      role: 'Customer',
    ),
    'provider@eventhub.vn': UserModel(
      id: '22222222-2222-2222-2222-222222222222',
      fullName: 'Ánh Dương Wedding & Decor',
      email: 'provider@eventhub.vn',
      phoneNumber: '0987654321',
      role: 'Provider',
      providerProfileId: '22222222-2222-2222-2222-222222222222',
      providerApprovalStatus: 'Approved',
    ),
    'media.glow@eventhub.vn': UserModel(
      id: '22222222-2222-2222-2222-222222222223',
      fullName: 'Glow Media & Studio',
      email: 'media.glow@eventhub.vn',
      phoneNumber: '0933112233',
      role: 'Provider',
      providerProfileId: '22222222-2222-2222-2222-222222222223',
      providerApprovalStatus: 'Approved',
    ),
    'sound.vibe@eventhub.vn': UserModel(
      id: '22222222-2222-2222-2222-222222222224',
      fullName: 'Vibe Audio & Lighting Systems',
      email: 'sound.vibe@eventhub.vn',
      phoneNumber: '0911224466',
      role: 'Provider',
      providerProfileId: '22222222-2222-2222-2222-222222222224',
      providerApprovalStatus: 'Approved',
    ),
    'catering.lotus@eventhub.vn': UserModel(
      id: '22222222-2222-2222-2222-222222222225',
      fullName: 'Lotus Banquet & Event Catering',
      email: 'catering.lotus@eventhub.vn',
      phoneNumber: '0944556677',
      role: 'Provider',
      providerProfileId: '22222222-2222-2222-2222-222222222225',
      providerApprovalStatus: 'Approved',
    ),
    'mc.minhtri@eventhub.vn': UserModel(
      id: '22222222-2222-2222-2222-222222222226',
      fullName: 'MC Minh Trí - MC Song Ngữ',
      email: 'mc.minhtri@eventhub.vn',
      phoneNumber: '0909988776',
      role: 'Provider',
      providerProfileId: '22222222-2222-2222-2222-222222222226',
      providerApprovalStatus: 'Approved',
    ),
    'flower.blossom@eventhub.vn': UserModel(
      id: '22222222-2222-2222-2222-222222222227',
      fullName: 'Blossom Floral & Design',
      email: 'flower.blossom@eventhub.vn',
      phoneNumber: '0977889900',
      role: 'Provider',
      providerProfileId: '22222222-2222-2222-2222-222222222227',
      providerApprovalStatus: 'Approved',
    ),
    'stage.pro@eventhub.vn': UserModel(
      id: '22222222-2222-2222-2222-222222222228',
      fullName: 'ProStage Event & Led Wall',
      email: 'stage.pro@eventhub.vn',
      phoneNumber: '0966554433',
      role: 'Provider',
      providerProfileId: '22222222-2222-2222-2222-222222222228',
      providerApprovalStatus: 'Approved',
    ),
    'nguyen.van.an@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111112',
      fullName: 'Nguyễn Văn An',
      email: 'nguyen.van.an@gmail.com',
      phoneNumber: '0913579246',
      role: 'Customer',
    ),
    'tran.thi.mai@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111113',
      fullName: 'Trần Thị Mai',
      email: 'tran.thi.mai@gmail.com',
      phoneNumber: '0924681357',
      role: 'Customer',
    ),
    'le.hoang.nam@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111114',
      fullName: 'Lê Hoàng Nam',
      email: 'le.hoang.nam@gmail.com',
      phoneNumber: '0936912151',
      role: 'Customer',
    ),
    'pham.quynh.nga@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111115',
      fullName: 'Phạm Quỳnh Nga',
      email: 'pham.quynh.nga@gmail.com',
      phoneNumber: '0948123789',
      role: 'Customer',
    ),
    'hoang.duc.thang@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111116',
      fullName: 'Hoàng Đức Thắng',
      email: 'hoang.duc.thang@gmail.com',
      phoneNumber: '0961234890',
      role: 'Customer',
    ),
    'vu.thu.trang@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111117',
      fullName: 'Vũ Thu Trang',
      email: 'vu.thu.trang@gmail.com',
      phoneNumber: '0973456123',
      role: 'Customer',
    ),
    'dang.tuan.kiet@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111118',
      fullName: 'Đặng Tuấn Kiệt',
      email: 'dang.tuan.kiet@gmail.com',
      phoneNumber: '0984567234',
      role: 'Customer',
    ),
    'bui.my.linh@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111119',
      fullName: 'Bùi Mỹ Linh',
      email: 'bui.my.linh@gmail.com',
      phoneNumber: '0915678345',
      role: 'Customer',
    ),
    'do.gia.huy@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111120',
      fullName: 'Đỗ Gia Huy',
      email: 'do.gia.huy@gmail.com',
      phoneNumber: '0926789456',
      role: 'Customer',
    ),
    'ngo.phuong.thao@gmail.com': UserModel(
      id: '11111111-1111-1111-1111-111111111121',
      fullName: 'Ngô Phương Thảo',
      email: 'ngo.phuong.thao@gmail.com',
      phoneNumber: '0937890567',
      role: 'Customer',
    ),
    'fpt.software@eventhub.vn': UserModel(
      id: '11111111-1111-1111-1111-111111111122',
      fullName: 'Công ty CP FPT Software',
      email: 'fpt.software@eventhub.vn',
      phoneNumber: '02473007300',
      role: 'Customer',
    ),
  };

  Future<Map<String, String>> _getLocalPasswords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localPasswordsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    return {};
  }

  Future<void> _saveLocalPassword(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await _getLocalPasswords();
      current[email.trim().toLowerCase()] = password;
      await prefs.setString(_localPasswordsKey, jsonEncode(current));
    } catch (_) {}
  }

  /// Login with email & password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final cleanEmail = email.trim().toLowerCase();

    // Kiểm tra trạng thái khóa / phân quyền mới nhất từ Admin
    final adminManagedUser = _ref.read(adminProvider.notifier).findUserByEmail(cleanEmail);
    if (adminManagedUser != null && !adminManagedUser.isActive) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Tài khoản này đã bị Quản trị viên tạm khóa. Vui lòng liên hệ bộ phận hỗ trợ.',
      );
      return false;
    }

    final localPasswords = await _getLocalPasswords();
    final savedPwd = localPasswords[cleanEmail];
    final isPasswordValid = (savedPwd != null && savedPwd == password) ||
        (savedPwd == null && (password == '1234567' || password == '12345' || password == 'Password123!'));

    // 1. Thử gửi request đăng nhập tới Backend API thực tế
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'email': cleanEmail, 'password': password},
      );

      final data = response.data;
      final token = data['token']?.toString() ?? 'token_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserModel.fromJson(data['user'] ?? data);

      await TokenStorage.saveUserSession(
        token: token,
        userId: user.id,
        role: user.role,
        providerProfileId: user.providerProfileId,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
      );
      return true;
    } catch (e) {
      // 2. Fallback: Đăng nhập từ Admin Users (đồng bộ role/khóa) hoặc Seed Users
      if (isPasswordValid && (adminManagedUser != null || _seedUsers.containsKey(cleanEmail))) {
        final seed = _seedUsers[cleanEmail];
        final effectiveRole = adminManagedUser?.role ?? seed!.role;
        final isProv = effectiveRole.toLowerCase() == 'provider';
        final effectiveId = adminManagedUser?.id ?? seed!.id;
        final effectiveName = isProv
            ? ((adminManagedUser?.businessName?.isNotEmpty == true)
                ? adminManagedUser!.businessName!
                : (seed?.fullName ?? adminManagedUser!.fullName))
            : (adminManagedUser?.fullName ?? seed!.fullName);

        final resolvedUser = UserModel(
          id: effectiveId,
          fullName: effectiveName,
          email: cleanEmail,
          phoneNumber: adminManagedUser?.phoneNumber ?? seed?.phoneNumber,
          role: effectiveRole,
          providerProfileId: isProv ? (seed?.providerProfileId ?? effectiveId) : null,
          providerApprovalStatus: isProv ? 'Approved' : null,
        );

        final token = 'token_${resolvedUser.id}';

        await TokenStorage.saveUserSession(
          token: token,
          userId: resolvedUser.id,
          role: resolvedUser.role,
          providerProfileId: resolvedUser.providerProfileId,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: resolvedUser,
          token: token,
        );
        return true;
      }

      final errorMsg = (adminManagedUser != null || _seedUsers.containsKey(cleanEmail))
          ? 'Email hoặc mật khẩu không chính xác.'
          : ApiClient.formatError(e);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMsg,
      );
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    required String role,
    String? businessName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final cleanEmail = email.trim().toLowerCase();

    final existingAdminUser = _ref.read(adminProvider.notifier).findUserByEmail(cleanEmail);
    if (existingAdminUser != null || _seedUsers.containsKey(cleanEmail)) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Email này đã được đăng ký trên hệ thống EventHub.',
      );
      return false;
    }

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'fullName': fullName.trim(),
          'email': cleanEmail,
          'password': password,
          'phoneNumber': phoneNumber?.trim(),
          'role': role,
          'businessName': businessName?.trim(),
        },
      );

      final data = response.data;
      final token = data['token']?.toString() ?? '';
      final user = UserModel.fromJson(data['user'] ?? data);

      await TokenStorage.saveUserSession(
        token: token,
        userId: user.id,
        role: user.role,
        providerProfileId: user.providerProfileId,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
      );
      return true;
    } catch (_) {
      // Offline / Local Registration Flow:
      // Nếu đăng ký làm Nhà cung cấp -> Tài khoản tạm thời là Customer & gửi Đơn xin NCC sang cho Admin duyệt!
      final newUserId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final wantsProvider = role.toLowerCase() == 'provider';
      final cleanName = fullName.trim();
      final cleanPhone = phoneNumber?.trim().isNotEmpty == true ? phoneNumber!.trim() : '0900000000';
      final cleanBiz = businessName?.trim().isNotEmpty == true ? businessName!.trim() : cleanName;

      await _saveLocalPassword(cleanEmail, password);

      _ref.read(adminProvider.notifier).registerLocalUser(
        id: newUserId,
        fullName: cleanName,
        email: cleanEmail,
        phoneNumber: cleanPhone,
        role: 'Customer',
        businessName: wantsProvider ? cleanBiz : null,
      );

      if (wantsProvider) {
        _ref.read(adminProvider.notifier).submitApplication(
          userId: newUserId,
          applicantName: cleanName,
          businessName: cleanBiz,
          email: cleanEmail,
          phoneNumber: cleanPhone,
          category: 'Trang trí sự kiện',
        );
      }

      final createdUser = UserModel(
        id: newUserId,
        fullName: cleanName,
        email: cleanEmail,
        phoneNumber: cleanPhone,
        role: 'Customer',
        providerApprovalStatus: wantsProvider ? 'Pending' : null,
      );
      final token = 'token_$newUserId';

      await TokenStorage.saveUserSession(
        token: token,
        userId: createdUser.id,
        role: createdUser.role,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: createdUser,
        token: token,
      );
      return true;
    }
  }

  /// Logout
  Future<void> logout() async {
    await TokenStorage.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
