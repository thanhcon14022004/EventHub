import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/system_chat_model.dart';
import '../providers/system_chat_provider.dart';

class UserSystemChatScreen extends ConsumerStatefulWidget {
  const UserSystemChatScreen({super.key});

  @override
  ConsumerState<UserSystemChatScreen> createState() => _UserSystemChatScreenState();
}

class _UserSystemChatScreenState extends ConsumerState<UserSystemChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _userQuickPrompts = [
    'Tư vấn quy trình đặt dịch vụ',
    'Chính sách bảo vệ & hoàn cọc',
    'Hỗ trợ thanh toán SePay VietQR',
    'Cần gặp trực tiếp Quản trị viên',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    final authState = ref.read(authProvider);
    final user = authState.user;

    final userId = user?.id ?? 'guest-user-id';
    final userName = user?.fullName ?? 'Khách hàng';
    final userRole = user?.isProvider == true ? 'Provider' : 'Customer';
    final userEmail = user?.email ?? 'guest@eventhub.vn';
    final userPhone = user?.phoneNumber ?? '0901234567';

    ref.read(systemChatProvider.notifier).sendMessageFromUser(
          userId: userId,
          userName: userName,
          userRole: userRole,
          text: text,
          userEmail: userEmail,
          userPhone: userPhone,
        );

    if (customText == null) {
      _messageController.clear();
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (!authState.isAuthenticated || user == null) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => context.pop(),
          ),
          title: const Text('CSKH & Hỗ trợ EventHub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 56,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Yêu cầu đăng nhập',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng đăng nhập để trao đổi tin nhắn trực tiếp với Đội ngũ CSKH và Quản trị viên EventHub.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text('Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chatState = ref.watch(systemChatProvider);

    // Find user's conversation with system
    final conv = chatState.conversations.firstWhere(
      (c) => (c.userId == user.id || c.userEmail == user.email),
      orElse: () {
        return SystemConversation(
          id: 'conv-${user.id}',
          userId: user.id,
          userName: user.fullName,
          userRole: user.isProvider ? 'Provider' : 'Customer',
          userEmail: user.email,
          userPhone: user.phoneNumber ?? '',
          updatedAt: DateTime.now(),
          lastMessage: 'Xin chào ${user.fullName}! Đội ngũ CSKH EventHub có thể hỗ trợ gì cho bạn hôm nay?',
          messages: [
            SystemChatMessage(
              id: 'welcome-${user.id}',
              senderId: 'system-agent',
              senderName: 'Trợ lý EventHub',
              senderRole: 'Admin',
              text: 'Xin chào ${user.fullName}! Đội ngũ CSKH EventHub có thể hỗ trợ gì cho bạn hôm nay?',
              createdAt: DateTime.now(),
              isFromAdmin: true,
            ),
          ],
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Ban Quản trị EventHub',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.verified_rounded, color: Color(0xFF6366F1), size: 15),
                    ],
                  ),
                  Text(
                    'Admin trực tuyến • Phản hồi tức thì',
                    style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Hotline CSKH',
            icon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hotline Ban Quản trị EventHub: 1900 6868 (Phím 1 gặp Admin)'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Trust Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF))),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF4F46E5)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kênh chat chính thức: Tin nhắn sẽ được Quản trị viên (Admin) trả lời trực tiếp.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF3730A3), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Message Feed
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: conv.messages.length,
              itemBuilder: (context, index) {
                final msg = conv.messages[index];
                // For user screen: isFromAdmin == false means isMe
                final isMe = !msg.isFromAdmin;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isMe
                            ? const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isMe ? null : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 18),
                        ),
                        border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: isMe
                                ? const Color(0xFF4F46E5).withOpacity(0.2)
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_rounded, size: 12, color: Color(0xFF6366F1)),
                                SizedBox(width: 4),
                                Text(
                                  'Quản trị viên Hệ thống',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                          ],
                          Text(
                            msg.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : const Color(0xFF0F172A),
                              fontSize: 13.5,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg.timeFormatted,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.done_all_rounded, size: 14, color: Colors.white70),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // User Quick Prompts Strip
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _userQuickPrompts.length,
              itemBuilder: (context, idx) {
                final prompt = _userQuickPrompts[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _sendMessage(prompt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Text(
                        prompt,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF4338CA)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(fontSize: 13.5),
                        decoration: const InputDecoration(
                          hintText: 'Nhắn tin đến Ban Quản trị EventHub...',
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

