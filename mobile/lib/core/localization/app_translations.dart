import 'app_locale_provider.dart';

class AppTranslations {
  static const Map<String, Map<AppLanguage, String>> _dict = {
    // Navigation Bottom Bar
    'nav_explore': {
      AppLanguage.vi: 'Khám phá',
      AppLanguage.en: 'Explore',
    },
    'nav_categories': {
      AppLanguage.vi: 'Danh mục',
      AppLanguage.en: 'Categories',
    },
    'nav_bookings': {
      AppLanguage.vi: 'Đơn đặt',
      AppLanguage.en: 'Bookings',
    },
    'nav_account': {
      AppLanguage.vi: 'Tài khoản',
      AppLanguage.en: 'Account',
    },
    'nav_settings': {
      AppLanguage.vi: 'Cài đặt',
      AppLanguage.en: 'Settings',
    },

    // Settings Screen
    'settings_title': {
      AppLanguage.vi: 'Cài đặt hệ thống',
      AppLanguage.en: 'System Settings',
    },
    'settings_subtitle': {
      AppLanguage.vi: 'Tuỳ chỉnh ngôn ngữ & giao diện người dùng',
      AppLanguage.en: 'Customize language & user interface',
    },
    'settings_language_section': {
      AppLanguage.vi: 'Ngôn ngữ hiển thị',
      AppLanguage.en: 'Display Language',
    },
    'settings_language_desc': {
      AppLanguage.vi: 'Chọn ngôn ngữ cho toàn bộ ứng dụng',
      AppLanguage.en: 'Choose language for entire application',
    },
    'settings_lang_vi': {
      AppLanguage.vi: 'Tiếng Việt',
      AppLanguage.en: 'Vietnamese',
    },
    'settings_lang_en': {
      AppLanguage.vi: 'Tiếng Anh (English)',
      AppLanguage.en: 'English',
    },
    'settings_bgcolor_section': {
      AppLanguage.vi: 'Màu nền ứng dụng',
      AppLanguage.en: 'Background Color',
    },
    'settings_bgcolor_desc': {
      AppLanguage.vi: 'Chỉ đổi màu nền, giữ nguyên màu chữ & màu nút',
      AppLanguage.en: 'Changes background only, preserves text & button colors',
    },
    'settings_color_white': {
      AppLanguage.vi: 'Trắng (Mặc định)',
      AppLanguage.en: 'White (Default)',
    },
    'settings_color_gray': {
      AppLanguage.vi: 'Xám',
      AppLanguage.en: 'Gray',
    },
    'settings_color_blue': {
      AppLanguage.vi: 'Xanh dương',
      AppLanguage.en: 'Blue',
    },
    'settings_color_green': {
      AppLanguage.vi: 'Xanh lá',
      AppLanguage.en: 'Green',
    },
    'settings_color_red': {
      AppLanguage.vi: 'Đỏ',
      AppLanguage.en: 'Red',
    },
    'settings_color_yellow': {
      AppLanguage.vi: 'Vàng',
      AppLanguage.en: 'Yellow',
    },
    'settings_darkmode_section': {
      AppLanguage.vi: 'Giao diện tối (Dark Mode)',
      AppLanguage.en: 'Dark Mode Appearance',
    },
    'settings_darkmode_desc': {
      AppLanguage.vi: 'Bật nền tối để bảo vệ mắt ban đêm',
      AppLanguage.en: 'Enable dark theme for nighttime viewing',
    },
    'settings_preview_title': {
      AppLanguage.vi: 'Xem trước màu nền đang chọn',
      AppLanguage.en: 'Active Background Preview',
    },
    'settings_active_badge': {
      AppLanguage.vi: 'Đang áp dụng',
      AppLanguage.en: 'Applied',
    },
    'settings_app_info': {
      AppLanguage.vi: 'Thông tin phiên bản',
      AppLanguage.en: 'App Version Information',
    },
    'settings_version_tag': {
      AppLanguage.vi: 'EventHub v2.4.0 • Nền tảng kết nối dịch vụ sự kiện',
      AppLanguage.en: 'EventHub v2.4.0 • Event Service Platform',
    },

    // Home Screen
    'home_search_placeholder': {
      AppLanguage.vi: 'Tìm trang trí, chụp ảnh, tiệc cưới, hội trường...',
      AppLanguage.en: 'Search decor, photo, wedding, hall...',
    },
    'home_greeting_guest': {
      AppLanguage.vi: 'Chào mừng bạn!',
      AppLanguage.en: 'Welcome!',
    },
    'home_login_now': {
      AppLanguage.vi: 'Đăng nhập',
      AppLanguage.en: 'Sign In',
    },
    'home_categories_title': {
      AppLanguage.vi: 'Danh mục dịch vụ',
      AppLanguage.en: 'Service Categories',
    },
    'home_view_all': {
      AppLanguage.vi: 'Xem tất cả',
      AppLanguage.en: 'View All',
    },
    'home_trending_title': {
      AppLanguage.vi: 'Dịch vụ thịnh hành',
      AppLanguage.en: 'Trending Services',
    },
    'home_top_providers': {
      AppLanguage.vi: 'Nhà cung cấp uy tín hàng đầu',
      AppLanguage.en: 'Top Verified Providers',
    },
    'home_all_services': {
      AppLanguage.vi: 'Tất cả dịch vụ nổi bật',
      AppLanguage.en: 'All Featured Services',
    },
    'home_filter_btn': {
      AppLanguage.vi: 'Bộ lọc',
      AppLanguage.en: 'Filter',
    },
    'home_schedule_btn': {
      AppLanguage.vi: 'Đặt lịch xem',
      AppLanguage.en: 'Schedule Tour',
    },
    'home_explore_now': {
      AppLanguage.vi: 'Khám phá ngay',
      AppLanguage.en: 'Explore Now',
    },
    'home_new_badge': {
      AppLanguage.vi: 'Mới ra mắt',
      AppLanguage.en: 'New',
    },
    'home_countdown_title': {
      AppLanguage.vi: 'Đếm ngược sự kiện',
      AppLanguage.en: 'Event Countdown',
    },

    // Categories Screen
    'cat_title': {
      AppLanguage.vi: 'Tất cả danh mục',
      AppLanguage.en: 'All Categories',
    },
    'cat_search': {
      AppLanguage.vi: 'Tìm kiếm danh mục sự kiện...',
      AppLanguage.en: 'Search event categories...',
    },

    // Bookings Screen
    'book_title': {
      AppLanguage.vi: 'Đơn đặt của tôi',
      AppLanguage.en: 'My Bookings',
    },
    'book_tab_all': {
      AppLanguage.vi: 'Tất cả',
      AppLanguage.en: 'All',
    },
    'book_tab_pending': {
      AppLanguage.vi: 'Chờ duyệt',
      AppLanguage.en: 'Pending',
    },
    'book_tab_confirmed': {
      AppLanguage.vi: 'Đã xác nhận',
      AppLanguage.en: 'Confirmed',
    },
    'book_tab_completed': {
      AppLanguage.vi: 'Hoàn thành',
      AppLanguage.en: 'Completed',
    },
    'book_tab_cancelled': {
      AppLanguage.vi: 'Đã hủy',
      AppLanguage.en: 'Cancelled',
    },
    'book_calendar_btn': {
      AppLanguage.vi: 'Thêm vào Google Calendar',
      AppLanguage.en: 'Add to Google Calendar',
    },

    // Profile Screen
    'profile_title': {
      AppLanguage.vi: 'Tài khoản của tôi',
      AppLanguage.en: 'My Account',
    },
    'profile_guest_title': {
      AppLanguage.vi: 'Khách ghé thăm',
      AppLanguage.en: 'Guest Visitor',
    },
    'profile_guest_subtitle': {
      AppLanguage.vi: 'Đăng nhập để theo dõi đơn đặt và trò chuyện cùng nhà cung cấp',
      AppLanguage.en: 'Log in to track bookings and chat with event providers',
    },
    'profile_login_btn': {
      AppLanguage.vi: 'Đăng nhập / Đăng ký',
      AppLanguage.en: 'Login / Register',
    },
    'profile_stat_bookings': {
      AppLanguage.vi: 'Đơn đặt',
      AppLanguage.en: 'Bookings',
    },
    'profile_stat_favorites': {
      AppLanguage.vi: 'Yêu thích',
      AppLanguage.en: 'Favorites',
    },
    'profile_stat_reviews': {
      AppLanguage.vi: 'Đánh giá',
      AppLanguage.en: 'Reviews',
    },
    'profile_stat_vouchers': {
      AppLanguage.vi: 'Voucher',
      AppLanguage.en: 'Vouchers',
    },
    'profile_personal_info': {
      AppLanguage.vi: 'Thông tin cá nhân & Liên hệ',
      AppLanguage.en: 'Personal Information & Contact',
    },
    'profile_security': {
      AppLanguage.vi: 'Bảo mật & Mật khẩu',
      AppLanguage.en: 'Security & Password',
    },
    'profile_notif_center': {
      AppLanguage.vi: 'Trung tâm thông báo',
      AppLanguage.en: 'Notification Center',
    },
    'profile_tech_support': {
      AppLanguage.vi: 'Hỗ trợ kỹ thuật 24/7',
      AppLanguage.en: '24/7 Technical Support',
    },
    'profile_settings_menu': {
      AppLanguage.vi: 'Cài đặt (Ngôn ngữ & Màu nền)',
      AppLanguage.en: 'Settings (Language & Background)',
    },
    'profile_logout_btn': {
      AppLanguage.vi: 'Đăng xuất tài khoản',
      AppLanguage.en: 'Log Out Account',
    },
    // Favorites / Wishlist
    'favorites_title': {
      AppLanguage.vi: 'Dịch vụ yêu thích',
      AppLanguage.en: 'Favorite Services',
    },
    'favorites_subtitle': {
      AppLanguage.vi: 'Các dịch vụ bạn đã lưu để lên kế hoạch sự kiện',
      AppLanguage.en: 'Services you saved for event planning',
    },
    'favorites_saved_count': {
      AppLanguage.vi: 'dịch vụ đã lưu',
      AppLanguage.en: 'saved services',
    },
    'favorites_clear_all': {
      AppLanguage.vi: 'Xóa tất cả',
      AppLanguage.en: 'Clear All',
    },
    'favorites_clear_confirm_title': {
      AppLanguage.vi: 'Xóa danh sách yêu thích?',
      AppLanguage.en: 'Clear all favorites?',
    },
    'favorites_clear_confirm_desc': {
      AppLanguage.vi: 'Bạn có chắc muốn xóa tất cả dịch vụ khỏi danh sách yêu thích?',
      AppLanguage.en: 'Are you sure you want to remove all saved services?',
    },
    'favorites_empty_title': {
      AppLanguage.vi: 'Chưa có dịch vụ yêu thích',
      AppLanguage.en: 'No favorites yet',
    },
    'favorites_empty_desc': {
      AppLanguage.vi: 'Nhấn vào biểu tượng trái tim ❤️ ở bất kỳ dịch vụ nào để lưu lại danh sách cần tham khảo.',
      AppLanguage.en: 'Tap the heart ❤️ icon on any service card to save it for later reference.',
    },
    'favorites_explore_btn': {
      AppLanguage.vi: 'Khám phá dịch vụ ngay',
      AppLanguage.en: 'Explore Services Now',
    },
    'btn_cancel': {
      AppLanguage.vi: 'Hủy',
      AppLanguage.en: 'Cancel',
    },
  };

  static String translate(String key, AppLanguage language) {
    final entry = _dict[key];
    if (entry == null) return key;
    return entry[language] ?? entry[AppLanguage.vi] ?? key;
  }
}

