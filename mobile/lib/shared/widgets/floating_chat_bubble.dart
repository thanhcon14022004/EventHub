import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/chat/providers/system_chat_provider.dart';

class FloatingChatBubble extends ConsumerStatefulWidget {
  final VoidCallback? onCustomTap;

  const FloatingChatBubble({super.key, this.onCustomTap});

  @override
  ConsumerState<FloatingChatBubble> createState() => _FloatingChatBubbleState();
}

class _FloatingChatBubbleState extends ConsumerState<FloatingChatBubble> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openLiveChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _LiveChatWebsiteModal(),
    );
  }

  void _showLoginRequiredSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 42,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Yêu cầu đăng nhập',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng đăng nhập tài khoản của bạn để trò chuyện trực tiếp cùng Đội ngũ CSKH hoặc Nhà cung cấp dịch vụ.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Đăng nhập ngay',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Để sau',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAuth = authState.isAuthenticated && user != null;
    final unreadCount = isAuth ? ref.watch(systemChatProvider).getUnreadForUser(user) : 0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!isAuth) {
            _showLoginRequiredSheet(context);
            return;
          }
          if (widget.onCustomTap != null) {
            widget.onCustomTap!();
          } else {
            _openLiveChatModal(context);
          }
        },
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4F46E5), // Electric Indigo
                Color(0xFF7C3AED), // Violet
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withOpacity(0.45),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Chat Speech Icon
              const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 28,
              ),

              // Unread Badge (Website Style Red Pill - dynamic from systemChatProvider)
              if (unreadCount > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

              // Online Green Pulse Dot
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveChatWebsiteModal extends ConsumerStatefulWidget {
  const _LiveChatWebsiteModal();

  @override
  ConsumerState<_LiveChatWebsiteModal> createState() => _LiveChatWebsiteModalState();
}

class _LiveChatWebsiteModalState extends ConsumerState<_LiveChatWebsiteModal> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _selectedConversation;
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': 'conv-provider-1',
      'name': 'Ánh Dương Wedding & Decor',
      'role': 'Nhà cung cấp',
      'avatarIcon': Icons.celebration_rounded,
      'avatarBg': const Color(0xFFEEF2FF),
      'avatarColor': const Color(0xFF4F46E5),
      'lastMsg': 'Dạ vâng, bên em đã ghi nhận yêu cầu hoa tone pastel của anh/chị rồi ạ!',
      'time': '10:45',
      'unread': 2,
      'online': true,
      'category': 'provider',
      'history': [
        {
          'isMe': false,
          'text': 'Chào bạn, cảm ơn bạn đã quan tâm đến dịch vụ trang trí tiệc cưới của Ánh Dương Decor!',
          'time': '10:30',
        },
        {
          'isMe': true,
          'text': 'Chào shop, mình muốn hỏi gói Rustic này có đổi hoa hồng phấn sang tone trắng kem được không?',
          'time': '10:32',
        },
        {
          'isMe': false,
          'text': 'Dạ hoàn toàn được bạn nhé! Tone trắng kem bên mình dùng hoa baby và lan hồ điệp rất sang trọng ạ.',
          'time': '10:35',
        },
        {
          'isMe': true,
          'text': 'Tuyệt vời, mình vừa gửi đơn đặt dịch vụ trên app cho ngày 24/10 tới đó ạ.',
          'time': '10:40',
        },
        {
          'isMe': false,
          'text': 'Dạ vâng, bên em đã ghi nhận yêu cầu hoa tone pastel của anh/chị rồi ạ!',
          'time': '10:45',
        },
      ],
    },
    {
      'id': 'conv-provider-2',
      'name': 'LensCraft Media Group',
      'role': 'Nhà cung cấp',
      'avatarIcon': Icons.videocam_rounded,
      'avatarBg': const Color(0xFFFDF4FF),
      'avatarColor': const Color(0xFFC026D3),
      'lastMsg': 'Ekip quay phim sẽ có mặt trước sự kiện 1 tiếng để set up máy móc nhé ạ.',
      'time': 'Hôm qua',
      'unread': 0,
      'online': true,
      'category': 'provider',
      'history': [
        {
          'isMe': false,
          'text': 'Chào bạn, ekip LensCraft Media Group đã sẵn sàng phục vụ sự kiện.',
          'time': 'Hôm qua 15:00',
        },
        {
          'isMe': false,
          'text': 'Ekip quay phim sẽ có mặt trước sự kiện 1 tiếng để set up máy móc nhé ạ.',
          'time': 'Hôm qua 15:30',
        },
      ],
    },
    {
      'id': 'conv-bot',
      'name': 'Trợ lý CSKH EventHub 24/7',
      'role': 'Hỗ trợ tự động',
      'avatarIcon': Icons.support_agent_rounded,
      'avatarBg': const Color(0xFFECFDF5),
      'avatarColor': const Color(0xFF059669),
      'lastMsg': 'Xin chào bạn 👋 EventHub Live Chat có thể hỗ trợ bạn điều gì hôm nay?',
      'time': 'Vừa xong',
      'unread': 0,
      'online': true,
      'category': 'support',
      'history': [
        {
          'isMe': false,
          'text': 'Xin chào bạn 👋 EventHub Live Chat có thể hỗ trợ bạn điều gì hôm nay?',
          'time': 'Vừa xong',
        },
      ],
    },
    {
      'id': 'conv-customer-1',
      'name': 'Trần Thị Thu Thảo',
      'role': 'Khách hàng',
      'avatarIcon': Icons.person_rounded,
      'avatarBg': const Color(0xFFFFFBEB),
      'avatarColor': const Color(0xFFD97706),
      'lastMsg': 'Chào bạn, gói tiệc buffet 150 người có kèm tráng miệng chè bưởi không?',
      'time': '14/10',
      'unread': 0,
      'online': false,
      'category': 'customer',
      'history': [
        {
          'isMe': false,
          'text': 'Chào bạn, gói tiệc buffet 150 người có kèm tráng miệng chè bưởi không?',
          'time': '14/10 09:12',
        },
      ],
    },
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredConversations {
    switch (_selectedFilter) {
      case 'unread':
        return _conversations.where((c) => (c['unread'] as int) > 0).toList();
      case 'provider':
        return _conversations.where((c) => c['category'] == 'provider').toList();
      case 'support':
        return _conversations.where((c) => c['category'] == 'support').toList();
      default:
        return _conversations;
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty || _selectedConversation == null) return;
    final msg = text.trim();
    setState(() {
      final history = _selectedConversation!['history'] as List<Map<String, dynamic>>;
      history.add({
        'isMe': true,
        'text': msg,
        'time': 'Bây giờ',
      });
      _selectedConversation!['lastMsg'] = msg;
      _selectedConversation!['time'] = 'Bây giờ';
      _msgController.clear();
    });

    _scrollToBottom();

    // Auto reply simulation after 1s
    final convId = _selectedConversation!['id'];
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _selectedConversation?['id'] != convId) return;
      setState(() {
        final history = _selectedConversation!['history'] as List<Map<String, dynamic>>;
        history.add({
          'isMe': false,
          'text': 'Cảm ơn bạn! Bên mình đã nhận được tin nhắn và sẽ phản hồi chi tiết ngay.',
          'time': 'Bây giờ',
        });
        _selectedConversation!['lastMsg'] = 'Cảm ơn bạn! Bên mình đã nhận được tin nhắn...';
      });
      _scrollToBottom();
    });
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      return Container(
        height: 380,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 42,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Yêu cầu đăng nhập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng đăng nhập tài khoản để xem tin nhắn và trò chuyện cùng Nhà cung cấp hoặc Quản trị viên.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text('Đăng nhập ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = (screenHeight * 0.70).clamp(420.0, 680.0) + (bottomInset > 0 ? bottomInset : 0);

    return Container(
      height: modalHeight,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 25,
            spreadRadius: 2,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: _selectedConversation == null
            ? _buildConversationListView()
            : _buildConversationChatView(),
      ),
    );
  }

  // 1. Danh sách tin nhắn (Default view inside small popup)
  Widget _buildConversationListView() {
    final totalUnread = _conversations.fold<int>(0, (sum, c) => sum + (c['unread'] as int));

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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
                    const Text(
                      'Hộp thư & Tin nhắn',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🟢 ${_conversations.length} cuộc hội thoại • $totalUnread tin mới',
                      style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Close button
              IconButton(
                tooltip: 'Đóng',
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Filter chips bar
        Container(
          color: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả (${_conversations.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Chưa đọc ($totalUnread)', 'unread'),
                const SizedBox(width: 8),
                _buildFilterChip('Nhà cung cấp', 'provider'),
                const SizedBox(width: 8),
                _buildFilterChip('Hỗ trợ CSKH', 'support'),
              ],
            ),
          ),
        ),

        // Conversation List
        Expanded(
          child: _filteredConversations.isEmpty
              ? const Center(
                  child: Text('Không có tin nhắn nào trong mục này', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _filteredConversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final conv = _filteredConversations[index];
                    final unread = conv['unread'] as int;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedConversation = conv;
                          conv['unread'] = 0;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar with online status
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: conv['avatarBg'] as Color,
                                  child: Icon(conv['avatarIcon'] as IconData, color: conv['avatarColor'] as Color, size: 24),
                                ),
                                if (conv['online'] == true)
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
                            const SizedBox(width: 12),
                            // Text details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conv['name'] as String,
                                          style: TextStyle(
                                            fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                                            fontSize: 14,
                                            color: const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        conv['time'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: unread > 0 ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                                          fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: (conv['avatarBg'] as Color).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          conv['role'] as String,
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: conv['avatarColor'] as Color),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          conv['lastMsg'] as String,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: unread > 0 ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      if (unread > 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$unread',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
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
                    );
                  },
                ),
        ),

        // Quick Bottom Action
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chạm vào liên hệ để mở chat nhanh',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/chat');
                },
                child: const Row(
                  children: [
                    Text('Toàn màn hình', style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.w700)),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF4F46E5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Khung trò chuyện chi tiết bên trong popup nhỏ
  Widget _buildConversationChatView() {
    final conv = _selectedConversation!;
    final history = conv['history'] as List<Map<String, dynamic>>;

    return Column(
      children: [
        // Header with Back button
        Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 10, 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Quay lại danh sách',
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                onPressed: () {
                  setState(() => _selectedConversation = null);
                },
              ),
              CircleAvatar(
                radius: 17,
                backgroundColor: conv['avatarBg'] as Color,
                child: Icon(conv['avatarIcon'] as IconData, color: conv['avatarColor'] as Color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conv['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '🟢 ${conv['online'] == true ? 'Đang hoạt động' : 'Ngoại tuyến'} • ${conv['role']}',
                      style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Mở toàn màn hình',
                icon: const Icon(Icons.open_in_full_rounded, color: Colors.white, size: 18),
                onPressed: () {
                  Navigator.pop(context);
                  if (conv['id'] == 'conv-bot') {
                    context.push('/chat/system');
                  } else {
                    context.push('/chat/${conv['id']}');
                  }
                },
              ),
              IconButton(
                tooltip: 'Đóng',
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Quick Prompt Chips
        Container(
          color: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPromptChip('💰 Báo giá trọn gói', () => _sendMessage('Mình muốn nhận báo giá trọn gói sự kiện.')),
                const SizedBox(width: 6),
                _buildPromptChip('📅 Kiểm tra ngày trống', () => _sendMessage('Shop cho mình hỏi ngày 24/10 tới còn nhận đơn không?')),
                const SizedBox(width: 6),
                _buildPromptChip('🌸 Tư vấn dịch vụ', () => _sendMessage('Tư vấn giúp mình các gói dịch vụ phù hợp nhất.')),
              ],
            ),
          ),
        ),

        // Messages History
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(14),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final m = history[index];
              final isMe = m['isMe'] == true;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['text'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: isMe ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        m['time'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Input Box
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tin nhắn trao đổi...',
                            hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _sendMessage(_msgController.text),
                borderRadius: BorderRadius.circular(21),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 19),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
      ),
    );
  }
}
