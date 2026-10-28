import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/calendar_service.dart';
import '../../../shared/widgets/event_countdown_timer.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import 'sepay_payment_screen.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  void _confirmCancelBooking(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận hủy đơn', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Bạn có chắc chắn muốn hủy đơn đặt $code không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(bookingProvider.notifier).cancelBooking(widget.bookingId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã hủy đơn đặt thành công'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBooking(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa đơn đặt', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Bạn có chắc chắn muốn xóa đơn đặt ${booking.code} khỏi danh sách không?'),
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
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(bookingProvider.notifier).deleteBooking(widget.bookingId);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa đơn đặt ${booking.code} khỏi danh sách.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  void _showSinglePaymentModal(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payment_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thanh toán đơn dịch vụ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Mã đơn: ${booking.code}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số tiền thanh toán:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      Text(
                        booking.price,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA50064),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0xFFA50064).withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.account_balance_wallet_rounded, size: 20),
                label: const Text('Thanh toán Ví MoMo (Chuyển tiền)', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                onPressed: () async {
                  Navigator.pop(modalCtx);
                  try {
                    const platform = MethodChannel('com.eventhub.app/momo');
                    await platform.invokeMethod('openMomo', {
                      'amount': booking.price,
                      'bookingCode': booking.code,
                    });
                  } catch (e) {
                    debugPrint('Could not launch MoMo: $e');
                  }
                  if (!mounted) return;
                  await ref.read(bookingProvider.notifier).paySingleBooking(booking.id, 'MoMo');
                  ref.read(notificationProvider.notifier).notifyBookingPaymentSuccess(booking, gatewayName: 'MoMo');
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                  foregroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                label: const Text('Thanh toán qua SePay VietQR', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                onPressed: () {
                  Navigator.pop(modalCtx);
                  final router = GoRouter.maybeOf(context);
                  if (router != null) {
                    router.push('/bookings/${booking.id}/sepay', extra: booking);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => SepayPaymentScreen(booking: booking),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingReviewDialog(BookingModel booking) {
    int selectedRating = 5;
    final commentController = TextEditingController(text: booking.reviewComment ?? '');

    final ratingLabels = {
      5: '⭐⭐⭐⭐⭐ Xuất sắc / Rất hài lòng',
      4: '⭐⭐⭐⭐ Rất tốt & Chuyên nghiệp',
      3: '⭐⭐⭐ Hài lòng / Đạt yêu cầu',
      2: '⭐⭐ Chưa hài lòng',
      1: '⭐ Rất thất vọng / Cần cải thiện',
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 26),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoàn tất & Đánh giá',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Đánh giá chất lượng dịch vụ của NCC',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  Text(
                    booking.serviceTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF1E293B)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhà cung cấp: ${booking.providerName}',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),

                  // Star Rating Row
                  const Text('Chọn số sao đánh giá:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          iconSize: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            star <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: star <= selectedRating ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                          ),
                          onPressed: () => setDialogState(() => selectedRating = star),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ratingLabels[selectedRating] ?? '',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comment Input
                  const Text('Nhận xét chi tiết:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập cảm nhận của bạn về sự kiện, đúng hẹn, chất lượng decor, thái độ phục vụ...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Để sau', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ),
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
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                  label: const Text('Gửi đánh giá', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  onPressed: () {
                    final comment = commentController.text.trim();
                    ref.read(bookingProvider.notifier).submitBookingReview(
                      bookingId: booking.id,
                      rating: selectedRating,
                      comment: comment.isNotEmpty ? comment : 'Dịch vụ rất tuyệt vời và chu đáo!',
                    );
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('Cảm ơn bạn đã đánh giá $selectedRating sao cho ${booking.providerName}!'),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingProvider);
    final booking = bookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => ref.read(bookingProvider.notifier).getBookingById(widget.bookingId) ?? BookingModel(
        id: '',
        code: 'N/A',
        serviceId: '',
        serviceTitle: 'Không tìm thấy dịch vụ',
        providerName: '',
        packageName: '',
        date: '',
        time: '',
        price: '0 ₫',
        rawPrice: 0,
        status: 'Unknown',
        imageUrl: '',
        location: '',
        guestCount: '',
        customerName: '',
        customerPhone: '',
        createdAt: DateTime(2026),
      ),
    );

    if (booking.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn đặt')),
        body: const Center(child: Text('Không tìm thấy thông tin đơn đặt này')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chi tiết đơn đặt'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Code Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã đơn: ${booking.code}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: booking.statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.statusLabel,
                          style: TextStyle(color: booking.statusColor, fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress Steps Timeline
                  Row(
                    children: [
                      _buildStepIndicator('Đã gửi', true),
                      _buildStepLine(booking.status != 'PendingProviderApproval' && booking.status != 'Pending'),
                      _buildStepIndicator('Duyệt', booking.status != 'PendingProviderApproval' && booking.status != 'Pending'),
                      _buildStepLine(booking.isPaid),
                      _buildStepIndicator('Thanh toán', booking.isPaid),
                      _buildStepLine(booking.isInProgress || booking.isCompleted),
                      _buildStepIndicator('Đang diễn ra', booking.isInProgress || booking.isCompleted),
                      _buildStepLine(booking.isCompleted),
                      _buildStepIndicator('Hoàn tất', booking.isCompleted),
                    ],
                  ),

                  // InProgress Live Banner
                  if (booking.isInProgress) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.rocket_launch_rounded, size: 20, color: Color(0xFF4F46E5)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sự kiện đang diễn ra trực tiếp! Nhà cung cấp đang triển khai dịch vụ tại địa điểm.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3730A3)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Review Banner if completed & reviewed
                  if (booking.isCompleted && booking.isReviewed) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 6),
                              Text(
                                '${booking.rating} sao - Đánh giá của bạn',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                              ),
                            ],
                          ),
                          if (booking.reviewComment?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              '"${booking.reviewComment}"',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF166534)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Countdown Timer if booking is active
            if (booking.status != 'Cancelled' && !booking.isCompleted) ...[
              const SizedBox(height: 16),
              EventCountdownTimer(
                targetDate: DateTime.now().add(const Duration(days: 4, hours: 14, minutes: 20)),
                eventName: booking.serviceTitle,
              ),
            ],

            const SizedBox(height: 16),

            // Service details Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: EventNetworkImage(
                          imageUrl: booking.imageUrl,
                          width: 80,
                          height: 80,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.serviceTitle,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.packageName,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NCC: ${booking.providerName}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow('Thời gian:', '${booking.date} • ${booking.time}', Icons.calendar_today_rounded, AppColors.primary),
                  const SizedBox(height: 10),
                  _buildDetailRow('Địa điểm:', booking.location, Icons.location_on_rounded, AppColors.accent),
                  const SizedBox(height: 10),
                  _buildDetailRow('Số lượng khách:', booking.guestCount, Icons.groups_rounded, const Color(0xFF0284C7)),
                  if (booking.specialRequirements.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow('Ghi chú:', booking.specialRequirements, Icons.note_alt_rounded, const Color(0xFFD97706)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Financials Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng chi phí gói:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      Text(booking.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  if (booking.isPaid) ...[
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.paymentGateway ?? 'Đã thanh toán thành công',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            if (booking.canBePaid) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.payment_rounded),
                  label: const Text('Thanh toán đơn này ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  onPressed: () => _showSinglePaymentModal(booking),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Hoàn thành & Đánh giá (khi NCC đã hoàn thành sự kiện nhưng khách CHƯA đánh giá)
            if (booking.status == 'Completed' && !booking.isReviewed) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.emeraldGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.task_alt_rounded, size: 20, color: Colors.white),
                  label: const Text(
                    'Hoàn thành & Đánh giá dịch vụ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  onPressed: () => _showRatingReviewDialog(booking),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Thêm vào Lịch điện thoại (Google Calendar)
            if (booking.status != 'Cancelled') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0284C7),
                    side: const BorderSide(color: Color(0xFF38BDF8), width: 1.3),
                    backgroundColor: const Color(0xFFF0F9FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFF0284C7)),
                  label: const Text('Thêm vào Lịch điện thoại (Google Calendar)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                  onPressed: () async {
                    final success = await CalendarService.addEventToCalendar(
                      title: 'Sự kiện EventHub: ${booking.serviceTitle}',
                      description: 'Mã đơn: ${booking.code}\nGói: ${booking.packageName}\nNhà cung cấp: ${booking.providerName}\nKhách hàng: ${booking.customerName}',
                      location: booking.location,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.event_available_rounded, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(child: Text(success ? 'Đã mở Google Calendar để lưu lịch sự kiện "${booking.serviceTitle}"!' : 'Không thể mở ứng dụng Lịch')),
                            ],
                          ),
                          backgroundColor: success ? AppColors.success : AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (booking.status != 'Cancelled' && booking.status != 'Completed') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Hủy yêu cầu đặt dịch vụ', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () => _confirmCancelBooking(context, booking.code),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Khi đã đánh giá xong thì không hiển thị nút Xóa nữa
            if (!booking.isReviewed) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Xóa đơn đặt khỏi danh sách', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () => _confirmDeleteBooking(context, booking),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String label, bool isDone) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: isDone ? 13 : 8,
            color: isDone ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
            color: isDone ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? AppColors.primary : const Color(0xFFE2E8F0),
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
        ),
      ],
    );
  }
}
