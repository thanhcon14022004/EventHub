import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_locale_provider.dart';
import '../../core/localization/app_translations.dart';
import '../../features/bookings/models/booking_model.dart';
import '../../features/notifications/providers/notification_provider.dart';
import 'floating_chat_bubble.dart';

class MainScaffoldShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldShell({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainScaffoldShell> createState() => _MainScaffoldShellState();
}

class _MainScaffoldShellState extends ConsumerState<MainScaffoldShell> {
  Timer? _snackBarTimer;

  @override
  void dispose() {
    _snackBarTimer?.cancel();
    super.dispose();
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự kiện thanh toán thành công để hiển thị thông báo nổi trên toàn bộ ứng dụng
    ref.listen<BookingModel?>(
      notificationProvider.select((s) => s.pendingSnackBarBooking),
      (previous, next) {
        if (next != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(notificationProvider.notifier).consumePendingSnackBar();
            final gateway = ref.read(notificationProvider).lastPaymentGateway;
            final messenger = ScaffoldMessenger.maybeOf(context);
            messenger?.hideCurrentSnackBar();
            messenger?.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF059669),
                duration: const Duration(seconds: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Đặt đơn thành công! Đơn ${next.code} (${next.serviceTitle}) đã thanh toán $gateway.',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                action: SnackBarAction(
                  label: 'Xem đơn',
                  textColor: const Color(0xFFFDE047),
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    _onTap(2); // Chuyển sang tab Đơn đặt
                  },
                ),
              ),
            );

            // Tự động tắt thông báo sau đúng 10 giây
            _snackBarTimer?.cancel();
            _snackBarTimer = Timer(const Duration(seconds: 10), () {
              if (mounted) {
                messenger?.hideCurrentSnackBar();
                ref.read(notificationProvider.notifier).dismissHomeSuccessBanner();
              }
            });
          });
        }
      },
    );

    final lang = ref.watch(appLocaleProvider);
    String t(String key) => AppTranslations.translate(key, lang);

    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          // Floating Circular Chat Widget
          const Positioned(
            bottom: 16,
            right: 18,
            child: FloatingChatBubble(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: Colors.white,
            elevation: 0,
            height: 64,
            indicatorColor: const Color(0xFFEDE9FE),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: -0.2,
              );
            }),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined, size: 22),
                selectedIcon: const Icon(Icons.explore_rounded, color: AppColors.primary, size: 23),
                label: t('nav_explore'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined, size: 22),
                selectedIcon: const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 23),
                label: t('nav_categories'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_today_outlined, size: 21),
                selectedIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 22),
                label: t('nav_bookings'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded, size: 23),
                selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                label: t('nav_account'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined, size: 23),
                selectedIcon: const Icon(Icons.settings_rounded, color: AppColors.primary, size: 24),
                label: t('nav_settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
