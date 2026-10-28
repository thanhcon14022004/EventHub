import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../notifications/providers/notification_provider.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class MomoPaymentScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const MomoPaymentScreen({super.key, required this.booking});

  @override
  ConsumerState<MomoPaymentScreen> createState() => _MomoPaymentScreenState();
}

class _MomoPaymentScreenState extends ConsumerState<MomoPaymentScreen> with SingleTickerProviderStateMixin {
  // Tài khoản 1: Nhận tiền (HA TRUNG THANH)
  static const String receiverPhone = '0364663787';
  static const String receiverName = 'HA TRUNG THANH';

  // Tài khoản 2: Khách hàng chuyển tiền trên máy ảo (VU THI MAI ANH)
  static const String senderPhone = '0862460313';
  static const String senderName = 'VU THI MAI ANH';

  bool _isProcessing = false;
  bool _isSuccess = false;
  String _momoTransId = '';

  late AnimationController _checkAnimController;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _checkAnimController.dispose();
    super.dispose();
  }

  String _generateMomoTransId() {
    final now = DateTime.now();
    return 'MM${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  Future<void> _handleConfirmPayment() async {
    if (_isProcessing || _isSuccess) return;

    setState(() {
      _isProcessing = true;
    });

    // Mô phỏng kết nối và xác thực bảo mật tài khoản MoMo trên máy ảo
    await Future.delayed(const Duration(milliseconds: 900));

    final transId = _generateMomoTransId();

    // Cập nhật trạng thái đơn hàng sang Confirmed với cổng MoMo
    await ref.read(bookingProvider.notifier).paySingleBooking(
      widget.booking.id,
      'MoMo ($senderPhone -> $receiverPhone)',
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _isSuccess = true;
      _momoTransId = transId;
    });

    _checkAnimController.forward();

    // Gửi thông báo đặt đơn thành công qua MoMo
    ref.read(notificationProvider.notifier).notifyBookingPaymentSuccess(widget.booking, gatewayName: 'MoMo');

    // Chờ 1.8 giây để người dùng thấy biên nhận MoMo thành công trước khi tự nhảy ra Home
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    // Tự động điều hướng về Home ('/')
    final router = GoRouter.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    if (navigator != null) {
      navigator.popUntil((route) => route.settings is Page || route.isFirst);
    }
    if (router != null) {
      router.go('/');
    }
  }

  Future<void> _openMomoApp() async {
    try {
      const platform = MethodChannel('com.eventhub.app/momo');
      await platform.invokeMethod('openMomo');
    } catch (e) {
      debugPrint('Could not open MoMo: $e');
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        backgroundColor: const Color(0xFFA50064),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA50064),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Thanh toán Ví MoMo',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // MoMo Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA50064), Color(0xFFD82D8B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA50064).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'momo',
                        style: TextStyle(
                          color: Color(0xFFA50064),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CỔNG CHUYỂN TIỀN TRỰC TIẾP MOMO',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.booking.price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Mã đơn: ${widget.booking.code}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Người nhận: Tài khoản 1 (CỦA BẠN)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCE7F3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF2F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.call_received_rounded, color: Color(0xFFA50064), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'TÀI KHOẢN NHẬN TIỀN (TK 1)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFA50064),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 13, color: Color(0xFF059669)),
                            SizedBox(width: 4),
                            Text('Chính chủ', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    label: 'Người nhận:',
                    value: receiverName,
                    isBold: true,
                    textColor: const Color(0xFF0F172A),
                  ),
                  const Divider(height: 18, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    label: 'Số MoMo nhận:',
                    value: receiverPhone,
                    isCopyable: true,
                    textColor: const Color(0xFFA50064),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Người gửi: Tài khoản 2 (CỦA BẠN BẠN TRÊN MÁY ẢO)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.call_made_rounded, color: Color(0xFF2563EB), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'TÀI KHOẢN CHUYỂN TIỀN (TK 2 - MÁY ẢO)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Đã liên kết', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    label: 'Khách hàng:',
                    value: senderName,
                    isBold: true,
                    textColor: const Color(0xFF0F172A),
                  ),
                  const Divider(height: 18, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    label: 'Số MoMo gửi:',
                    value: senderPhone,
                    textColor: const Color(0xFF334155),
                    isBold: true,
                  ),
                  const Divider(height: 18, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    label: 'Dịch vụ:',
                    value: widget.booking.serviceTitle,
                    textColor: const Color(0xFF334155),
                  ),
                  const Divider(height: 18, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    label: 'Nội dung CK:',
                    value: 'EH ${widget.booking.code}',
                    isCopyable: true,
                    textColor: const Color(0xFF0F172A),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thông báo trạng thái hoặc Nút Xác nhận chuyển tiền
            if (_isSuccess) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 48),
                    const SizedBox(height: 10),
                    const Text(
                      'GIAO DỊCH MOMO THÀNH CÔNG!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF065F46),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tiền đã chuyển từ $senderName sang $receiverName.',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mã giao dịch: $_momoTransId',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF065F46), fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF059669)),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Đang tự động chuyển về Trang chủ...',
                          style: TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Nút Mở Ứng Dụng MoMo Trực Tiếp Trên Máy Ảo
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFA50064), width: 1.5),
                    backgroundColor: const Color(0xFFFDF2F8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _openMomoApp,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.launch_rounded, color: Color(0xFFA50064), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Mở ứng dụng MoMo trên máy ảo',
                        style: TextStyle(
                          color: Color(0xFFA50064),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFA50064),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: const Color(0xFFA50064).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isProcessing ? null : _handleConfirmPayment,
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Đang xử lý chuyển tiền MoMo...',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Xác nhận chuyển ${widget.booking.price}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Giao dịch được bảo vệ và mã hóa bởi MoMo Security Sandbox',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isBold = false,
    bool isCopyable = false,
    Color textColor = const Color(0xFF0F172A),
  }) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              color: textColor,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        if (isCopyable)
          InkWell(
            onTap: () => _copyToClipboard(value, label.replaceAll(':', '')),
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Icon(Icons.copy_rounded, size: 16, color: Color(0xFFA50064)),
            ),
          ),
      ],
    );
  }
}
