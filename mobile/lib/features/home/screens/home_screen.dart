import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bookings/models/booking_model.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/widgets/notification_dropdown.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../services/providers/product_approval_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  final String _selectedCity = 'Hà Nội & TP. HCM';

  final List<Map<String, String>> _banners = [
    {
      'tag': 'Ưu đãi tháng này 🔥',
      'title': 'Lên kế hoạch sự kiện trọn gói\nTiết kiệm đến 25%',
      'subtitle': 'Áp dụng cho tiệc cưới, thôi nôi & kỷ niệm',
      'btnText': 'Khám phá ngay',
      'category': 'Trang trí sự kiện',
      'imageUrl': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'tag': 'Công nghệ 4K ✨',
      'title': 'Quay phim phóng sự & Flycam\nEkip chuyên nghiệp',
      'subtitle': 'Tặng gói dựng Highlight Clip 60s',
      'btnText': 'Xem chi tiết',
      'category': 'Chụp ảnh & Quay phim',
      'imageUrl': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'tag': 'Địa điểm VIP 🏛️',
      'title': 'Hội trường Grand Ballroom\nKhông gian tiệc đẳng cấp',
      'subtitle': 'Sức chứa lên tới 800 khách mời',
      'btnText': 'Đặt lịch xem',
      'category': 'Địa điểm & Hội trường',
      'imageUrl': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=1000&q=80',
    },
  ];

  final List<Map<String, dynamic>> _quickCategories = [
    {
      'title': 'Trang trí',
      'icon': Icons.palette_rounded,
      'color': Color(0xFF8E24AA),
      'bg': Color(0xFFF3E5F5),
      'catName': 'Trang trí sự kiện',
    },
    {
      'title': 'Quay chụp',
      'icon': Icons.camera_alt_rounded,
      'color': Color(0xFF1E88E5),
      'bg': Color(0xFFE3F2FD),
      'catName': 'Chụp ảnh & Quay phim',
    },
    {
      'title': 'Ẩm thực',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFE64A19),
      'bg': Color(0xFFFBE9E7),
      'catName': 'Ẩm thực & Catering',
    },
    {
      'title': 'Hội trường',
      'icon': Icons.apartment_rounded,
      'color': Color(0xFF2E7D32),
      'bg': Color(0xFFE8F5E9),
      'catName': 'Địa điểm & Hội trường',
    },
    {
      'title': 'Âm thanh',
      'icon': Icons.speaker_group_rounded,
      'color': Color(0xFFF57C00),
      'bg': Color(0xFFFFF3E0),
      'catName': 'Âm thanh & Ánh sáng',
    },
    {
      'title': 'MC & Vũ đoàn',
      'icon': Icons.mic_external_on_rounded,
      'color': Color(0xFF00897B),
      'bg': Color(0xFFE0F2F1),
      'catName': 'MC & Nhân sự sự kiện',
    },
    {
      'title': 'Hoa tươi',
      'icon': Icons.local_florist_rounded,
      'color': Color(0xFFD81B60),
      'bg': Color(0xFFFCE4EC),
      'catName': 'Trang trí sự kiện',
    },
    {
      'title': 'Tất cả',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF5E35B1),
      'bg': Color(0xFFEDE7F6),
      'catName': '',
    },
  ];

  final List<Map<String, dynamic>> _topProviders = [
    {
      'name': 'Ánh Dương Wedding & Decor',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'events': '180+ sự kiện',
      'rating': 4.9,
      'category': 'Trang trí tiệc cưới',
      'verified': true,
    },
    {
      'name': 'LensCraft Media Group',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      'events': '125+ sự kiện',
      'rating': 4.8,
      'category': 'Quay phim & Chụp ảnh',
      'verified': true,
    },
    {
      'name': 'Royal Catering Saigon',
      'avatar': 'https://images.unsplash.com/photo-1583394838336-acd977736f90?auto=format&fit=crop&w=200&q=80',
      'events': '210+ tiệc tiệc',
      'rating': 5.0,
      'category': 'Ẩm thực cao cấp',
      'verified': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoSlide();
  }

  void _startBannerAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final notifState = ref.watch(notificationProvider);
    final unreadCount = user != null ? notifState.unreadCount : 0;
    final successBooking = notifState.activeHomeSuccessBooking;

    final approvedCatalog = ref.watch(productApprovalProvider).approvedPublicCatalog;
    final trendingItems = approvedCatalog.take(6).map((p) {
      final isNewlyApproved = !p.id.startsWith('s') && p.id != 'ps1';
      final city = p.id == 's4'
          ? 'Đà Nẵng'
          : ((p.id == 's2' || p.id == 's3' || p.id == 's6') ? 'TP. Hồ Chí Minh' : 'Hà Nội');
      final badge = isNewlyApproved
          ? 'Mới ra mắt ✨'
          : (p.id == 's4' ? 'Hot Deal 🔥' : (p.id == 's3' ? 'Yêu thích ❤️' : 'Giảm 20%'));
      return <String, dynamic>{
        'id': p.id,
        'title': p.title,
        'provider': p.providerName,
        'price': p.price,
        'oldPrice': BookingModel.formatVnd((p.priceNum * 1.2).round()),
        'rating': p.rating,
        'reviews': p.reviewsCount,
        'city': city,
        'badge': badge,
        'imageUrl': p.imageUrl,
      };
    }).toList();

    final lang = ref.watch(appLocaleProvider);
    String t(String key) => AppTranslations.translate(key, lang);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Elegant Custom Sliver AppBar with greeting and search
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF090D16),
                      Color(0xFF1E1B4B),
                      Color(0xFF2E1065),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Ambient decorative gradient orb
                    Positioned(
                      top: -40,
                      right: -30,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF7C3AED).withOpacity(0.25),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -20,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4338CA).withOpacity(0.2),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Greeting Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left User Info
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFF59E0B).withOpacity(0.4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: const Color(0xFF1E293B),
                                          child: user != null && user.fullName.isNotEmpty
                                              ? Text(
                                                  user.fullName.substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16,
                                                  ),
                                                )
                                              : const Icon(Icons.person, color: Colors.white, size: 22),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              user != null
                                                  ? (lang == AppLanguage.en ? 'Hello, ${user.fullName} 👋' : 'Chào, ${user.fullName} 👋')
                                                  : (lang == AppLanguage.en ? 'Welcome to EventHub 👋' : 'Chào mừng bạn 👋'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFFFBBF24)),
                                                const SizedBox(width: 3),
                                                Flexible(
                                                  child: Text(
                                                    _selectedCity,
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.85),
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white70),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Action Buttons (Login, Admin Shortcut, or Notifications)
                                if (user != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (user.isAdmin) ...[
                                        InkWell(
                                          onTap: () => context.go('/admin'),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF6366F1).withOpacity(0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.admin_panel_settings_rounded, size: 14, color: Colors.white),
                                                SizedBox(width: 4),
                                                Text(
                                                  'QL Admin',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      // Theme Mode Quick Toggle
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final themeMode = ref.watch(themeModeProvider);
                                          final isDark = themeMode == ThemeMode.dark;
                                          return Container(
                                            margin: const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.12),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                                            ),
                                            child: IconButton(
                                              tooltip: isDark ? 'Chế độ Sáng' : 'Chế độ Tối',
                                              icon: Icon(
                                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                                color: isDark ? const Color(0xFFFBBF24) : Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                ref.read(themeModeProvider.notifier).toggleTheme();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                                        ),
                                        child: Builder(
                                          builder: (btnCtx) => IconButton(
                                            tooltip: 'Thông báo',
                                            icon: Badge(
                                              isLabelVisible: unreadCount > 0,
                                              backgroundColor: const Color(0xFFEF4444),
                                              label: Text(
                                                '$unreadCount',
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                              child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                            ),
                                            onPressed: () => showNotificationDropdown(btnCtx),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Theme Mode Quick Toggle
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final themeMode = ref.watch(themeModeProvider);
                                          final isDark = themeMode == ThemeMode.dark;
                                          return Container(
                                            margin: const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.12),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                                            ),
                                            child: IconButton(
                                              tooltip: isDark ? 'Chế độ Sáng' : 'Chế độ Tối',
                                              icon: Icon(
                                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                                color: isDark ? const Color(0xFFFBBF24) : Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                ref.read(themeModeProvider.notifier).toggleTheme();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                                        ),
                                        child: Builder(
                                          builder: (btnCtx) => IconButton(
                                            tooltip: 'Thông báo',
                                            icon: Badge(
                                              isLabelVisible: unreadCount > 0,
                                              backgroundColor: const Color(0xFFEF4444),
                                              label: Text(
                                                '$unreadCount',
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                              child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                                            ),
                                            onPressed: () => showNotificationDropdown(btnCtx),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF6366F1).withOpacity(0.4),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            shadowColor: Colors.transparent,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                            minimumSize: const Size(0, 36),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          ),
                                          onPressed: () => context.push('/login'),
                                          icon: const Icon(Icons.login_rounded, size: 14),
                                          label: Text(t('home_login_now'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating Search Bar at the bottom of SliverAppBar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(66),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: GestureDetector(
                  onTap: () => context.push('/services'),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t('home_search_placeholder'),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFC7D2FE), width: 0.8),
                          ),
                          child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (successBooking != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF34D399), width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Đặt đơn thành công! 🎉',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Đơn ${successBooking.code} • ${successBooking.serviceTitle} (${successBooking.price}) đã thanh toán SePay thành công.',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF047857),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () {
                                  ref.read(notificationProvider.notifier).dismissHomeSuccessBanner();
                                  GoRouter.maybeOf(context)?.go('/bookings');
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Xem đơn đã xác nhận',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF065F46),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF065F46)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Đóng thông báo',
                          icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF065F46)),
                          onPressed: () => ref.read(notificationProvider.notifier).dismissHomeSuccessBanner(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),

                // Interactive Promotional Banner Carousel
                SizedBox(
                  height: 165,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final item = _banners[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.18),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  item['imageUrl']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: AppColors.primary),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF1E1B4B).withOpacity(0.92),
                                        AppColors.primary.withOpacity(0.75),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.65, 1.0],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.22),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item['tag']!,
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: () => context.push('/services?category=${item['category']}'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            item['btnText']!,
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
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
                  ),
                ),

                // Carousel Dots Indicator
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_banners.length, (i) {
                    final isActive = i == _currentBannerIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Quick Categories (Grid of 8 rounded icon pills)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          t('home_categories_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.go('/categories'),
                        child: Text(
                          '${t('home_view_all')} ➔',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 108,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _quickCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final cat = _quickCategories[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (cat['catName'] == '') {
                            context.go('/categories');
                          } else {
                            context.push('/services?category=${cat['catName']}');
                          }
                        },
                        child: SizedBox(
                          width: 78,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: (cat['bg'] as Color).withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (cat['color'] as Color).withOpacity(0.16),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 30),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                cat['title'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                // Trending Services (Horizontal Cards)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECE0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFE64A19), size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t('home_trending_title'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/services'),
                        child: const Text(
                          'Xem thêm',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Carousel of Trending Services
                SizedBox(
                  height: 255,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = trendingItems[index];
                      final itemId = item['id'] as String;
                      final isFav = ref.watch(favoritesProvider).contains(itemId);
                      return GestureDetector(
                        onTap: () => context.push('/services/${item['id']}'),
                        child: Container(
                          width: 230,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image with Badge
                              Stack(
                                children: [
                                  EventNetworkImage(
                                    imageUrl: item['imageUrl'] as String,
                                    width: 230,
                                    height: 130,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4F46E5).withOpacity(0.35),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        item['badge'] as String,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: InkWell(
                                      onTap: () {
                                        final nowFav = ref.read(favoritesProvider.notifier).toggleFavorite(itemId);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              nowFav
                                                  ? 'Đã thêm "${item['title']}" vào yêu thích ❤️'
                                                  : 'Đã bỏ yêu thích "${item['title']}"',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                          size: 16,
                                          color: isFav ? const Color(0xFFEF4444) : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item['provider'] as String,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${item['rating']}',
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            item['city'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item['price'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            item['oldPrice'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textMuted,
                                              decoration: TextDecoration.lineThrough,
                                            ),
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
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Top Verified Providers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t('home_top_providers'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 125,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _topProviders.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final p = _topProviders[index];
                      return Container(
                        width: 230,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    p['avatar'] as String,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 56,
                                      height: 56,
                                      color: AppColors.secondary,
                                      child: const Icon(Icons.storefront, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified, size: 14, color: Color(0xFF1E88E5)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    p['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p['category'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text('${p['rating']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '• ${p['events']}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 26),

                // Featured Services Feed Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          t('home_all_services'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/services'),
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Vertical Rich Cards Feed
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildRichServiceCard(
                        context,
                        id: 's1',
                        title: 'Gói Trang trí Tiệc Cưới Phong Cách Rustic Sang Trọng',
                        provider: 'Ánh Dương Wedding & Decor',
                        price: '15.000.000 ₫',
                        rating: 4.9,
                        reviews: 28,
                        city: 'Hà Nội',
                        tag: 'Trang trí',
                        imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80',
                      ),
                      _buildRichServiceCard(
                        context,
                        id: 's2',
                        title: 'Quay Phim & Chụp Ảnh Sự Kiện Doanh Nghiệp 4K',
                        provider: 'LensCraft Media Group',
                        price: '8.500.000 ₫',
                        rating: 4.8,
                        reviews: 19,
                        city: 'TP. Hồ Chí Minh',
                        tag: 'Quay chụp',
                        imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
                      ),
                      _buildRichServiceCard(
                        context,
                        id: 's3',
                        title: 'Buffet Tiệc Cao Cấp & Tiệc Trà Teabreak Chuẩn 5 Sao',
                        provider: 'Royal Catering Saigon',
                        price: '350.000 ₫ / khách',
                        rating: 4.9,
                        reviews: 35,
                        city: 'TP. Hồ Chí Minh',
                        tag: 'Ẩm thực',
                        imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
                      ),
                      _buildRichServiceCard(
                        context,
                        id: 's4',
                        title: 'Hội Trường Sự Kiện & Hội Nghị Grand Ballroom Sức Chứa 800 Khách',
                        provider: 'Skyline Convention Hall',
                        price: '25.000.000 ₫',
                        rating: 5.0,
                        reviews: 42,
                        city: 'Đà Nẵng',
                        tag: 'Hội trường',
                        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quality & Trust Guarantee Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cam kết dịch vụ từ EventHub',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildGuaranteeItem(Icons.verified_user_outlined, '100% Xác thực\nNhà cung cấp'),
                            _buildGuaranteeItem(Icons.security_rounded, 'Bảo vệ thanh toán\nAn toàn tuyệt đối'),
                            _buildGuaranteeItem(Icons.headset_mic_outlined, 'Hỗ trợ 24/7\nĐồng hành cùng bạn'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: authState.isProvider
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.storefront_rounded),
              label: const Text('Kênh nhà cung cấp'),
              onPressed: () => context.go('/provider'),
            )
          : null,
    );
  }

  Widget _buildRichServiceCard(
    BuildContext context, {
    required String id,
    required String title,
    required String provider,
    required String price,
    required double rating,
    required int reviews,
    required String city,
    required String tag,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/services/$id'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    EventNetworkImage(
                      imageUrl: imageUrl,
                      width: 100,
                      height: 100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              provider,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                                const SizedBox(width: 2),
                                Text(
                                  '$rating',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviews)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    city,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
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
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Chi tiết',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primary),
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
      ),
    );
  }

  Widget _buildGuaranteeItem(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.25),
          ),
        ],
      ),
    );
  }
}
