import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'floating_chat_bubble.dart';

class ProviderScaffoldShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ProviderScaffoldShell({
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
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
            selectedIndex: navigationShell.currentIndex,
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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, size: 23),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary, size: 24),
                label: 'Tổng quan',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined, size: 23),
                selectedIcon: Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                label: 'Dịch vụ',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined, size: 23),
                selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primary, size: 24),
                label: 'Yêu cầu',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, size: 24),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary, size: 25),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
