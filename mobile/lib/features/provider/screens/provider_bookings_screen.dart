import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../../bookings/models/booking_model.dart';
import '../../bookings/providers/booking_provider.dart';

class ProviderBookingsScreen extends ConsumerStatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  ConsumerState<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends ConsumerState<ProviderBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _receivedSubFilter = 'all'; // 'all', 'confirmed', 'in_progress', 'accepted'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _acceptBooking(String id) {
    ref.read(bookingProvider.notifier).acceptProviderBooking(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Đã chấp thuận đơn! Khách hàng có thể tiến hành chuyển khoản/thanh toán ngay.')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _rejectBooking(String id) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Từ chối đơn đặt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vui lòng nhập lý do từ chối để hệ thống gửi thông báo cho khách hàng:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'VD: Đã kín lịch vào ngày này, bảo trì thiết bị...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              Navigator.pop(ctx);
              ref.read(bookingProvider.notifier).rejectProviderBooking(id, reason.isNotEmpty ? reason : 'Đã kín lịch sự kiện');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã từ chối đơn đặt.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
  }

  void _changeBookingStatus(String id, String newStatus) {
    ref.read(bookingProvider.notifier).updateProviderBookingStatus(id, newStatus);
    String statusText = 'Đang diễn ra';
    IconData icon = Icons.play_arrow_rounded;
    Color bg = const Color(0xFF6366F1);

    if (newStatus == 'Completed') {
      statusText = 'Hoàn thành sự kiện';
      icon = Icons.verified_rounded;
      bg = AppColors.success;
    } else if (newStatus == 'Confirmed') {
      statusText = 'Chờ triển khai';
      icon = Icons.schedule_rounded;
      bg = const Color(0xFF0284C7);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('Đã cập nhật trạng thái đơn thành "$statusText"!')),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<BookingModel> _filterList(List<BookingModel> allBookings, String statusGroup) {
    switch (statusGroup) {
      case 'Pending':
        return allBookings.where((b) => b.status == 'PendingProviderApproval' || b.status == 'Pending').toList();
      case 'Confirmed':
        // Đơn đã nhận: Khách đã chuyển khoản (Confirmed, InProgress) và đơn đã duyệt chờ chuyển khoản
        return allBookings.where((b) => b.status == 'Confirmed' || b.status == 'InProgress' || b.status == 'Accepted').toList();
      case 'Completed':
        return allBookings.where((b) => b.status == 'Completed').toList();
      case 'Rejected':
        return allBookings.where((b) => b.status == 'Rejected' || b.status == 'Cancelled').toList();
      default:
        return allBookings;
    }
  }

  void _showBookingDetailModal(BookingModel b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã đơn: ${b.code}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.serviceTitle,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: b.statusBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      b.statusLabel,
                      style: TextStyle(color: b.statusColor, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // Customer & Event Info
              const Text('Thông tin khách hàng & Sự kiện', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildModalRow(Icons.person_rounded, 'Khách hàng', b.customerName),
                    const SizedBox(height: 8),
                    _buildModalRow(Icons.phone_rounded, 'Số điện thoại', b.customerPhone),
                    const SizedBox(height: 8),
                    _buildModalRow(Icons.event_rounded, 'Thời gian', '${b.date} • ${b.time}'),
                    const SizedBox(height: 8),
                    _buildModalRow(Icons.groups_rounded, 'Số lượng khách', b.guestCount),
                    const SizedBox(height: 8),
                    _buildModalRow(Icons.location_on_rounded, 'Địa điểm', b.location),
                    if (b.specialRequirements.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildModalRow(Icons.note_alt_rounded, 'Ghi chú', b.specialRequirements),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Payment and Revenue
              const Text('Tài chính & Thanh toán', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng giá trị gói:', style: TextStyle(fontSize: 13, color: Color(0xFF166534))),
                        Text(b.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Chiết khấu sàn (10%):', style: TextStyle(fontSize: 12, color: Color(0xFF15803D))),
                        Text(
                          '-${BookingModel.formatVnd((b.rawPrice * BookingModel.adminCommissionRate).round())}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Color(0xFFBBF7D0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('NCC Thực nhận:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                        Text(
                          b.providerNetPrice,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              b.paymentGateway ?? 'Đã thanh toán chuyển khoản SePay VietQR',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Customer Review block if completed (NCC is view-only)
              if (b.status == 'Completed') ...[
                const SizedBox(height: 16),
                const Text('Đánh giá từ khách hàng (NCC chỉ xem)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: b.isReviewed ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: b.isReviewed ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                  ),
                  child: b.isReviewed
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => Icon(
                                    index < (b.rating ?? 5) ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: const Color(0xFFF59E0B),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${b.rating}.0 / 5.0 sao',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
                                ),
                              ],
                            ),
                            if (b.reviewComment?.isNotEmpty == true) ...[
                              const SizedBox(height: 8),
                              Text(
                                '"${b.reviewComment}"',
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF78350F), fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        )
                      : const Row(
                          children: [
                            Icon(Icons.hourglass_top_rounded, size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Khách hàng chưa gửi đánh giá sao cho đơn này.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                ),
              ],

              const SizedBox(height: 20),

              // Status Change Action Buttons (Only when not yet completed)
              if (b.status != 'Completed') ...[
                const Text('Chuyển chế độ đơn hàng:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Set to Confirmed (Chờ triển khai)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: b.status == 'Confirmed' ? const Color(0xFF0284C7) : AppColors.textSecondary,
                          backgroundColor: b.status == 'Confirmed' ? const Color(0xFFF0F9FF) : Colors.white,
                          side: BorderSide(color: b.status == 'Confirmed' ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _changeBookingStatus(b.id, 'Confirmed');
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 18),
                            SizedBox(height: 4),
                            Text('Chờ triển khai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Set to InProgress (Đang diễn ra)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: b.status == 'InProgress' ? 2 : 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _changeBookingStatus(b.id, 'InProgress');
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_fill_rounded, size: 18),
                            SizedBox(height: 4),
                            Text('Đang diễn ra', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Set to Completed (Hoàn thành)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _changeBookingStatus(b.id, 'Completed');
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.task_alt_rounded, size: 18),
                            SizedBox(height: 4),
                            Text('Hoàn thành', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 105,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingProvider);

    final pendingList = _filterList(allBookings, 'Pending');
    final confirmedList = _filterList(allBookings, 'Confirmed');
    final completedList = _filterList(allBookings, 'Completed');
    final rejectedList = _filterList(allBookings, 'Rejected');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Đơn đặt dịch vụ'),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'Chờ duyệt (${pendingList.length})'),
                Tab(text: 'Đã nhận (${confirmedList.length})'),
                Tab(text: 'Hoàn tất (${completedList.length})'),
                Tab(text: 'Đã hủy (${rejectedList.length})'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(pendingList, 'yêu cầu chờ duyệt', showActionButtons: true),
          _buildConfirmedTab(confirmedList),
          _buildList(completedList, 'đơn hoàn thành'),
          _buildList(rejectedList, 'đơn đã từ chối/hủy'),
        ],
      ),
    );
  }

  Widget _buildConfirmedTab(List<BookingModel> items) {
    // Filter according to sub-filter chip
    final filtered = items.where((b) {
      if (_receivedSubFilter == 'confirmed') return b.status == 'Confirmed';
      if (_receivedSubFilter == 'in_progress') return b.status == 'InProgress';
      if (_receivedSubFilter == 'accepted') return b.status == 'Accepted';
      return true;
    }).toList();

    final confirmedCount = items.where((b) => b.status == 'Confirmed').length;
    final inProgressCount = items.where((b) => b.status == 'InProgress').length;
    final acceptedCount = items.where((b) => b.status == 'Accepted').length;

    return Column(
      children: [
        // Sub-filter chips row
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSubChip('Tất cả (${items.length})', 'all'),
                const SizedBox(width: 8),
                _buildSubChip('Chờ triển khai ($confirmedCount)', 'confirmed', color: const Color(0xFF0284C7)),
                const SizedBox(width: 8),
                _buildSubChip('Đang diễn ra ($inProgressCount)', 'in_progress', color: const Color(0xFF6366F1), isHot: inProgressCount > 0),
                if (acceptedCount > 0) ...[
                  const SizedBox(width: 8),
                  _buildSubChip('Chờ thanh toán ($acceptedCount)', 'accepted', color: const Color(0xFFD97706)),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: _buildList(
            filtered,
            'đơn đã nhận',
            isConfirmedTab: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSubChip(String label, String key, {Color? color, bool isHot = false}) {
    final isSelected = _receivedSubFilter == key;
    final effectiveColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: () => setState(() => _receivedSubFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor.withOpacity(0.12) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? effectiveColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: effectiveColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? effectiveColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    List<BookingModel> items,
    String categoryName, {
    bool showActionButtons = false,
    bool isConfirmedTab = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: const Icon(Icons.inbox_outlined, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              Text(
                'Chưa có $categoryName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Các đơn đặt từ khách hàng sẽ xuất hiện tự động tại đây khi có yêu cầu mới.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final b = items[idx];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showBookingDetailModal(b),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: b.status == 'InProgress'
                    ? const Color(0xFF6366F1).withOpacity(0.5)
                    : AppColors.cardBorder,
                width: b.status == 'InProgress' ? 1.5 : 1,
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Strip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: b.status == 'InProgress' ? const Color(0xFFEEF2FF) : const Color(0xFFFAFAFC),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: b.status == 'InProgress'
                                    ? const Color(0xFF6366F1).withOpacity(0.15)
                                    : AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                b.status == 'InProgress' ? Icons.rocket_launch_rounded : Icons.tag_rounded,
                                size: 14,
                                color: b.status == 'InProgress' ? const Color(0xFF6366F1) : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              b.code,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: b.status == 'InProgress' ? const Color(0xFF4338CA) : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: b.statusBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: b.statusColor.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: b.statusColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                b.statusLabel,
                                style: TextStyle(color: b.statusColor, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Booking Service Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: EventNetworkImage(
                                imageUrl: b.imageUrl,
                                width: 72,
                                height: 72,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.serviceTitle,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Gói: ${b.packageName.isNotEmpty ? b.packageName : "Tiêu chuẩn"}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Customer Info Ribbon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      b.customerName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E7FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      b.customerPhone,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16, color: Color(0xFFE2E8F0)),
                              Row(
                                children: [
                                  const Icon(Icons.event_rounded, size: 15, color: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(b.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                  const SizedBox(width: 14),
                                  const Icon(Icons.groups_rounded, size: 15, color: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(b.guestCount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 15, color: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      b.location,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Payment Gateway ribbon if paid
                        if (b.status == 'Confirmed' || b.status == 'InProgress') ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF16A34A)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    b.paymentGateway ?? 'Đã chuyển khoản thành công qua SePay - ACB',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (b.specialRequirements.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Text(
                              'Ghi chú: ${b.specialRequirements}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Price and Action Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thực nhận (đã trừ 10% phí)',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    b.providerNetPrice,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Actions for Pending approval
                            if (showActionButtons)
                              Row(
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                      minimumSize: const Size(0, 36),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _rejectBooking(b.id),
                                    child: const Text('Từ chối', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                        minimumSize: const Size(0, 36),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _acceptBooking(b.id),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Duyệt đơn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )

                            // Actions for Confirmed & InProgress (Đã nhận: chuyển chế độ Đang diễn ra hoặc Hoàn thành)
                            else if (isConfirmedTab)
                              Row(
                                children: [
                                  if (b.status != 'InProgress')
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6366F1),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                        minimumSize: const Size(0, 36),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                      label: const Text('Đang diễn ra', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                                      onPressed: () => _changeBookingStatus(b.id, 'InProgress'),
                                    ),
                                  if (b.status != 'InProgress') const SizedBox(width: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.emeraldGradient,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.success.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                        minimumSize: const Size(0, 36),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.task_alt_rounded, size: 16, color: Colors.white),
                                      label: const Text(
                                        'Hoàn thành',
                                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                      onPressed: () => _changeBookingStatus(b.id, 'Completed'),
                                    ),
                                  ),
                                ],
                              )

                            // Khi đơn đã hoàn tất (Completed): NCC chỉ xem số sao đánh giá của khách, không có nút đánh giá hay xóa
                            else if (b.status == 'Completed')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: b.isReviewed ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: b.isReviewed ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      b.isReviewed ? Icons.star_rounded : Icons.rate_review_outlined,
                                      size: 15,
                                      color: b.isReviewed ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      b.isReviewed ? '${b.rating}.0 ★ (Khách đánh giá)' : 'Chờ khách đánh giá',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: b.isReviewed ? const Color(0xFF92400E) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
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
        );
      },
    );
  }
}
