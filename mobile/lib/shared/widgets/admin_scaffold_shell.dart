import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/admin/providers/admin_provider.dart';
import '../../features/services/providers/product_approval_provider.dart';

class AdminScaffoldShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdminScaffoldShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAppCount = ref.watch(adminProvider).pendingApplicationsCount;
    final pendingProductCount = ref.watch(productApprovalProvider).pendingCount;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: Colors.white,
            elevation: 0,
            height: 64,
            indicatorColor: const Color(0xFFEEF2FF),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF4F46E5) : AppColors.textSecondary,
                letterSpacing: -0.2,
              );
            }),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, size: 22),
                selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF4F46E5), size: 23),
                label: 'Tổng quan',
              ),
              const NavigationDestination(
                icon: Icon(Icons.people_outline_rounded, size: 22),
                selectedIcon: Icon(Icons.people_alt_rounded, color: Color(0xFF4F46E5), size: 23),
                label: 'Người dùng',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: pendingAppCount > 0,
                  label: Text('$pendingAppCount', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFFF59E0B),
                  child: const Icon(Icons.verified_outlined, size: 22),
                ),
                selectedIcon: Badge(
                  isLabelVisible: pendingAppCount > 0,
                  label: Text('$pendingAppCount', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFFF59E0B),
                  child: const Icon(Icons.verified_rounded, color: Color(0xFF4F46E5), size: 23),
                ),
                label: 'Đơn xin NCC',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: pendingProductCount > 0,
                  label: Text('$pendingProductCount', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFFEA580C),
                  child: const Icon(Icons.inventory_2_outlined, size: 22),
                ),
                selectedIcon: Badge(
                  isLabelVisible: pendingProductCount > 0,
                  label: Text('$pendingProductCount', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFFEA580C),
                  child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF4F46E5), size: 23),
                ),
                label: 'Duyệt SP',
              ),
              const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined, size: 23),
                selectedIcon: Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF4F46E5), size: 24),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

