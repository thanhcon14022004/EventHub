import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/providers/system_chat_provider.dart';

class AdminSupportChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const AdminSupportChatDetailScreen({super.key, required this.conversationId});

  @override
  ConsumerState<AdminSupportChatDetailScreen> createState() => _AdminSupportChatDetailScreenState();
}

class _AdminSupportChatDetailScreenState extends ConsumerState<AdminSupportChatDetailScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _adminQuickReplies = [
    'Dạ Ban Quản trị EventHub xin chào bạn!',
    'Bên mình đã tiếp nhận và đang xử lý yêu cầu.',
    'Yêu cầu của bạn đã được phê duyệt thành công!',
    'Bạn vui lòng kiểm tra lại đơn đặt hàng trên app nhé.',
    'Cảm ơn bạn đã liên hệ đội ngũ EventHub!',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(systemChatProvider.notifier).markAsReadByAdmin(widget.conversationId);
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

  void _sendReply([String? customText]) {
    final text = customText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    final currentAdmin = ref.read(authProvider).user;
    final adminName = currentAdmin?.fullName ?? 'Quản trị viên Hệ thống';

    ref.read(systemChatProvider.notifier).sendMessageFromAdmin(
          conversationId: widget.conversationId,
          text: text,
          adminName: adminName,
        );

    if (customText == null) {
      _messageController.clear();
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(systemChatProvider);
    final convIndex = chatState.conversations.indexWhere((c) => c.id == widget.conversationId);

    if (convIndex < 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết tin nhắn')),
        body: const Center(child: Text('Không tìm thấy cuộc trò chuyện')),
      );
    }

    final conv = chatState.conversations[convIndex];
    final isCustomer = conv.userRole == 'Customer';
    final roleColor = isCustomer ? const Color(0xFF2563EB) : const Color(0xFF7C3AED);
    final roleBg = isCustomer ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF);

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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: roleBg,
                  child: Icon(
                    isCustomer ? Icons.person_rounded : Icons.storefront_rounded,
                    color: roleColor,
                    size: 20,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          conv.userName,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: roleBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCustomer ? 'Khách' : 'NCC',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${conv.userPhone} • ${conv.userEmail}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Resolve / Toggle status button
          PopupMenuButton<String>(
            tooltip: 'Trạng thái xử lý',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF475569)),
            ),
            onSelected: (val) {
              ref.read(systemChatProvider.notifier).updateConversationStatus(conv.id, val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val == 'resolved' ? 'Đã đánh dấu hỗ trợ hoàn tất!' : 'Đã chuyển trạng thái xử lý'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'waiting',
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty_rounded, size: 18, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Text('Đánh dấu: Chờ phản hồi'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'in_progress',
                child: Row(
                  children: [
                    Icon(Icons.sync_rounded, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text('Đánh dấu: Đang xử lý'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'resolved',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Text('Đánh dấu: Đã giải quyết'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Info banner: Topic and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFEEF2FF),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chủ đề: ${conv.topic}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3730A3)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: conv.status == 'resolved'
                        ? const Color(0xFFD1FAE5)
                        : (conv.status == 'waiting' ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    conv.status == 'resolved' ? 'Đã xong' : (conv.status == 'waiting' ? 'Chờ xử lý' : 'Đang xử lý'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: conv.status == 'resolved'
                          ? const Color(0xFF047857)
                          : (conv.status == 'waiting' ? const Color(0xFFB45309) : const Color(0xFF1E40AF)),
                    ),
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
                final isFromAdmin = msg.isFromAdmin;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Align(
                    alignment: isFromAdmin ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isFromAdmin
                            ? const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isFromAdmin ? null : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isFromAdmin ? 18 : 4),
                          bottomRight: Radius.circular(isFromAdmin ? 4 : 18),
                        ),
                        border: isFromAdmin ? null : Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: isFromAdmin
                                ? const Color(0xFF4F46E5).withOpacity(0.2)
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isFromAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          // Sender Label
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isFromAdmin) ...[
                                const Icon(Icons.verified_user_rounded, size: 12, color: Color(0xFFC7D2FE)),
                                const SizedBox(width: 4),
                                const Text(
                                  'Quản trị viên (Hệ thống)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFE0E7FF),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  msg.senderName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: isFromAdmin ? Colors.white : const Color(0xFF0F172A),
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
                                  color: isFromAdmin ? Colors.white70 : const Color(0xFF94A3B8),
                                ),
                              ),
                              if (isFromAdmin) ...[
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

          // Admin Quick Replies Strip
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _adminQuickReplies.length,
              itemBuilder: (context, idx) {
                final reply = _adminQuickReplies[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _sendReply(reply),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          Text(
                            reply,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Box for Admin
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
                          hintText: 'Nhập câu trả lời từ Quản trị viên...',
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendReply(),
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
                      onPressed: () => _sendReply(),
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
