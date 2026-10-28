import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/admin_user_model.dart';
import '../providers/admin_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final adminNotifier = ref.read(adminProvider.notifier);
    final users = adminState.filteredUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý Người dùng',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            Text(
              'Kiểm soát tài khoản Khách hàng & Đối tác',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) => adminNotifier.searchUsers(val),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email, SĐT...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              adminNotifier.searchUsers('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Role Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildRoleFilterChip('All', 'Tất cả (${adminState.totalUsersCount})', adminState.userRoleFilter),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Customer', 'Khách hàng (${adminState.customersCount})', adminState.userRoleFilter),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Provider', 'Nhà cung cấp (${adminState.providersCount})', adminState.userRoleFilter),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Admin', 'Quản trị viên', adminState.userRoleFilter),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Status Filter Chips
                Row(
                  children: [
                    _buildStatusChip('All', 'Tất cả trạng thái', adminState.userStatusFilter),
                    const SizedBox(width: 8),
                    _buildStatusChip('Active', 'Đang hoạt động (${adminState.activeUsersCount})', adminState.userStatusFilter),
                    const SizedBox(width: 8),
                    _buildStatusChip('Inactive', 'Bị khóa (${adminState.lockedUsersCount})', adminState.userStatusFilter),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 2. User List
          Expanded(
            child: users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off_rounded, size: 56, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        const Text(
                          'Không tìm thấy người dùng phù hợp',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Thử thay đổi từ khóa hoặc bộ lọc trạng thái',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            adminNotifier.searchUsers('');
                            adminNotifier.filterUserRole('All');
                            adminNotifier.filterUserStatus('All');
                          },
                          child: const Text('Đặt lại bộ lọc'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    physics: const BouncingScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(context, ref, user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(String roleKey, String label, String currentRole) {
    final isSelected = currentRole.toLowerCase() == roleKey.toLowerCase();
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        color: isSelected ? Colors.white : const Color(0xFF475569),
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF6366F1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onSelected: (_) => ref.read(adminProvider.notifier).filterUserRole(roleKey),
    );
  }

  Widget _buildStatusChip(String statusKey, String label, String currentStatus) {
    final isSelected = currentStatus.toLowerCase() == statusKey.toLowerCase();
    return InkWell(
      onTap: () => ref.read(adminProvider.notifier).filterUserStatus(statusKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, AdminUserModel user) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(user.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isActive ? const Color(0xFFE2E8F0) : const Color(0xFFFECACA),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showUserDetailModal(context, ref, user),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: user.avatarUrl == null
                          ? Text(
                              user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
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
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
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
                          if (user.businessName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.businessName!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6366F1),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          if (user.phoneNumber != null)
                            Text(
                              'SĐT: ${user.phoneNumber}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(user.isActive),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tham gia: $formattedDate • ${user.bookingCount} đơn hàng',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _showUserDetailModal(context, ref, user),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Chi tiết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: Icon(
                            user.isActive ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                            size: 19,
                            color: user.isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                          onPressed: () => _confirmToggleStatus(context, ref, user),
                          tooltip: user.isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmToggleStatus(BuildContext context, WidgetRef ref, AdminUserModel user) {
    final willLock = user.isActive;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              willLock ? Icons.warning_rounded : Icons.verified_user_rounded,
              color: willLock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
            const SizedBox(width: 10),
            Text(willLock ? 'Tạm khóa tài khoản?' : 'Mở khóa tài khoản?'),
          ],
        ),
        content: Text(
          willLock
              ? 'Tài khoản "${user.fullName}" (${user.email}) sẽ không thể đăng nhập hoặc thực hiện giao dịch cho đến khi được mở khóa.'
              : 'Xác nhận mở khóa và khôi phục quyền truy cập cho tài khoản "${user.fullName}"?',
          style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
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
                  content: Text(
                    willLock ? 'Đã khóa tài khoản ${user.fullName}' : 'Đã mở khóa tài khoản ${user.fullName}',
                  ),
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
            child: Text(willLock ? 'Khóa tài khoản' : 'Mở khóa ngay'),
          ),
        ],
      ),
    );
  }

  void _showUserDetailModal(BuildContext context, WidgetRef ref, AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: user.avatarUrl == null
                      ? Text(user.fullName[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildRoleBadge(user.role),
                          const SizedBox(width: 8),
                          _buildStatusBadge(user.isActive),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildDetailRow('Mã định danh (ID):', user.id),
            _buildDetailRow('Email:', user.email),
            _buildDetailRow('Số điện thoại:', user.phoneNumber ?? 'Chưa cập nhật'),
            if (user.businessName != null) _buildDetailRow('Tên thương hiệu:', user.businessName!),
            _buildDetailRow('Ngày tham gia:', DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt)),
            _buildDetailRow('Số đơn giao dịch:', '${user.bookingCount} đơn'),
            if (user.notes != null) _buildDetailRow('Ghi chú Admin:', user.notes!),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      user.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(user.isActive ? 'Khóa tài khoản' : 'Mở khóa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user.isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      side: BorderSide(color: user.isActive ? const Color(0xFFFCA5A5) : const Color(0xFF6EE7B7)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmToggleStatus(context, ref, user);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
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

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 3,
            backgroundColor: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Hoạt động' : 'Đã khóa',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? const Color(0xFF047857) : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }
}

