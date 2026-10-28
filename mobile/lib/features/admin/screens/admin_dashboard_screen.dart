import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bookings/models/booking_model.dart';
import '../../bookings/providers/booking_provider.dart';
import '../../chat/providers/system_chat_provider.dart';
import '../../services/providers/product_approval_provider.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../models/admin_user_model.dart';
import '../models/provider_application_model.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final adminNotifier = ref.read(adminProvider.notifier);
    final currentAdmin = ref.watch(authProvider).user;
    final chatState = ref.watch(systemChatProvider);
    final productState = ref.watch(productApprovalProvider);
    final allBookings = ref.watch(bookingProvider);

    final pendingApplications = adminState.applications.where((a) => a.isPending).toList();
    final recentUsers = adminState.users.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Premium Admin App Bar & Hero Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            actions: [
              IconButton(
                tooltip: 'Hộp thư Hỗ trợ CSKH',
                icon: Badge(
                  isLabelVisible: chatState.totalUnreadByAdmin > 0,
                  label: Text(
                    '${chatState.totalUnreadByAdmin}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  child: const Icon(Icons.forum_rounded, color: Colors.white, size: 22),
                ),
                onPressed: () => context.push('/admin/support-chat'),
              ),
              const SizedBox(width: 6),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF31104B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF818CF8), width: 2),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          currentAdmin?.avatarUrl ??
                                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                                        ),
                                        onError: (_, __) {},
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentAdmin?.fullName ?? 'Hà Trung Thành',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6366F1).withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.4)),
                                          ),
                                          child: const Text(
                                            '🛡️ Quản trị viên',
                                            style: TextStyle(
                                              color: Color(0xFFC7D2FE),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // System health badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF10B981)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Online',
                                    style: TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'CỔNG QUẢN TRỊ TRUNG TÂM',
                          style: TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Giám sát Người dùng & Duyệt Đối tác',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Dashboard Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero EventHub Revenue Card via SePay VietQR (ACB)
                  _buildEventHubRevenueCard(allBookings),
                  const SizedBox(height: 16),

                  // 2. KPI Overview Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Đơn chờ duyệt',
                          value: '${adminState.pendingApplicationsCount}',
                          subtitle: 'Hồ sơ nhà cung cấp',
                          icon: Icons.pending_actions_rounded,
                          color: const Color(0xFFF59E0B),
                          bgGradient: const [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
                          onTap: () => context.go('/admin/applications'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Sản phẩm chờ duyệt',
                          value: '${productState.pendingCount}',
                          subtitle: 'Dịch vụ đối tác nộp',
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFFEA580C),
                          bgGradient: const [Color(0xFFFFEDD5), Color(0xFFFFF7ED)],
                          onTap: () => context.go('/admin/products'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Tổng Người dùng',
                          value: '${adminState.totalUsersCount}',
                          subtitle: '${adminState.customersCount} Khách • ${adminState.providersCount} NCC',
                          icon: Icons.group_rounded,
                          color: const Color(0xFF6366F1),
                          bgGradient: const [Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
                          onTap: () => context.go('/admin/users'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Tài khoản khóa',
                          value: '${adminState.lockedUsersCount}',
                          subtitle: 'Vi phạm quy định',
                          icon: Icons.lock_person_rounded,
                          color: const Color(0xFFEF4444),
                          bgGradient: const [Color(0xFFFEE2E2), Color(0xFFFEF2F2)],
                          onTap: () {
                            adminNotifier.filterUserStatus('Inactive');
                            context.go('/admin/users');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Quick Action Shortcuts Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Thao tác nhanh',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/admin/applications'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Xem tất cả đơn'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.checklist_rtl_rounded,
                          label: 'Duyệt đơn NCC',
                          badgeCount: adminState.pendingApplicationsCount,
                          color: const Color(0xFFD97706),
                          onTap: () => context.go('/admin/applications'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.manage_accounts_rounded,
                          label: 'Quản lý Users',
                          badgeCount: null,
                          color: const Color(0xFF4F46E5),
                          onTap: () => context.go('/admin/users'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.inventory_2_outlined,
                          label: 'Duyệt SP NCC',
                          badgeCount: productState.pendingCount > 0 ? productState.pendingCount : null,
                          color: const Color(0xFFEA580C),
                          onTap: () => context.go('/admin/products'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.support_agent_rounded,
                          label: 'Hộp thư CSKH',
                          badgeCount: chatState.totalUnreadByAdmin > 0 ? chatState.totalUnreadByAdmin : null,
                          color: const Color(0xFF2563EB),
                          onTap: () => context.push('/admin/support-chat'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Product Approval Highlight Card
                  _buildProductApprovalHighlightCard(context, ref, productState),

                  const SizedBox(height: 14),

                  // Support Chat Highlight Card
                  _buildSupportChatHighlightCard(context, ref, chatState),

                  const SizedBox(height: 28),

                  // 4. Section: Đơn xin làm NCC cần duyệt gấp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFD97706), size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Đơn xin làm NCC cần xử lý',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${pendingApplications.length} chờ duyệt',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (pendingApplications.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF10B981)),
                          const SizedBox(height: 8),
                          const Text(
                            'Đã xử lý hết hồ sơ!',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Hiện không có đơn xin làm nhà cung cấp nào đang chờ duyệt.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingApplications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final app = pendingApplications[index];
                        return _buildUrgentApplicationCard(context, ref, app);
                      },
                    ),

                  const SizedBox(height: 32),

                  // 5. Section: Người dùng mới tham gia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.people_outline_rounded, color: Color(0xFF6366F1), size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Người dùng hệ thống gần đây',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/admin/users'),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = recentUsers[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                              onBackgroundImageError: user.avatarUrl != null ? (_, __) {} : null,
                              backgroundColor: const Color(0xFFE0E7FF),
                              child: user.avatarUrl == null
                                  ? Text(
                                      user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                                    )
                                  : null,
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
                                          user.fullName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      _buildRoleBadge(user.role),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Quick lock/unlock toggle
                            IconButton(
                              tooltip: user.isActive ? 'Khóa tài khoản' : 'Mở khóa',
                              icon: Icon(
                                user.isActive ? Icons.lock_open_rounded : Icons.lock_rounded,
                                color: user.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                size: 20,
                              ),
                              onPressed: () {
                                _showToggleStatusDialog(context, ref, user);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SEPAY VIETQR EVENTHUB REVENUE CARD ---
  Widget _buildEventHubRevenueCard(List<BookingModel> allBookings) {
    final paidBookings = allBookings
        .where((b) => b.status == 'Confirmed' || b.status == 'Completed' || b.status == 'InProgress')
        .toList();
    final int totalGross = allBookings.isEmpty
        ? 27000000
        : paidBookings.fold<int>(0, (sum, b) => sum + b.rawPrice);
    final int paidCount = allBookings.isEmpty ? 2 : paidBookings.length;
    final int adminCommission = (totalGross * BookingModel.adminCommissionRate).round();
    final int providerPayout = totalGross - adminCommission;
    final int commissionPercent = (BookingModel.adminCommissionRate * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF064E3B),
            Color(0xFF047857),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag: Gateway and live status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_2_rounded, color: Color(0xFF6EE7B7), size: 14),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Cổng thanh toán SePay VietQR (ACB)',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Color(0xFF34D399)),
                      SizedBox(width: 5),
                      Text(
                        'Hoạt động ✓',
                        style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'TỔNG DOANH THU ĐƠN HÀNG EVENTHUB (SEPAY)',
              style: TextStyle(
                color: Color(0xFFA7F3D0),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    BookingModel.formatVnd(totalGross),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$paidCount đơn đã thanh toán',
                    style: const TextStyle(
                      color: Color(0xFFD1FAE5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withOpacity(0.12)),
            const SizedBox(height: 14),

            // Revenue Sub-metrics
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoa hồng nền tảng ($commissionPercent%)',
                        style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '+${BookingModel.formatVnd(adminCommission)}',
                        style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chi trả đối tác NCC',
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        BookingModel.formatVnd(providerPayout),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bank Account Info strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_rounded, color: Color(0xFF93C5FD), size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ACB • STK: 27655931',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    'HA TRUNG THANH',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE METRICS & ACTIONS ---
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> bgGradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: bgGradient),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int? badgeCount,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badgeCount != null && badgeCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductApprovalHighlightCard(
    BuildContext context,
    WidgetRef ref,
    ProductApprovalState productState,
  ) {
    final pendingCount = productState.pendingCount;
    final topProduct = productState.recentPending.isNotEmpty ? productState.recentPending.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pendingCount > 0 ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
          width: pendingCount > 0 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: pendingCount > 0 ? const Color(0xFFEA580C).withOpacity(0.06) : Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: pendingCount > 0 ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: pendingCount > 0 ? const Color(0xFFEA580C) : const Color(0xFF64748B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.inventory_2_rounded, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sản phẩm NCC cần phê duyệt',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Kiểm duyệt chất lượng trước khi niêm yết',
                              style: TextStyle(fontSize: 10.5, color: Colors.orange.shade800, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => context.push('/admin/products'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: pendingCount > 0 ? const Color(0xFFEA580C) : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pendingCount > 0 ? '$pendingCount chờ duyệt' : 'Đã duyệt hết',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Preview
          if (topProduct != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: EventNetworkImage(
                          imageUrl: topProduct.imageUrl,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    topProduct.category,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  topProduct.timeFormatted,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topProduct.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  topProduct.providerName,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  topProduct.price,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.push('/admin/products/${topProduct.id}'),
                      icon: const Icon(Icons.rate_review_rounded, size: 18),
                      label: const Text(
                        'Kiểm duyệt dịch vụ này ngay ➔',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Tất cả sản phẩm NCC đã được thẩm định xong!',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/admin/products'),
                    child: const Text('Xem kho hàng'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupportChatHighlightCard(
    BuildContext context,
    WidgetRef ref,
    SystemChatState chatState,
  ) {
    final waitingConvs = chatState.conversations.where((c) => c.status == 'waiting' || c.unreadByAdmin > 0).toList();
    final topConv = waitingConvs.isNotEmpty ? waitingConvs.first : (chatState.conversations.isNotEmpty ? chatState.conversations.first : null);
    final totalWaiting = chatState.totalWaitingConversations;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: totalWaiting > 0 ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0),
          width: totalWaiting > 0 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: totalWaiting > 0 ? const Color(0xFF4F46E5).withOpacity(0.06) : Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: totalWaiting > 0 ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: totalWaiting > 0 ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.forum_rounded, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hỗ trợ Hệ thống & CSKH',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Admin phản hồi trực tiếp người dùng',
                              style: TextStyle(fontSize: 10.5, color: Colors.indigo.shade600, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => context.push('/admin/support-chat'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: totalWaiting > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalWaiting > 0 ? '$totalWaiting cần xử lý' : 'Đã phản hồi',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content preview
          if (topConv != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: topConv.userRole == 'Customer' ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF),
                        child: Icon(
                          topConv.userRole == 'Customer' ? Icons.person_rounded : Icons.storefront_rounded,
                          color: topConv.userRole == 'Customer' ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
                          size: 16,
                        ),
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
                                    topConv.userName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: topConv.userRole == 'Customer' ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    topConv.userRole == 'Customer' ? 'Khách hàng' : 'Nhà cung cấp',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: topConv.userRole == 'Customer' ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              topConv.topic,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        topConv.timeFormatted,
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            topConv.lastMessage,
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.35),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ref.read(systemChatProvider.notifier).markAsReadByAdmin(topConv.id);
                        context.push('/admin/support-chat/${topConv.id}');
                      },
                      icon: const Icon(Icons.reply_rounded, size: 18),
                      label: const Text(
                        'Mở chat trả lời người dùng ngay ➔',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgentApplicationCard(
    BuildContext context,
    WidgetRef ref,
    ProviderApplicationModel app,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Color(0xFFD97706), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.businessName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Đại diện: ${app.applicantName} • ${app.city}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Chờ duyệt',
                    style: TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    app.category,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                  const Spacer(),
                  const Icon(Icons.work_history_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    '${app.experienceYears} năm kinh nghiệm',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, ref, app),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApproveDialog(context, ref, app),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Phê duyệt ngay', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, WidgetRef ref, ProviderApplicationModel app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 26),
            SizedBox(width: 10),
            Text('Duyệt hồ sơ NCC?'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn phê duyệt "${app.businessName}" thành Nhà cung cấp chính thức trên EventHub?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminProvider.notifier).approveApplication(app.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Đã phê duyệt đối tác "${app.businessName}" thành công!'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xác nhận duyệt'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, ProviderApplicationModel app) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 26),
            SizedBox(width: 10),
            Text('Từ chối hồ sơ?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Từ chối hồ sơ đăng ký của "${app.businessName}". Vui lòng nhập lý do:',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Thiếu giấy phép kinh doanh, ảnh hồ sơ không đạt chuẩn...',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminProvider.notifier).rejectApplication(app.id, reasonController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã từ chối hồ sơ của "${app.businessName}"'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Từ chối hồ sơ'),
          ),
        ],
      ),
    );
  }

  void _showToggleStatusDialog(BuildContext context, WidgetRef ref, AdminUserModel user) {
    final willLock = user.isActive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              willLock ? Icons.lock_person_rounded : Icons.lock_open_rounded,
              color: willLock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(willLock ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?'),
          ],
        ),
        content: Text(
          willLock
              ? 'Tài khoản của "${user.fullName}" sẽ tạm thời bị ngưng hoạt động trên hệ thống.'
              : 'Mở lại quyền truy cập cho tài khoản "${user.fullName}".',
          style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminProvider.notifier).toggleUserStatus(user.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(willLock ? 'Đã khóa tài khoản "${user.fullName}"' : 'Đã mở khóa tài khoản "${user.fullName}"'),
                  backgroundColor: willLock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: willLock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(willLock ? 'Xác nhận khóa' : 'Mở khóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bg = const Color(0xFFEEF2FF);
    Color text = const Color(0xFF4F46E5);
    String label = 'Khách hàng';

    if (role.toLowerCase() == 'provider') {
      bg = const Color(0xFFF5F3FF);
      text = const Color(0xFF7C3AED);
      label = 'Nhà cung cấp';
    } else if (role.toLowerCase() == 'admin') {
      bg = const Color(0xFFFEF2F2);
      text = const Color(0xFFDC2626);
      label = 'Admin';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
    );
  }
}
