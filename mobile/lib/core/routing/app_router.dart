import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/screens/admin_applications_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_product_approval_screen.dart';
import '../../features/admin/screens/admin_product_detail_screen.dart';
import '../../features/admin/screens/admin_support_chat_detail_screen.dart';
import '../../features/admin/screens/admin_support_chat_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/bookings/models/booking_model.dart';
import '../../features/bookings/providers/booking_provider.dart';
import '../../features/bookings/screens/booking_detail_screen.dart';
import '../../features/bookings/screens/create_booking_screen.dart';
import '../../features/bookings/screens/my_bookings_screen.dart';
import '../../features/bookings/screens/sepay_payment_screen.dart';
import '../../features/bookings/screens/momo_payment_screen.dart';
import '../../features/categories/screens/categories_screen.dart';
import '../../features/chat/screens/chat_conversation_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/user_system_chat_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/provider/screens/provider_bookings_screen.dart';
import '../../features/provider/screens/provider_dashboard_screen.dart';
import '../../features/provider/screens/provider_services_screen.dart';
import '../../features/services/screens/service_detail_screen.dart';
import '../../features/services/screens/service_list_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/main_scaffold_shell.dart';
import '../../shared/widgets/provider_scaffold_shell.dart';
import '../../shared/widgets/admin_scaffold_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Customer Navigation Shell (4 tabs: Khám phá, Danh mục, Đơn đặt, Tài khoản)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffoldShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const MyBookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Provider Navigation Shell (4 tabs: Tổng quan, Dịch vụ, Yêu cầu đơn, Tài khoản)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ProviderScaffoldShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/provider',
                builder: (context, state) => const ProviderDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/provider/services',
                builder: (context, state) => const ProviderServicesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/provider/bookings',
                builder: (context, state) => const ProviderBookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/provider/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Admin Navigation Shell (4 tabs: Tổng quan, Người dùng, Đơn xin NCC, Tài khoản)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminScaffoldShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/users',
                builder: (context, state) => const AdminUsersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/applications',
                builder: (context, state) => const AdminApplicationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/products',
                builder: (context, state) => const AdminProductApprovalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Detail Routes
      GoRoute(
        path: '/services',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final cat = state.uri.queryParameters['category'];
          return ServiceListScreen(initialCategory: cat);
        },
      ),
      GoRoute(
        path: '/services/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ServiceDetailScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: '/services/:id/book',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final pkgId = state.uri.queryParameters['pkgId'];
          final pkgName = state.uri.queryParameters['pkgName'];
          final price = state.uri.queryParameters['price'];
          return CreateBookingScreen(
            serviceId: id,
            packageId: pkgId,
            packageName: pkgName,
            packagePrice: price,
          );
        },
      ),
      GoRoute(
        path: '/bookings/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BookingDetailScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/bookings/:id/sepay',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extraBooking = state.extra as BookingModel?;
          if (extraBooking != null) {
            return SepayPaymentScreen(booking: extraBooking);
          }
          final bookings = ProviderScope.containerOf(context).read(bookingProvider);
          final booking = bookings.firstWhere(
            (b) => b.id == id,
            orElse: () => BookingModel(
              id: id,
              code: id,
              serviceId: '',
              serviceTitle: 'Đơn đặt dịch vụ',
              providerName: '',
              packageName: 'Tiêu chuẩn',
              date: '',
              time: '',
              price: '0 ₫',
              rawPrice: 0,
              status: 'Accepted',
              imageUrl: '',
              location: '',
              guestCount: '0',
              customerName: '',
              customerPhone: '',
              createdAt: DateTime.now(),
            ),
          );
          return SepayPaymentScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/bookings/:id/momo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extraBooking = state.extra as BookingModel?;
          if (extraBooking != null) {
            return MomoPaymentScreen(booking: extraBooking);
          }
          final bookings = ProviderScope.containerOf(context).read(bookingProvider);
          final booking = bookings.firstWhere(
            (b) => b.id == id,
            orElse: () => BookingModel(
              id: id,
              code: id,
              serviceId: '',
              serviceTitle: 'Đơn đặt dịch vụ',
              providerName: '',
              packageName: 'Tiêu chuẩn',
              date: '',
              time: '',
              price: '0 ₫',
              rawPrice: 0,
              status: 'Accepted',
              imageUrl: '',
              location: '',
              guestCount: '0',
              customerName: '',
              customerPhone: '',
              createdAt: DateTime.now(),
            ),
          );
          return MomoPaymentScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/provider/chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/system',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UserSystemChatScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id == 'system' || id.startsWith('sys-conv-')) {
            return const UserSystemChatScreen();
          }
          return ChatConversationScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/admin/support-chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminSupportChatScreen(),
      ),
      GoRoute(
        path: '/admin/support-chat/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AdminSupportChatDetailScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/admin/products/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AdminProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
