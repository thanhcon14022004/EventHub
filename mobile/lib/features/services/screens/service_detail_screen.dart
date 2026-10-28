import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/event_countdown_timer.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bookings/models/booking_model.dart';
import '../models/product_model.dart';
import '../providers/product_approval_provider.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  int _selectedPackageIndex = 0;

  List<Map<String, dynamic>> _buildPackages(ProductModel product) {
    if (product.packages.isNotEmpty) {
      return List.generate(product.packages.length, (idx) {
        final p = product.packages[idx];
        final digits = p.price.replaceAll(RegExp(r'[^0-9]'), '');
        final rawVal = int.tryParse(digits) ?? product.priceNum.round();
        return <String, dynamic>{
          'id': '${product.id}-pkg-${idx + 1}',
          'name': p.name,
          'price': p.price.isNotEmpty ? p.price : BookingModel.formatVnd(rawVal),
          'priceVal': rawVal,
          'duration': idx == 0 ? '4 giờ' : '6 giờ',
          'guests': idx == 0 ? 'Dưới 100 khách' : 'Dưới 250 khách',
          'features': p.includes.isNotEmpty
              ? p.includes
              : <String>[p.description.isNotEmpty ? p.description : 'Trọn gói dịch vụ tiêu chuẩn EventHub'],
        };
      });
    }

    final baseRaw = product.priceNum.round() > 0 ? product.priceNum.round() : 10000000;
    final vipRaw = (baseRaw * 1.4).round();
    return [
      {
        'id': '${product.id}-pkg-1',
        'name': 'Gói Tiêu Chuẩn (Standard)',
        'price': BookingModel.formatVnd(baseRaw),
        'priceVal': baseRaw,
        'duration': '4 giờ',
        'guests': 'Dưới 100 khách',
        'features': <String>[
          'Thiết kế & triển khai trọn gói ${product.category.toLowerCase()}',
          'Khảo sát mặt bằng thực tế & tư vấn kịch bản miễn phí',
          'Đội ngũ kỹ thuật viên điều phối suốt thời lượng sự kiện',
        ],
      },
      {
        'id': '${product.id}-pkg-2',
        'name': 'Gói Cao Cấp (Premium VIP)',
        'price': BookingModel.formatVnd(vipRaw),
        'priceVal': vipRaw,
        'duration': '6 giờ',
        'guests': 'Dưới 250 khách',
        'features': <String>[
          'Nâng cấp toàn diện quy mô & vật tư cao cấp từ Gói Tiêu Chuẩn',
          'Thiết kế cá nhân hóa theo concept riêng của chủ tiệc',
          'Nhân sự giám sát & hậu cần túc trực 100% thời gian tiệc',
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productApprovalProvider).resolveServiceById(widget.serviceId);
    final packages = _buildPackages(product);
    final safeIndex = _selectedPackageIndex.clamp(0, packages.length - 1);
    final selectedPkg = packages[safeIndex];
    final gallery = product.galleryUrls.isNotEmpty ? product.galleryUrls : <String>[product.imageUrl];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with hero image
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: AppColors.primary),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  EventNetworkImage(
                    imageUrl: product.imageUrl,
                    borderRadius: BorderRadius.zero,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Service Title
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating and City
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewsCount} đánh giá)',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      const Expanded(
                        child: Text(
                          'Toàn quốc & lân cận',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Countdown Timer to next event session
                  EventCountdownTimer(
                    targetDate: DateTime.now().add(const Duration(days: 3, hours: 8, minutes: 25)),
                    eventName: product.title,
                  ),
                  const SizedBox(height: 18),

                  // Provider Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.storefront, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.providerName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Nhà cung cấp đã xác minh ✓',
                                style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(80, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () {
                            final isAuth = ref.read(authProvider).isAuthenticated;
                            if (!isAuth) {
                              _showLoginRequiredDialog(context);
                              return;
                            }
                            context.push('/chat/conv-provider-1');
                          },
                          child: const Text('Nhắn tin', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Packages Section
                  const Text(
                    'Chọn gói dịch vụ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: List.generate(packages.length, (index) {
                      final pkg = packages[index];
                      final isSelected = safeIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedPackageIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFF6366F1).withOpacity(0.12)
                                    : const Color(0xFF0F172A).withOpacity(0.04),
                                blurRadius: isSelected ? 16 : 10,
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
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      pkg['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: isSelected ? const Color(0xFF4338CA) : AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    pkg['price'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const SizedBox(width: 32),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(pkg['duration'], style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.groups_rounded, size: 12, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(pkg['guests'], style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              ...((pkg['features'] as List<String>).map((feat) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            feat,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'Mô tả chi tiết',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Dịch vụ sự kiện trọn gói cao cấp được kiểm duyệt và bảo chứng chất lượng bởi EventHub.',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Event Photo Gallery
                  const Text(
                    'Hình ảnh thực tế từ các sự kiện đã thực hiện',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => EventNetworkImage(
                        imageUrl: gallery[index],
                        width: 150,
                        height: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Booking Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng chi phí dự kiến', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                  Text(
                    selectedPkg['price'],
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -0.3),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Direct Chat with Provider circular button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  tooltip: 'Chat với nhà cung cấp',
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF475569), size: 20),
                  onPressed: () {
                    final authState = ref.read(authProvider);
                    if (!authState.isAuthenticated) {
                      _showLoginRequiredDialog(context);
                      return;
                    }
                    context.push('/chat/conv-provider-1');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.event_available_rounded, size: 18),
                    onPressed: () {
                      final authState = ref.read(authProvider);
                      if (!authState.isAuthenticated) {
                        _showLoginRequiredDialog(context);
                        return;
                      }

                      final uri = Uri(
                        path: '/services/${widget.serviceId}/book',
                        queryParameters: {
                          'pkgId': (selectedPkg['id'] ?? '').toString(),
                          'pkgName': (selectedPkg['name'] ?? '').toString(),
                          'price': (selectedPkg['priceVal'] ?? 0).toString(),
                        },
                      );
                      context.push(uri.toString());
                    },
                    label: const Text('Đặt dịch vụ ngay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );


  }

  void _showLoginRequiredDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đăng nhập để đặt dịch vụ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn đang khám phá với tư cách Khách. Vui lòng đăng nhập tài khoản để chọn lịch và hoàn tất đơn đặt dịch vụ này.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Để sau'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.push('/login');
                    },
                    child: const Text('Đăng nhập ngay'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
