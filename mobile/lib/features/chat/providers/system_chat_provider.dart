import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/models/user_model.dart';
import '../models/system_chat_model.dart';

class SystemChatState {
  final List<SystemConversation> conversations;
  final String selectedFilter; // 'all', 'unread', 'Customer', 'Provider', 'resolved'
  final String searchQuery;

  const SystemChatState({
    required this.conversations,
    this.selectedFilter = 'all',
    this.searchQuery = '',
  });

  int get totalUnreadByAdmin {
    return conversations.fold<int>(0, (sum, c) => sum + c.unreadByAdmin);
  }

  int get totalWaitingConversations {
    return conversations.where((c) => c.status == 'waiting' || c.unreadByAdmin > 0).length;
  }

  int getUnreadForUser(UserModel? user) {
    if (user == null) return 0;
    if (user.isAdmin) return totalUnreadByAdmin;
    for (final c in conversations) {
      if (c.userId == user.id || c.userEmail.toLowerCase() == user.email.toLowerCase()) {
        return c.unreadByUser;
      }
    }
    return 0;
  }

  List<SystemConversation> get filteredConversations {
    return conversations.where((c) {
      // 1. Role / Status Filter
      if (selectedFilter == 'unread' && c.unreadByAdmin == 0) {
        return false;
      }
      if (selectedFilter == 'Customer' && c.userRole != 'Customer') {
        return false;
      }
      if (selectedFilter == 'Provider' && c.userRole != 'Provider') {
        return false;
      }
      if (selectedFilter == 'resolved' && c.status != 'resolved') {
        return false;
      }

      // 2. Search Query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchName = c.userName.toLowerCase().contains(q);
        final matchEmail = c.userEmail.toLowerCase().contains(q);
        final matchPhone = c.userPhone.contains(q);
        final matchMsg = c.lastMessage.toLowerCase().contains(q);
        final matchTopic = c.topic.toLowerCase().contains(q);
        if (!matchName && !matchEmail && !matchPhone && !matchMsg && !matchTopic) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  SystemChatState copyWith({
    List<SystemConversation>? conversations,
    String? selectedFilter,
    String? searchQuery,
  }) {
    return SystemChatState(
      conversations: conversations ?? this.conversations,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SystemChatNotifier extends StateNotifier<SystemChatState> {
  static const String _storageKey = 'eventhub_system_chats_v1';

  SystemChatNotifier()
      : super(
          SystemChatState(
            conversations: _seedConversations(),
          ),
        ) {
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final loaded = decoded
            .map((e) => SystemConversation.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        if (loaded.isNotEmpty) {
          state = state.copyWith(conversations: loaded);
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.conversations.map((c) => c.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  static List<SystemConversation> _seedConversations() {
    final now = DateTime.now();

    return [
      SystemConversation(
        id: 'sys-conv-customer-1',
        userId: '11111111-1111-1111-1111-111111111111',
        userName: 'Trần Thị Thu Thảo',
        userEmail: 'customer@eventhub.vn',
        userPhone: '0901234567',
        userRole: 'Customer',
        topic: 'Chính sách hoàn cọc & Dời ngày cưới',
        status: 'waiting',
        unreadByAdmin: 1,
        unreadByUser: 0,
        lastMessage: 'Dạ vâng may quá, em muốn dời từ ngày 24/10 sang 15/11 thì thủ tục trên app làm thế nào ạ?',
        updatedAt: now.subtract(const Duration(minutes: 5)),
        messages: [
          SystemChatMessage(
            id: 'm-1-1',
            senderId: '11111111-1111-1111-1111-111111111111',
            senderName: 'Trần Thị Thu Thảo',
            senderRole: 'Customer',
            isFromAdmin: false,
            text: 'Chào Ban Quản trị EventHub, mình cần hỗ trợ về chính sách dời ngày tổ chức sự kiện cưới khi có việc đột xuất ạ.',
            createdAt: now.subtract(const Duration(minutes: 25)),
          ),
          SystemChatMessage(
            id: 'm-1-2',
            senderId: 'admin-system',
            senderName: 'Ban Quản trị EventHub',
            senderRole: 'Admin',
            isFromAdmin: true,
            text: 'Chào bạn Thu Thảo! Theo điều khoản bảo vệ khách hàng của EventHub, bạn được hỗ trợ dời lịch miễn phí trước 14 ngày diễn ra sự kiện. Ban quản trị sẽ bảo lưu cọc và kết nối đối tác điều chỉnh lịch cho bạn.',
            createdAt: now.subtract(const Duration(minutes: 15)),
          ),
          SystemChatMessage(
            id: 'm-1-3',
            senderId: '11111111-1111-1111-1111-111111111111',
            senderName: 'Trần Thị Thu Thảo',
            senderRole: 'Customer',
            isFromAdmin: false,
            text: 'Dạ vâng may quá, em muốn dời từ ngày 24/10 sang 15/11 thì thủ tục trên app làm thế nào ạ?',
            createdAt: now.subtract(const Duration(minutes: 5)),
          ),
        ],
      ),
      SystemConversation(
        id: 'sys-conv-provider-1',
        userId: 'demo-provider-id',
        userName: 'Vũ Thị Minh Anh (Ánh Dương Wedding & Decor)',
        userEmail: 'provider@eventhub.vn',
        userPhone: '0987654321',
        userRole: 'Provider',
        topic: 'Duyệt bảng giá gói hoa tươi mùa cưới',
        status: 'waiting',
        unreadByAdmin: 1,
        unreadByUser: 0,
        lastMessage: 'Kính gửi Admin, bên em vừa cập nhật bảng giá gói hoa tươi tháng 11, nhờ admin duyệt giúp gian hàng ạ.',
        updatedAt: now.subtract(const Duration(minutes: 42)),
        messages: [
          SystemChatMessage(
            id: 'm-2-1',
            senderId: 'demo-provider-id',
            senderName: 'Vũ Thị Minh Anh',
            senderRole: 'Provider',
            isFromAdmin: false,
            text: 'Kính gửi Admin, bên em vừa cập nhật bảng giá gói hoa tươi tháng 11, nhờ admin duyệt giúp gian hàng ạ.',
            createdAt: now.subtract(const Duration(minutes: 42)),
          ),
        ],
      ),
      SystemConversation(
        id: 'sys-conv-customer-2',
        userId: '22222222-2222-2222-2222-222222222222',
        userName: 'Lê Minh Cường',
        userEmail: 'cuong.le@gmail.com',
        userPhone: '0934567890',
        userRole: 'Customer',
        topic: 'Xuất hóa đơn VAT qua SePay VietQR',
        status: 'resolved',
        unreadByAdmin: 0,
        unreadByUser: 0,
        lastMessage: 'Cảm ơn Admin nhiều nhé, dịch vụ rất nhanh chóng và chuyên nghiệp!',
        updatedAt: now.subtract(const Duration(hours: 3)),
        messages: [
          SystemChatMessage(
            id: 'm-3-1',
            senderId: '22222222-2222-2222-2222-222222222222',
            senderName: 'Lê Minh Cường',
            senderRole: 'Customer',
            isFromAdmin: false,
            text: 'Admin cho mình hỏi thanh toán chuyển khoản SePay VietQR quét mã ACB có nhận được hoá đơn đỏ công ty không?',
            createdAt: now.subtract(const Duration(hours: 3, minutes: 20)),
          ),
          SystemChatMessage(
            id: 'm-3-2',
            senderId: 'admin-system',
            senderName: 'Ban Quản trị EventHub',
            senderRole: 'Admin',
            isFromAdmin: true,
            text: 'Chào anh Cường, hệ thống SePay tự động ghi nhận thanh toán. Bộ phận kế toán EventHub sẽ xuất hóa đơn điện tử VAT gửi qua email cho anh trong vòng 24 giờ làm việc nhé ạ.',
            createdAt: now.subtract(const Duration(hours: 3, minutes: 10)),
          ),
          SystemChatMessage(
            id: 'm-3-3',
            senderId: '22222222-2222-2222-2222-222222222222',
            senderName: 'Lê Minh Cường',
            senderRole: 'Customer',
            isFromAdmin: false,
            text: 'Cảm ơn Admin nhiều nhé, dịch vụ rất nhanh chóng và chuyên nghiệp!',
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
        ],
      ),
      SystemConversation(
        id: 'sys-conv-provider-2',
        userId: 'demo-provider-2',
        userName: 'LensCraft Media Group',
        userEmail: 'contact@lenscraft.vn',
        userPhone: '0918889999',
        userRole: 'Provider',
        topic: 'Đăng ký huy hiệu Đối tác Đã xác minh VIP',
        status: 'in_progress',
        unreadByAdmin: 0,
        unreadByUser: 0,
        lastMessage: 'Admin đã bàn giao hồ sơ cho bộ phận thanh tra, kết quả thẩm định sẽ có trong 48h.',
        updatedAt: now.subtract(const Duration(hours: 6)),
        messages: [
          SystemChatMessage(
            id: 'm-4-1',
            senderId: 'demo-provider-2',
            senderName: 'LensCraft Media Group',
            senderRole: 'Provider',
            isFromAdmin: false,
            text: 'Bên mình muốn hoàn tất hồ sơ cấp huy hiệu Đối tác Đã xác minh thì liên hệ chuyên viên nào ạ?',
            createdAt: now.subtract(const Duration(hours: 6, minutes: 30)),
          ),
          SystemChatMessage(
            id: 'm-4-2',
            senderId: 'admin-system',
            senderName: 'Ban Quản trị EventHub',
            senderRole: 'Admin',
            isFromAdmin: true,
            text: 'Admin đã tiếp nhận và bàn giao hồ sơ cho bộ phận thanh tra, kết quả thẩm định sẽ có trong 48h làm việc nhé!',
            createdAt: now.subtract(const Duration(hours: 6)),
          ),
        ],
      ),
    ];
  }

  /// User sends a message to the System / Admin
  void sendMessageFromUser({
    required String userId,
    required String userName,
    required String userRole,
    required String text,
    String? userEmail,
    String? userPhone,
    String? topic,
  }) {
    if (text.trim().isEmpty) return;

    final trimmedText = text.trim();
    final now = DateTime.now();
    final newMsg = SystemChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: userId,
      senderName: userName,
      senderRole: userRole,
      isFromAdmin: false,
      text: trimmedText,
      createdAt: now,
    );

    final existingIndex = state.conversations.indexWhere(
      (c) => c.userId == userId || (userEmail != null && c.userEmail == userEmail),
    );

    List<SystemConversation> updatedList = List.from(state.conversations);

    if (existingIndex >= 0) {
      final old = updatedList[existingIndex];
      final updatedConv = old.copyWith(
        messages: [...old.messages, newMsg],
        lastMessage: trimmedText,
        updatedAt: now,
        unreadByAdmin: old.unreadByAdmin + 1,
        status: 'waiting',
      );
      updatedList.removeAt(existingIndex);
      updatedList.insert(0, updatedConv);
    } else {
      final newConv = SystemConversation(
        id: 'sys-conv-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        userEmail: userEmail ?? 'user@eventhub.vn',
        userPhone: userPhone ?? '0900000000',
        userRole: userRole,
        topic: topic ?? 'Hỗ trợ dịch vụ & Khiếu nại',
        status: 'waiting',
        unreadByAdmin: 1,
        unreadByUser: 0,
        lastMessage: trimmedText,
        updatedAt: now,
        messages: [newMsg],
      );
      updatedList.insert(0, newConv);
    }

    state = state.copyWith(conversations: updatedList);
    _saveToLocal();
  }

  /// Admin replies to a user conversation
  void sendMessageFromAdmin({
    required String conversationId,
    required String text,
    String adminName = 'Quản trị viên Hệ thống',
  }) {
    if (text.trim().isEmpty) return;

    final trimmedText = text.trim();
    final now = DateTime.now();

    final targetIndex = state.conversations.indexWhere((c) => c.id == conversationId);
    if (targetIndex < 0) return;

    final old = state.conversations[targetIndex];
    final newMsg = SystemChatMessage(
      id: 'msg-admin-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'admin-sys',
      senderName: adminName,
      senderRole: 'Admin',
      isFromAdmin: true,
      text: trimmedText,
      createdAt: now,
    );

    final updatedConv = old.copyWith(
      messages: [...old.messages, newMsg],
      lastMessage: trimmedText,
      updatedAt: now,
      unreadByAdmin: 0, // Admin answered, clear unread
      unreadByUser: old.unreadByUser + 1,
      status: 'in_progress',
    );

    List<SystemConversation> updatedList = List.from(state.conversations);
    updatedList.removeAt(targetIndex);
    updatedList.insert(0, updatedConv);

    state = state.copyWith(conversations: updatedList);
    _saveToLocal();
  }

  /// Mark conversation as read by admin
  void markAsReadByAdmin(String conversationId) {
    final targetIndex = state.conversations.indexWhere((c) => c.id == conversationId);
    if (targetIndex < 0) return;

    final old = state.conversations[targetIndex];
    if (old.unreadByAdmin == 0) return;

    final updatedConv = old.copyWith(unreadByAdmin: 0);
    List<SystemConversation> updatedList = List.from(state.conversations);
    updatedList[targetIndex] = updatedConv;
    state = state.copyWith(conversations: updatedList);
    _saveToLocal();
  }

  /// Mark conversation as read by user
  void markAsReadByUser(String conversationId) {
    final targetIndex = state.conversations.indexWhere((c) => c.id == conversationId);
    if (targetIndex < 0) return;

    final old = state.conversations[targetIndex];
    if (old.unreadByUser == 0) return;

    final updatedConv = old.copyWith(unreadByUser: 0);
    List<SystemConversation> updatedList = List.from(state.conversations);
    updatedList[targetIndex] = updatedConv;
    state = state.copyWith(conversations: updatedList);
    _saveToLocal();
  }

  /// Change conversation status
  void updateConversationStatus(String conversationId, String newStatus) {
    final targetIndex = state.conversations.indexWhere((c) => c.id == conversationId);
    if (targetIndex < 0) return;

    final old = state.conversations[targetIndex];
    final updatedConv = old.copyWith(status: newStatus);
    List<SystemConversation> updatedList = List.from(state.conversations);
    updatedList[targetIndex] = updatedConv;
    state = state.copyWith(conversations: updatedList);
    _saveToLocal();
  }

  /// Filter & search
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Get or create conversation for the logged in user
  SystemConversation getOrCreateUserConversation(UserModel user) {
    final match = state.conversations.firstWhere(
      (c) => c.userId == user.id || c.userEmail == user.email,
      orElse: () {
        final now = DateTime.now();
        final welcomeMsg = SystemChatMessage(
          id: 'welcome-${user.id}',
          senderId: 'admin-sys',
          senderName: 'Ban Quản trị EventHub',
          senderRole: 'Admin',
          isFromAdmin: true,
          text: 'Xin chào ${user.fullName}! Ban Quản trị EventHub sẵn sàng hỗ trợ bạn 24/7. Hãy nhắn tin bất kỳ câu hỏi nào về dịch vụ, đơn hàng hay chính sách nhé.',
          createdAt: now,
        );

        final newConv = SystemConversation(
          id: 'sys-conv-${user.id}',
          userId: user.id,
          userName: user.fullName,
          userEmail: user.email,
          userPhone: user.phoneNumber ?? '0901234567',
          userRole: user.isProvider ? 'Provider' : 'Customer',
          topic: 'Hỗ trợ tài khoản & Dịch vụ',
          status: 'in_progress',
          unreadByAdmin: 0,
          unreadByUser: 1,
          lastMessage: welcomeMsg.text,
          updatedAt: now,
          messages: [welcomeMsg],
        );

        state = state.copyWith(conversations: [newConv, ...state.conversations]);
        return newConv;
      },
    );
    return match;
  }
}

final systemChatProvider = StateNotifierProvider<SystemChatNotifier, SystemChatState>((ref) {
  return SystemChatNotifier();
});

