import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/theme_provider.dart';
import '../../admin/models/provider_application_model.dart';
import '../../admin/providers/admin_provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bookings/providers/booking_provider.dart';
import '../../notifications/widgets/notification_dropdown.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = authState.isAdmin;
    final isProvider = authState.isProvider;
    final isCustomer = authState.isAuthenticated && !isProvider && !isAdmin;
    final bookingCount = ref.watch(bookingProvider).length;
    final adminState = ref.watch(adminProvider);
    final lang = ref.watch(appLocaleProvider);
    String t(String key) => AppTranslations.translate(key, lang);

    ProviderApplicationModel? myApplication;
    if (user != null) {
      final cleanEmail = user.email.trim().toLowerCase();
      for (final a in adminState.applications) {
        if (a.userId == user.id || a.email.trim().toLowerCase() == cleanEmail) {
          myApplication = a;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(t('profile_title')),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: t('nav_settings'),
            icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
            onPressed: () => context.go('/settings'),
          ),
          Builder(
            builder: (btnCtx) => IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
              onPressed: () => showNotificationDropdown(btnCtx),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Luxury Profile Header Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    // Gradient Cover Top
                    Container(
                      height: 84,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient,
                      ),
                    ),

                    // Avatar & Details with negative offset
                    Transform.translate(
                      offset: const Offset(0, -42),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            if (user != null) ...[
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: AppColors.secondary,
                                      child: Text(
                                        user.fullName.isNotEmpty ? user.fullName.substring(0, 1).toUpperCase() : 'U',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: isAdmin
                                      ? const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF4F46E5)])
                                      : (isProvider ? AppColors.amberGradient : AppColors.primaryGradient),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isProvider ? Colors.amber : AppColors.primary).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  isAdmin
                                      ? '🛡️ Quản Trị Viên Hệ Thống'
                                      : (isProvider ? '⭐ Nhà Cung Cấp Dịch Vụ' : '👑 Thành Viên Sự Kiện'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Stats Strip
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      '$bookingCount',
                                      'Đơn đặt',
                                      () => context.go(isAdmin ? '/admin' : (isProvider ? '/provider/bookings' : '/bookings')),
                                    ),
                                    _buildStatDivider(),
                                    _buildStatItem('12', 'Yêu thích', () {}),
                                    _buildStatDivider(),
                                    _buildStatItem('5.0', 'Đánh giá', () {}),
                                    _buildStatDivider(),
                                    _buildStatItem('3', 'Voucher', () {}),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: CircleAvatar(
                                  radius: 38,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  child: const Icon(Icons.person_outline_rounded, size: 40, color: AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Khách ghé thăm',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Đăng nhập để theo dõi đơn đặt và trò chuyện cùng nhà cung cấp',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () => context.push('/login'),
                                  icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                                  label: const Text('Đăng nhập / Đăng ký', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Admin / Provider Quick Management Banner or Customer Upgrade Banner
            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF312E81)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E1B4B).withOpacity(0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Trung tâm Điều hành Quản trị viên',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kiểm duyệt dịch vụ đối tác, phê duyệt hồ sơ NCC và giám sát doanh thu SePay',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.dashboard_customize_rounded, size: 16),
                            label: const Text('Dashboard', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            onPressed: () => context.go('/admin'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.inventory_2_rounded, size: 16),
                            label: const Text('Duyệt Dịch vụ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            onPressed: () => context.go('/admin/products'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else if (isProvider)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Kênh Quản trị Nhà cung cấp',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Quản lý danh sách dịch vụ, duyệt đơn đặt của khách và báo cáo doanh thu',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.dashboard_rounded, size: 16),
                            label: const Text('Bàn làm việc', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            onPressed: () => context.go('/provider'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.inventory_2_rounded, size: 16),
                            label: const Text('Kho Dịch vụ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            onPressed: () => context.go('/provider/services'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else if (isCustomer && user != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _showBecomeProviderSheet(context, ref, user, myApplication),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: myApplication?.isPending == true
                          ? const Color(0xFFEEF2FF)
                          : (myApplication?.isRejected == true ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: myApplication?.isPending == true
                            ? const Color(0xFFC7D2FE)
                            : (myApplication?.isRejected == true ? const Color(0xFFFECACA) : const Color(0xFFFDE68A)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: myApplication?.isPending == true
                                ? const Color(0xFFE0E7FF)
                                : (myApplication?.isRejected == true ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            myApplication?.isPending == true
                                ? Icons.hourglass_top_rounded
                                : (myApplication?.isRejected == true ? Icons.refresh_rounded : Icons.star_rounded),
                            color: myApplication?.isPending == true
                                ? AppColors.primary
                                : (myApplication?.isRejected == true ? AppColors.error : const Color(0xFFD97706)),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                myApplication?.isPending == true
                                    ? 'Hồ sơ Đối tác NCC đang chờ duyệt ⏳'
                                    : (myApplication?.isRejected == true
                                        ? 'Hồ sơ NCC cần bổ sung (Nhấn gửi lại)'
                                        : 'Trở thành Nhà cung cấp'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: myApplication?.isPending == true
                                      ? const Color(0xFF312E81)
                                      : (myApplication?.isRejected == true ? const Color(0xFF991B1B) : const Color(0xFF92400E)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                myApplication?.isPending == true
                                    ? 'Thương hiệu: ${myApplication!.businessName} • Chờ Admin phê duyệt'
                                    : (myApplication?.isRejected == true
                                        ? 'Lý do: ${myApplication!.rejectionReason ?? 'Cần cập nhật lại thông tin hồ sơ'}'
                                        : 'Đăng ký mở gian hàng sự kiện & tiếp cận hàng ngàn khách hàng'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: myApplication?.isPending == true
                                      ? AppColors.primary
                                      : (myApplication?.isRejected == true ? AppColors.error : const Color(0xFFB45309)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: myApplication?.isPending == true
                              ? AppColors.primary
                              : (myApplication?.isRejected == true ? AppColors.error : const Color(0xFFD97706)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Settings & Actions Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Thông tin cá nhân & Liên hệ',
                    subtitle: 'Cập nhật số điện thoại, địa chỉ',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Bảo mật & Mật khẩu',
                    subtitle: 'Quản lý mật khẩu và phiên đăng nhập',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Trung tâm thông báo',
                    subtitle: 'Tin tức đơn đặt & khuyến mãi',
                    onTap: () => showNotificationDropdown(context),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  if (isAdmin)
                    _buildMenuItem(
                      icon: Icons.forum_rounded,
                      title: 'Hộp thư Hỗ trợ Khách hàng & NCC',
                      subtitle: 'Phản hồi tin nhắn hỗ trợ trực tuyến toàn sàn',
                      onTap: () => context.push('/admin/support-chat'),
                    )
                  else
                    _buildMenuItem(
                      icon: Icons.support_agent_rounded,
                      title: 'Hỗ trợ kỹ thuật 24/7',
                      subtitle: 'Hotline 1900 6868 hoặc chat trực tiếp với Admin',
                      onTap: () => context.push('/chat/system'),
                    ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      final currentMode = ref.watch(themeModeProvider);
                      final isDark = currentMode == ThemeMode.dark;
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: isDark ? const Color(0xFFFBBF24) : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: const Text('Giao diện tối (Dark Mode)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(
                          isDark ? 'Đang bật nền tối bảo vệ mắt' : 'Đang dùng nền sáng tiêu chuẩn',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Switch.adaptive(
                          value: isDark,
                          activeColor: AppColors.primary,
                          onChanged: (_) {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.tune_rounded,
                    title: t('profile_settings_menu'),
                    subtitle: lang == AppLanguage.en
                        ? 'Language (EN/VI) & Background color'
                        : 'Đổi ngôn ngữ (Anh/Việt) & màu nền',
                    onTap: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            if (user != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 1.2),
                    backgroundColor: const Color(0xFFFEF2F2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Đăng xuất tài khoản', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Xác nhận đăng xuất', style: TextStyle(fontWeight: FontWeight.w800)),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng EventHub?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await ref.read(authProvider.notifier).logout();
                              if (context.mounted) context.go('/login');
                            },
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _buildStatItem(String count, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 22,
      color: const Color(0xFFE2E8F0),
    );
  }

  void _showBecomeProviderSheet(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    ProviderApplicationModel? existingApp,
  ) {
    final formKey = GlobalKey<FormState>();
    final bizController = TextEditingController(text: existingApp?.businessName ?? '');
    final phoneController = TextEditingController(text: existingApp?.phoneNumber ?? user.phoneNumber ?? '0901234567');
    final cityController = TextEditingController(text: existingApp?.city ?? 'Hà Nội');
    final addressController = TextEditingController(text: existingApp?.address ?? 'Văn phòng đối tác EventHub');
    final taxController = TextEditingController(text: existingApp?.taxOrIdNumber ?? '');
    final descController = TextEditingController(
      text: existingApp?.description ??
          'Cam kết cung cấp dịch vụ sự kiện chuyên nghiệp, đúng tiến độ và đạt chuẩn chất lượng EventHub.',
    );
    String selectedCategory = existingApp?.category ?? 'Trang trí sự kiện';
    const categories = [
      'Trang trí sự kiện',
      'Chụp ảnh & Quay phim',
      'Ẩm thực & Catering',
      'Địa điểm & Hội trường',
      'Âm thanh & Ánh sáng',
      'MC & Nhân sự sự kiện',
    ];
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đăng ký Đối tác Nhà cung cấp',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Hồ sơ sẽ được Admin xét duyệt để mở Kênh Nhà cung cấp',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetCtx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: bizController,
                        decoration: const InputDecoration(
                          labelText: 'Tên thương hiệu / Doanh nghiệp *',
                          hintText: 'VD: Hoa Tươi & Sự Kiện Minh Châu',
                          prefixIcon: Icon(Icons.business_rounded, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên thương hiệu' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Lĩnh vực dịch vụ chính *',
                          prefixIcon: Icon(Icons.category_outlined, size: 20),
                        ),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) {
                          if (v != null) setModalState(() => selectedCategory = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Số điện thoại *',
                                prefixIcon: Icon(Icons.phone_outlined, size: 20),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập SĐT' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: cityController,
                              decoration: const InputDecoration(
                                labelText: 'Tỉnh / Thành phố *',
                                prefixIcon: Icon(Icons.location_city_rounded, size: 20),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập Tỉnh/TP' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ văn phòng / cửa hàng',
                          prefixIcon: Icon(Icons.place_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: taxController,
                        decoration: const InputDecoration(
                          labelText: 'Mã số thuế / Số CCCD đại diện',
                          hintText: 'VD: 0109876543',
                          prefixIcon: Icon(Icons.verified_user_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Giới thiệu năng lực & kinh nghiệm *',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng mô tả năng lực' : null,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            ref.read(adminProvider.notifier).submitApplication(
                                  userId: user.id,
                                  applicantName: user.fullName,
                                  businessName: bizController.text.trim(),
                                  email: user.email,
                                  phoneNumber: phoneController.text.trim(),
                                  category: selectedCategory,
                                  address: addressController.text.trim().isNotEmpty
                                      ? addressController.text.trim()
                                      : 'Văn phòng đối tác EventHub',
                                  city: cityController.text.trim(),
                                  description: descController.text.trim(),
                                  taxOrIdNumber: taxController.text.trim().isNotEmpty ? taxController.text.trim() : null,
                                );
                            Navigator.pop(sheetCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã gửi hồ sơ Đối tác Nhà cung cấp tới Admin chờ phê duyệt!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            existingApp?.isPending == true
                                ? 'Cập nhật hồ sơ chờ Admin duyệt'
                                : 'Gửi hồ sơ chờ Admin phê duyệt',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
