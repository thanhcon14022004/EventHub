import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/system_chat_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFF090D16),
        body: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.forum_rounded, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Hộp Thư Trao Đổi Trực Tiếp',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Đăng nhập để nhận tư vấn báo giá, giải đáp thắc mắc dịch vụ và trao đổi chi tiết kế hoạch với đối tác.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
                      ),
                      const SizedBox(height: 28),

                      // Quick Demo Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'Trải nghiệm nhanh tính năng Chat:',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () async {
                                  await ref.read(authProvider.notifier).login('customer@eventhub.vn', '1234567');
                                },
                                icon: const Icon(Icons.person_rounded, size: 18, color: Colors.white),
                                label: const Text('Chat với tư cách Khách hàng', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () async {
                                  await ref.read(authProvider.notifier).login('provider@eventhub.vn', '1234567');
                                  if (context.mounted) context.go('/provider/chat');
                                },
                                icon: const Icon(Icons.storefront_rounded, size: 18, color: Color(0xFF4F46E5)),
                                label: const Text('Chat với tư cách Nhà cung cấp', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Hoặc đăng nhập tài khoản khác ➔', style: TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final chatState = ref.watch(systemChatProvider);
    final user = authState.user;
    final userSysConv = chatState.conversations.firstWhere(
      (c) => (user != null && (c.userId == user.id || c.userEmail == user.email)),
      orElse: () => chatState.conversations.first,
    );

    final chats = [
      {
        'id': 'system',
        'name': 'Ban Quản trị & Hỗ trợ EventHub',
        'role': 'Hệ thống / Admin',
        'lastMsg': userSysConv.lastMessage,
        'time': userSysConv.timeFormatted,
        'unread': userSysConv.unreadByUser,
        'avatarColor': const Color(0xFF4F46E5),
        'isSystem': true,
      },
      {
        'id': 'conv-provider-1',
        'name': 'Ánh Dương Wedding & Decor',
        'role': 'Nhà cung cấp',
        'lastMsg': 'Dạ vâng, bên em đã ghi nhận yêu cầu hoa tone pastel của anh/chị rồi ạ!',
        'time': '10:45',
        'unread': 2,
        'avatarColor': const Color(0xFF4F46E5),
      },
      {
        'id': 'conv-provider-2',
        'name': 'LensCraft Media Group',
        'role': 'Nhà cung cấp',
        'lastMsg': 'Ekip quay phim sẽ có mặt trước sự kiện 1 tiếng để set up máy móc nhé ạ.',
        'time': 'Hôm qua',
        'unread': 0,
        'avatarColor': const Color(0xFF0EA5E9),
      },
      {
        'id': 'conv-customer-1',
        'name': 'Trần Thị Thu Thảo',
        'role': 'Khách hàng',
        'lastMsg': 'Chào bạn, gói tiệc buffet 150 người có kèm tráng miệng chè bưởi không?',
        'time': '14/10',
        'unread': 0,
        'avatarColor': const Color(0xFFEC4899),
      },
      {
        'id': 'conv-provider-3',
        'name': 'Hanoi Grand Catering',
        'role': 'Nhà cung cấp',
        'lastMsg': 'Thực đơn 10 món tiệc cưới đã được gửi qua email cho anh/chị tham khảo rồi ạ.',
        'time': '12/10',
        'unread': 0,
        'avatarColor': const Color(0xFF10B981),
      },
    ];

    final filteredChats = chats.where((c) {
      final name = (c['name'] as String).toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => context.pop(),
              )
            : null,
        title: const Text(
          'Tin nhắn & Trao đổi',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Search Input Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm cuộc trò chuyện...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Chat items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                final unread = chat['unread'] as int;
                final avatarColor = chat['avatarColor'] as Color;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: unread > 0 ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0),
                      width: unread > 0 ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: unread > 0
                            ? const Color(0xFF4F46E5).withOpacity(0.06)
                            : Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        if (chat['isSystem'] == true) {
                          context.push('/chat/system');
                        } else {
                          context.push('/chat/${chat['id']}');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Avatar with Online dot
                            Stack(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: avatarColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: avatarColor.withOpacity(0.3), width: 1.5),
                                  ),
                                  child: Icon(
                                    chat['isSystem'] == true
                                        ? Icons.support_agent_rounded
                                        : (chat['role'] == 'Nhà cung cấp' ? Icons.storefront_rounded : Icons.person_rounded),
                                    color: avatarColor,
                                    size: 24,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),

                            // Main Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                chat['name'] as String,
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEEF2FF),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                chat['role'] as String,
                                                style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 9, fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        chat['time'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: unread > 0 ? AppColors.primary : AppColors.textMuted,
                                          fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          chat['lastMsg'] as String,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      if (unread > 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$unread',
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
