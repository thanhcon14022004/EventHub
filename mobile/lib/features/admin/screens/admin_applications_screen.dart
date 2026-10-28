import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/provider_application_model.dart';
import '../providers/admin_provider.dart';

class AdminApplicationsScreen extends ConsumerStatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  ConsumerState<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends ConsumerState<AdminApplicationsScreen> {
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
    final applications = adminState.filteredApplications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đơn xin làm Nhà cung cấp',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            Text(
              'Kiểm duyệt và cấp quyền hoạt động gian hàng',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. Search Bar & Status Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => adminNotifier.searchApplications(val),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo thương hiệu, người đại diện, ngành nghề...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFF59E0B), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              adminNotifier.searchApplications('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildStatusTab(
                        'All',
                        'Tất cả (${adminState.totalApplicationsCount})',
                        adminState.appStatusFilter,
                        null,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusTab(
                        'Pending',
                        'Chờ duyệt',
                        adminState.appStatusFilter,
                        adminState.pendingApplicationsCount,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusTab(
                        'Approved',
                        'Đã duyệt (${adminState.approvedApplicationsCount})',
                        adminState.appStatusFilter,
                        null,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusTab(
                        'Rejected',
                        'Từ chối (${adminState.rejectedApplicationsCount})',
                        adminState.appStatusFilter,
                        null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 2. Application List
          Expanded(
            child: applications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 54, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        const Text(
                          'Không có đơn đăng ký nào',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    physics: const BouncingScrollPhysics(),
                    itemCount: applications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = applications[index];
                      return _buildApplicationCard(context, ref, app);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String statusKey, String label, String currentStatus, int? badgeCount) {
    final isSelected = currentStatus.toLowerCase() == statusKey.toLowerCase();
    Color activeColor = const Color(0xFF0F172A);
    if (statusKey == 'Pending') activeColor = const Color(0xFFD97706);
    if (statusKey == 'Approved') activeColor = const Color(0xFF10B981);
    if (statusKey == 'Rejected') activeColor = const Color(0xFFEF4444);

    return InkWell(
      onTap: () => ref.read(adminProvider.notifier).filterApplicationStatus(statusKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
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
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? activeColor : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, WidgetRef ref, ProviderApplicationModel app) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(app.submittedAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: app.isPending
              ? const Color(0xFFFDE68A)
              : app.isApproved
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFFECACA),
        ),
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
          onTap: () => _showApplicationDetailModal(context, ref, app),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: app.isPending
                            ? const Color(0xFFFEF3C7)
                            : app.isApproved
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        app.isApproved
                            ? Icons.verified_rounded
                            : app.isRejected
                                ? Icons.cancel_rounded
                                : Icons.store_rounded,
                        color: app.isPending
                            ? const Color(0xFFD97706)
                            : app.isApproved
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.businessName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Đại diện: ${app.applicantName} • ${app.city}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SĐT: ${app.phoneNumber} • Email: ${app.email}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(app.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Category & Experience Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, size: 15, color: Color(0xFF6366F1)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          app.category,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${app.experienceYears} năm kinh nghiệm',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  app.description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (app.isRejected && app.rejectionReason != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lý do từ chối: ${app.rejectionReason}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gửi lúc: $formattedDate',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                    if (app.isPending)
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => _showRejectDialog(context, ref, app),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Từ chối', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showApproveDialog(context, ref, app),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Phê duyệt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      )
                    else
                      TextButton(
                        onPressed: () => _showApplicationDetailModal(context, ref, app),
                        child: const Text('Xem hồ sơ chi tiết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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

  void _showApplicationDetailModal(BuildContext context, WidgetRef ref, ProviderApplicationModel app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      app.businessName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ),
                  _buildStatusBadge(app.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Mã hồ sơ: ${app.id}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),

              const Text(
                'THÔNG TIN DOANH NGHIỆP / ĐẠI DIỆN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6366F1), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              _buildDetailItem('Người đại diện:', app.applicantName),
              _buildDetailItem('Số điện thoại:', app.phoneNumber),
              _buildDetailItem('Email liên hệ:', app.email),
              if (app.taxOrIdNumber != null) _buildDetailItem('Mã số thuế / CCCD:', app.taxOrIdNumber!),
              _buildDetailItem('Lĩnh vực đăng ký:', app.category),
              _buildDetailItem('Kinh nghiệm:', '${app.experienceYears} năm trong ngành sự kiện'),
              _buildDetailItem('Địa chỉ trụ sở:', '${app.address}, ${app.city}'),
              _buildDetailItem('Thời gian nộp đơn:', DateFormat('dd/MM/yyyy HH:mm:ss').format(app.submittedAt)),

              const SizedBox(height: 16),
              const Text(
                'HỒ SƠ NĂNG LỰC & GIỚI THIỆU',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6366F1), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  app.description,
                  style: const TextStyle(fontSize: 13, height: 1.45, color: Color(0xFF334155)),
                ),
              ),

              if (app.samplePhotos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'HÌNH ẢNH DỰ ÁN THỰC TẾ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6366F1), letterSpacing: 0.5),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: app.samplePhotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        app.samplePhotos[idx],
                        width: 140,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              if (app.isPending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showRejectDialog(context, ref, app);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Từ chối hồ sơ', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showApproveDialog(context, ref, app);
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Phê duyệt đối tác', style: TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
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
            Text('Phê duyệt đối tác?'),
          ],
        ),
        content: Text(
          'Xác nhận duyệt hồ sơ cho "${app.businessName}". Tài khoản này sẽ được nâng cấp thành Nhà cung cấp chính thức trên EventHub.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
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
              'Từ chối hồ sơ "${app.businessName}". Nhập lý do gửi đến đối tác:',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Thiếu chứng chỉ VSATTP, ảnh sản phẩm chưa rõ...',
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color text = const Color(0xFFB45309);
    String label = 'Chờ duyệt';

    if (status.toLowerCase() == 'approved') {
      bg = const Color(0xFFD1FAE5);
      text = const Color(0xFF047857);
      label = 'Đã phê duyệt';
    } else if (status.toLowerCase() == 'rejected') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
      label = 'Đã từ chối';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: text)),
    );
  }
}

