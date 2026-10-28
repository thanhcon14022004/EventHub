import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bookings/models/booking_model.dart';
import '../../bookings/providers/booking_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/widgets/notification_dropdown.dart';

class ProviderDashboardScreen extends ConsumerStatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  ConsumerState<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends ConsumerState<ProviderDashboardScreen> {
  bool _isReceivingOrders = true;

  void _handleBookingAction(String bookingId, String bookingCode, bool accept) {
    if (accept) {
      ref.read(bookingProvider.notifier).acceptProviderBooking(bookingId);
    } else {
      ref.read(bookingProvider.notifier).rejectProviderBooking(bookingId, 'Đã từ chối từ Kênh Nhà cung cấp');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          accept
              ? 'Đã duyệt đơn $bookingCode! Thông báo đã gửi tới khách hàng.'
              : 'Đã từ chối đơn $bookingCode.',
        ),
        backgroundColor: accept ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final unreadNotifCount = ref.watch(notificationProvider).unreadCount;
    final allBookings = ref.watch(bookingProvider);
    final urgentBookings = allBookings
        .where((b) => b.status == 'PendingProviderApproval' || b.status == 'Pending')
        .toList();
    final inProgressBookings = allBookings
        .where((b) => b.status == 'InProgress')
        .toList();

    // Doanh thu gộp cơ sở trong tháng (3 sự kiện) + các đơn mới đã thanh toán/đang diễn ra/hoàn thành
    const baseMonthlyGrossRevenue = 45000000;
    final completedOrdersGross = allBookings
        .where((b) => b.status == 'Confirmed' || b.status == 'Completed' || b.status == 'InProgress')
        .fold<int>(0, (sum, b) => sum + b.rawPrice);
    final netProviderRevenue =
        ((baseMonthlyGrossRevenue + completedOrdersGross) * (1 - BookingModel.adminCommissionRate)).round();
    final commissionPercent = (BookingModel.adminCommissionRate * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Kênh Nhà Cung Cấp'),
        actions: [
          Builder(
            builder: (btnCtx) => IconButton(
              tooltip: 'Thông báo',
              icon: Badge(
                isLabelVisible: unreadNotifCount > 0,
                label: Text('$unreadNotifCount'),
                child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22),
              ),
              onPressed: () => showNotificationDropdown(btnCtx),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12, left: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: const Size(0, 34),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppColors.primary, width: 1),
                ),
              ),
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: const Text('Xem Kênh Khách', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              onPressed: () => context.go('/'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Welcome Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E1B4B),
                    Color(0xFF31104B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E1B4B).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withOpacity(0.35),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 48,
                                    height: 48,
                                    color: AppColors.secondary,
                                    child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName.isNotEmpty == true ? user!.fullName : 'Ánh Dương Wedding & Decor',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF059669),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.verified_rounded, size: 11, color: Colors.white),
                                              SizedBox(width: 3),
                                              Flexible(
                                                child: Text(
                                                  'Đối tác VIP ✓',
                                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
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
                      GestureDetector(
                        onTap: () {
                          setState(() => _isReceivingOrders = !_isReceivingOrders);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isReceivingOrders ? 'Cửa hàng đã bật chế độ NHẬN ĐƠN MỚI' : 'Đã tạm dừng nhận đơn',
                              ),
                              backgroundColor: _isReceivingOrders ? const Color(0xFF059669) : AppColors.textSecondary,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isReceivingOrders ? const Color(0xFF10B981).withOpacity(0.2) : Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isReceivingOrders ? const Color(0xFF10B981) : Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isReceivingOrders ? const Color(0xFF34D399) : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                  boxShadow: _isReceivingOrders
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF34D399).withOpacity(0.6),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isReceivingOrders ? 'Nhận đơn' : 'Tạm nghỉ',
                                style: TextStyle(
                                  color: _isReceivingOrders ? const Color(0xFF34D399) : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Quick Actions Bar
            const Text(
              'Tác vụ quản lý nhanh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _buildQuickAction(
                  context,
                  title: 'Thêm dịch vụ',
                  icon: Icons.add_circle_outline_rounded,
                  color: AppColors.primary,
                  onTap: () => context.go('/provider/services'),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  title: 'Quản lý đơn',
                  icon: Icons.assignment_turned_in_outlined,
                  color: const Color(0xFF0284C7),
                  onTap: () => context.go('/provider/bookings'),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  title: 'Hộp thư chat',
                  icon: Icons.forum_outlined,
                  color: const Color(0xFF0D9488),
                  onTap: () => context.go('/provider/chat'),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  title: 'Kho dịch vụ',
                  icon: Icons.storefront_outlined,
                  color: const Color(0xFFEA580C),
                  onTap: () => context.go('/provider/services'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4 Metrics Cards
            const Text(
              'Hiệu quả kinh doanh tháng này',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildMetricCard(
                  title: 'Doanh thu thực nhận',
                  value: BookingModel.formatVnd(netProviderRevenue),
                  subtext: 'Đã trừ $commissionPercent% phí Admin',
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF4F46E5),
                  bg: const Color(0xFFEEF2FF),
                ),
                _buildMetricCard(
                  title: 'Đơn chờ duyệt',
                  value: '${urgentBookings.length} yêu cầu',
                  subtext: '⚡ Cần phản hồi ngay',
                  icon: Icons.hourglass_top_rounded,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFFBEB),
                ),
                _buildMetricCard(
                  title: 'Đang triển khai',
                  value: '${inProgressBookings.isNotEmpty ? inProgressBookings.length : 1} sự kiện',
                  subtext: 'Đang diễn ra & Setup',
                  icon: Icons.event_available_rounded,
                  color: const Color(0xFF6366F1),
                  bg: const Color(0xFFEEF2FF),
                ),
                _buildMetricCard(
                  title: 'Đánh giá tích cực',
                  value: '4.9 ★ (42)',
                  subtext: '98% khách hài lòng',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFE11D48),
                  bg: const Color(0xFFFFF1F2),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Urgent incoming requests preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notification_important_rounded, color: Color(0xFFD97706), size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Yêu cầu khách hàng cần duyệt',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/provider/bookings'),
                  child: const Text('Xem tất cả ➔', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (urgentBookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 42),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Bạn đã xử lý hết tất cả yêu cầu!',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Các đơn đặt mới sẽ xuất hiện tại đây khi khách hàng gửi yêu cầu.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(urgentBookings.length, (idx) {
                final b = urgentBookings[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.receipt_rounded, size: 12, color: Color(0xFF475569)),
                              ),
                              const SizedBox(width: 6),
                              Text(b.code, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(color: b.statusBg, borderRadius: BorderRadius.circular(8)),
                            child: Text(b.statusLabel, style: TextStyle(color: b.statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      Text('Khách hàng: ${b.customerName} • SĐT: ${b.customerPhone}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Dịch vụ: ${b.serviceTitle} • ${b.packageName}', style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Thời gian: ${b.date} (${b.time})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text('Địa điểm: ${b.location}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thực nhận (trừ $commissionPercent% phí)',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b.providerNetPrice,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(80, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                                  foregroundColor: AppColors.error,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _handleBookingAction(b.id, b.code, false),
                                child: const Text('Từ chối', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    minimumSize: const Size(96, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _handleBookingAction(b.id, b.code, true),
                                  child: const Text('Duyệt đơn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
          ),
          Text(subtext, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
