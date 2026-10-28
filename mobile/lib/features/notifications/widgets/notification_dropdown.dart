import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notification_provider.dart';

/// Hiển thị menu thông báo dạng popover trỏ ngay vào vị trí cái chuông
void showNotificationDropdown(BuildContext context) {
  final renderBox = context.findRenderObject() as RenderBox?;
  final offset = renderBox?.localToGlobal(Offset.zero);
  final size = renderBox?.size;
  final mediaQuery = MediaQuery.of(context);
  final screenWidth = mediaQuery.size.width;
  final statusBarHeight = mediaQuery.padding.top;

  // Tính toán tọa độ cái chuông
  final double bellCenterX = (offset != null && size != null)
      ? offset.dx + size.width / 2
      : screenWidth - 36;
  final double bellBottomY = (offset != null && size != null)
      ? offset.dy + size.height
      : statusBarHeight + 48;

  // Kích thước card dropdown nhỏ gọn
  final double cardWidth = (screenWidth - 20).clamp(320.0, 360.0);

  // Vị trí mép phải của card cách mép phải màn hình
  final double cardRightMargin = (offset != null && size != null)
      ? (screenWidth - (offset.dx + size.width)).clamp(10.0, 24.0)
      : 12.0;

  // Vị trí đỉnh card (ngay dưới cái chuông 6px)
  final double cardTop = bellBottomY + 7.0;

  // Khoảng cách từ mép phải của card tới mũi tên (để mũi tên trỏ chuẩn tâm chuông)
  final double cardRightEdgeGlobalX = screenWidth - cardRightMargin;
  final double arrowFromRight = (cardRightEdgeGlobalX - bellCenterX).clamp(18.0, cardWidth - 26.0);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'NotificationDropdown',
    barrierColor: Colors.black.withOpacity(0.25),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim1, anim2, child) {
      final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, -0.06),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: Stack(
            children: [
              Positioned(
                top: cardTop,
                right: cardRightMargin,
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Khung thông báo nhỏ gọn
                      Container(
                        width: cardWidth,
                        constraints: const BoxConstraints(
                          maxHeight: 450,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: const NotificationDropdownWidget(),
                        ),
                      ),

                      // Mũi tên tam giác trỏ ngược lên vị trí cái chuông
                      Positioned(
                        top: -7.5,
                        right: arrowFromRight - 7,
                        child: CustomPaint(
                          size: const Size(15, 8),
                          painter: _PopoverArrowPainter(
                            color: Colors.white,
                            borderColor: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Vẽ mũi tên nhọn trỏ lên cái chuông
class _PopoverArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _PopoverArrowPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Đổ màu tam giác nối liền với card
    final fillPath = Path()
      ..moveTo(0, size.height + 1)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height + 1)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Viền 2 cạnh trên của tam giác
    final strokePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height);

    final strokePaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NotificationDropdownWidget extends ConsumerStatefulWidget {
  const NotificationDropdownWidget({super.key});

  @override
  ConsumerState<NotificationDropdownWidget> createState() => _NotificationDropdownWidgetState();
}

class _NotificationDropdownWidgetState extends ConsumerState<NotificationDropdownWidget> {
  String _activeFilter = 'all';

  List<AppNotificationItem> _getFilteredNotifs(List<AppNotificationItem> all) {
    if (_activeFilter == 'unread') {
      return all.where((n) => !n.isRead).toList();
    }
    if (_activeFilter == 'order') {
      return all.where((n) => n.category == 'order' || n.category == 'payment').toList();
    }
    return all;
  }

  void _markAllAsRead() {
    ref.read(notificationProvider.notifier).markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Nếu chưa đăng nhập: Không hiển thị danh sách thông báo riêng tư mà yêu cầu đăng nhập
    if (!authState.isAuthenticated) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF4F46E5), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Yêu cầu đăng nhập',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng đăng nhập để xem thông báo đơn đặt và khuyến mãi dành riêng cho bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                label: const Text('Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
              ),
            ),
          ],
        ),
      );
    }

    final notifState = ref.watch(notificationProvider);
    final notifications = notifState.items;
    final unreadCount = notifState.unreadCount;
    final filteredNotifs = _getFilteredNotifs(notifications);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF4F46E5), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount mới',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
              const Spacer(),
              if (unreadCount > 0)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Đọc tất cả',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                  ),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Quick Filter Tabs
        Container(
          color: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('Tất cả (${notifications.length})', 'all'),
              const SizedBox(width: 6),
              _buildFilterChip('Chưa đọc ($unreadCount)', 'unread'),
              const SizedBox(width: 6),
              _buildFilterChip('Đơn hàng', 'order'),
            ],
          ),
        ),

        // Notifications List
        Flexible(
          child: filteredNotifs.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 36, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 8),
                      Text(
                        'Không có thông báo nào trong mục này',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: filteredNotifs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final notif = filteredNotifs[index];
                    final isRead = notif.isRead;

                    return InkWell(
                      onTap: () {
                        ref.read(notificationProvider.notifier).markAsRead(notif.id);
                      },
                      child: Container(
                        color: isRead ? Colors.transparent : const Color(0xFFF5F3FF).withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: notif.bg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(notif.icon, color: notif.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 7,
                                          height: 7,
                                          margin: const EdgeInsets.only(left: 6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF4F46E5),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    notif.body,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.time,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
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

        // Footer Action
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tự động đồng bộ thời gian thực',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/notifications');
                },
                child: const Row(
                  children: [
                    Text(
                      'Xem chi tiết',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                    ),
                    SizedBox(width: 3),
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

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _activeFilter == key;
    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
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
}
