import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../chat/models/system_chat_model.dart';
import '../../chat/providers/system_chat_provider.dart';

class AdminSupportChatScreen extends ConsumerStatefulWidget {
  const AdminSupportChatScreen({super.key});

  @override
  ConsumerState<AdminSupportChatScreen> createState() => _AdminSupportChatScreenState();
}

class _AdminSupportChatScreenState extends ConsumerState<AdminSupportChatScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(systemChatProvider);
    final chatNotifier = ref.read(systemChatProvider.notifier);
    final conversations = chatState.filteredConversations;
    final totalWaiting = chatState.totalWaitingConversations;
    final totalUnread = chatState.totalUnreadByAdmin;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hộp thư Hỗ trợ Hệ thống',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Trực tiếp phản hồi Khách hàng & Đối tác',
              style: TextStyle(fontSize: 12, color: Colors.indigo.shade600, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: totalWaiting > 0 ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: totalWaiting > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  totalWaiting > 0 ? Icons.mark_chat_unread_rounded : Icons.check_circle_rounded,
                  size: 15,
                  color: totalWaiting > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
                ),
                const SizedBox(width: 5),
                Text(
                  totalWaiting > 0 ? '$totalWaiting cần xử lý' : 'Đã phản hồi hết',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: totalWaiting > 0 ? const Color(0xFFB45309) : const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: chatNotifier.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên người dùng, email, số ĐT, tin nhắn...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            chatNotifier.setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // 2. Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab(
                    label: 'Tất cả (${chatState.conversations.length})',
                    value: 'all',
                    selectedValue: chatState.selectedFilter,
                    onTap: () => chatNotifier.setFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    label: 'Chờ trả lời ($totalUnread)',
                    value: 'unread',
                    badge: totalUnread > 0 ? '$totalUnread' : null,
                    badgeColor: const Color(0xFFEF4444),
                    selectedValue: chatState.selectedFilter,
                    onTap: () => chatNotifier.setFilter('unread'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    label: 'Khách hàng',
                    value: 'Customer',
                    selectedValue: chatState.selectedFilter,
                    onTap: () => chatNotifier.setFilter('Customer'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    label: 'Nhà cung cấp',
                    value: 'Provider',
                    selectedValue: chatState.selectedFilter,
                    onTap: () => chatNotifier.setFilter('Provider'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    label: 'Đã hoàn tất',
                    value: 'resolved',
                    selectedValue: chatState.selectedFilter,
                    onTap: () => chatNotifier.setFilter('resolved'),
                  ),
                ],
              ),
            ),
          ),

          Container(color: const Color(0xFFE2E8F0), height: 1),

          // 3. Conversation List
          Expanded(
            child: conversations.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      return _buildConversationCard(context, ref, conv);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = selectedValue == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : (badgeColor ?? const Color(0xFFEF4444)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConversationCard(BuildContext context, WidgetRef ref, SystemConversation conv) {
    final hasUnread = conv.unreadByAdmin > 0;
    final isCustomer = conv.userRole == 'Customer';
    final roleColor = isCustomer ? const Color(0xFF2563EB) : const Color(0xFF7C3AED);
    final roleBg = isCustomer ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasUnread ? const Color(0xFF818CF8) : const Color(0xFFE2E8F0),
          width: hasUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasUnread ? const Color(0xFF6366F1).withOpacity(0.08) : Colors.black.withOpacity(0.02),
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
            ref.read(systemChatProvider.notifier).markAsReadByAdmin(conv.id);
            context.push('/admin/support-chat/${conv.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Name + Role + Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: roleBg,
                          child: Icon(
                            isCustomer ? Icons.person_rounded : Icons.storefront_rounded,
                            color: roleColor,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: conv.status == 'waiting'
                                  ? const Color(0xFFF59E0B)
                                  : (conv.status == 'resolved' ? const Color(0xFF10B981) : const Color(0xFF3B82F6)),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  conv.userName,
                                  style: TextStyle(
                                    fontWeight: hasUnread ? FontWeight.w900 : FontWeight.w700,
                                    fontSize: 14.5,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: roleBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: roleColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  isCustomer ? 'Khách hàng' : 'Nhà cung cấp',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: roleColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${conv.userEmail} • ${conv.userPhone}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          conv.timeFormatted,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w500,
                            color: hasUnread ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusBadge(conv.status),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Topic Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.help_outline_rounded, size: 12, color: Color(0xFF475569)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          conv.topic,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Last Message Preview & Unread Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conv.lastMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
                          color: hasUnread ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    if (hasUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.reply_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${conv.unreadByAdmin} mới',
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'waiting':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        label = 'Chờ phản hồi';
        break;
      case 'resolved':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF047857);
        label = 'Đã xong';
        break;
      default:
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1E40AF);
        label = 'Đang xử lý';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: text),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, size: 48, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy hội thoại nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tất cả tin nhắn gửi lên hệ thống từ Khách hàng hoặc Nhà cung cấp sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

