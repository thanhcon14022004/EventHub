import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EventCountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final String? eventName;
  final bool compact;

  const EventCountdownTimer({
    super.key,
    required this.targetDate,
    this.eventName,
    this.compact = false,
  });

  @override
  State<EventCountdownTimer> createState() => _EventCountdownTimerState();
}

class _EventCountdownTimerState extends State<EventCountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _calcRemaining();
        });
      }
    });
  }

  void _calcRemaining() {
    final now = DateTime.now();
    if (widget.targetDate.isAfter(now)) {
      _remaining = widget.targetDate.difference(now);
    } else {
      _remaining = Duration.zero;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpired = _remaining == Duration.zero;

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (widget.compact) {
      if (isExpired) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 4),
              Text(
                'Đang diễn ra',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5).withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              '${days}d ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF4338CA) : const Color(0xFFC7D2FE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alarm_on_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.eventName != null
                    ? 'Đếm ngược: ${widget.eventName}'
                    : 'Đếm ngược đến giờ khai mạc sự kiện',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (!isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Sắp diễn ra',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (isExpired)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: const Text(
                '🎉 Sự kiện đang được tổ chức trực tiếp!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeBox(days.toString().padLeft(2, '0'), 'NGÀY', isDark),
                _buildSeparator(isDark),
                _buildTimeBox(hours.toString().padLeft(2, '0'), 'GIỜ', isDark),
                _buildSeparator(isDark),
                _buildTimeBox(minutes.toString().padLeft(2, '0'), 'PHÚT', isDark),
                _buildSeparator(isDark),
                _buildTimeBox(seconds.toString().padLeft(2, '0'), 'GIÂY', isDark, isHighlight: true),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String val, String label, bool isDark, {bool isHighlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHighlight
                  ? const Color(0xFFF59E0B)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isHighlight ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            val,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isHighlight
                  ? const Color(0xFFF59E0B)
                  : (isDark ? Colors.white : AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: isDark ? const Color(0xFF818CF8) : AppColors.primary,
        ),
      ),
    );
  }
}

