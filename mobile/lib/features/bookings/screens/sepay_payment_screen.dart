import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../notifications/providers/notification_provider.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class SepayPaymentScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const SepayPaymentScreen({super.key, required this.booking});

  @override
  ConsumerState<SepayPaymentScreen> createState() => _SepayPaymentScreenState();
}

class _SepayPaymentScreenState extends ConsumerState<SepayPaymentScreen> with SingleTickerProviderStateMixin {
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 900; // 15 phút
  bool _isCheckingManual = false;
  bool _isSuccess = false;
  late AnimationController _pulseController;

  static const String _kAccountNumber = '27655931';
  static const String _kAccountName = 'HA TRUNG THANH';
  static const String _kBankBrand = 'ACB';
  static const String _kBankName = 'Ngân hàng TMCP Á Châu (ACB)';

  String get _cleanCode => widget.booking.code.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  String get _transferContent => 'EH $_cleanCode';

  String get _qrUrl {
    final amount = widget.booking.rawPrice;
    final des = Uri.encodeComponent(_transferContent);
    return 'https://qr.sepay.vn/img?acc=$_kAccountNumber&bank=$_kBankBrand&amount=$amount&des=$des';
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Bắt đầu đếm ngược 15 phút
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });

    // Tự động quét biến động số dư SePay mỗi 3 giây
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_isSuccess && mounted) {
        _checkStatusSilently();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkStatusSilently() async {
    final isPaid = await ref.read(bookingProvider.notifier).checkSepayPayment(widget.booking.id);
    if (isPaid && mounted && !_isSuccess) {
      _onPaymentSuccess();
    }
  }

  Future<void> _checkStatusManual() async {
    if (_isSuccess) return;
    setState(() => _isCheckingManual = true);
    final isPaid = await ref.read(bookingProvider.notifier).checkSepayPayment(widget.booking.id);
    if (!mounted) return;
    setState(() => _isCheckingManual = false);

    if (isPaid) {
      _onPaymentSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa phát hiện biến động số dư hợp lệ. Đang tiếp tục quét tự động...'),
          backgroundColor: AppColors.info,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onPaymentSuccess() {
    if (_isSuccess) return;
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() => _isSuccess = true);

    // Ghi nhận thông báo "Đặt đơn thành công" và hiển thị ngay khi về trang Home
    ref.read(notificationProvider.notifier).notifyBookingPaymentSuccess(widget.booking, gatewayName: 'SePay');

    // Tự động điều hướng thẳng ra trang Home ('/')
    final router = GoRouter.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    if (navigator != null) {
      navigator.popUntil((route) => route.settings is Page || route.isFirst);
    }
    if (router != null) {
      router.go('/');
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatRemainingTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Thanh toán tự động SePay'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        child: Column(
          children: [
            // Top Live Scanning Indicator Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15 + _pulseController.value * 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.radar_rounded, color: AppColors.success, size: 22),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đang tự động quét biến động số dư SePay',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1B5E20)),
                        ),
                        Text(
                          'Thời gian giữ đơn: ${_formatRemainingTime(_remainingSeconds)} • Quét mỗi 3s',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic VietQR Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bank Logo & Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005BAA).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACB',
                          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF005BAA), fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'VietQR Tự Động 24/7',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // VietQR Image from SePay
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: Image.network(
                        _qrUrl,
                        width: 230,
                        height: 230,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 230,
                            height: 230,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          width: 230,
                          height: 230,
                          color: AppColors.secondary,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2_rounded, size: 64, color: AppColors.primary),
                              SizedBox(height: 8),
                              Text('Đang tải mã VietQR...', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Mở ứng dụng Ngân hàng bất kỳ hoặc Ví điện tử để quét mã',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bank Information Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin chuyển khoản thủ công',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _buildCopyableRow(
                    label: 'Ngân hàng thụ hưởng:',
                    value: _kBankName,
                    copyValue: 'ACB',
                  ),
                  const Divider(height: 18),
                  _buildCopyableRow(
                    label: 'Số tài khoản:',
                    value: _kAccountNumber,
                    copyValue: _kAccountNumber,
                    isHighlight: true,
                  ),
                  const Divider(height: 18),
                  _buildCopyableRow(
                    label: 'Chủ tài khoản:',
                    value: _kAccountName,
                    copyValue: _kAccountName,
                  ),
                  const Divider(height: 18),
                  _buildCopyableRow(
                    label: 'Số tiền cần chuyển:',
                    value: widget.booking.price,
                    copyValue: '${widget.booking.rawPrice}',
                    isHighlight: true,
                    valueColor: AppColors.primary,
                  ),
                  const Divider(height: 18),
                  // Transfer Content (Critical for Auto-Detection)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFF57F17)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Nội dung chuyển khoản (Bắt buộc chính xác):',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFFF57F17)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _transferContent,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFB71C1C), letterSpacing: 1),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF57F17),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: const Size(0, 32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: const Text('Sao chép', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              onPressed: () => _copyToClipboard(_transferContent, 'nội dung'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isCheckingManual
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
                label: Text(
                  _isCheckingManual ? 'Đang kiểm tra SePay...' : 'Tôi đã chuyển khoản (Kiểm tra ngay)',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                onPressed: _isCheckingManual ? null : _checkStatusManual,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyableRow({
    required String label,
    required String value,
    required String copyValue,
    bool isHighlight = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _copyToClipboard(copyValue, label.replaceAll(':', '')),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
