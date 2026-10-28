import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/event_network_image.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Trang trí sự kiện',
        'desc': 'Trang trí backdrop, sân khấu, sinh nhật, tiệc cưới, hội nghị doanh nghiệp',
        'icon': Icons.palette_outlined,
        'count': '45 dịch vụ',
        'color': const Color(0xFF8E24AA),
        'imageUrl': 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=400&q=80',
      },
      {
        'title': 'Chụp ảnh & Quay phim',
        'desc': 'Quay phóng sự cưới, chụp kỷ yếu, livestream sự kiện, flycam chuyên nghiệp',
        'icon': Icons.camera_alt_outlined,
        'count': '62 dịch vụ',
        'color': const Color(0xFF1E88E5),
        'imageUrl': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=400&q=80',
      },
      {
        'title': 'Ẩm thực & Catering',
        'desc': 'Buffet, finger food, tiệc bàn set menu cao cấp, cocktail bar, teabreak',
        'icon': Icons.restaurant_outlined,
        'count': '38 dịch vụ',
        'color': const Color(0xFFE64A19),
        'imageUrl': 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=400&q=80',
      },
      {
        'title': 'Địa điểm & Hội trường',
        'desc': 'Trung tâm hội nghị tiệc cưới, sân vườn ngoài trời, rooftop lounge sang trọng',
        'icon': Icons.apartment_outlined,
        'count': '29 địa điểm',
        'color': const Color(0xFF2E7D32),
        'imageUrl': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=400&q=80',
      },
      {
        'title': 'Âm thanh & Ánh sáng',
        'desc': 'Hệ thống loa line array, màn hình LED, hiệu ứng khói lạnh, pháo hoa sân khấu',
        'icon': Icons.speaker_group_outlined,
        'count': '24 dịch vụ',
        'color': const Color(0xFFF57C00),
        'imageUrl': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=400&q=80',
      },
      {
        'title': 'MC & Nhân sự sự kiện',
        'desc': 'MC song ngữ, ban nhạc acoustic, vũ đoàn, PG/PB lễ tân chuyên nghiệp',
        'icon': Icons.mic_external_on_outlined,
        'count': '31 dịch vụ',
        'color': const Color(0xFF00897B),
        'imageUrl': 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=400&q=80',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Danh mục dịch vụ sự kiện'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header intro banner
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF31104B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E1B4B).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Color(0xFFFBBF24), size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Hơn 220+ dịch vụ sẵn có',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Hệ Sinh Thái Sự Kiện',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tìm kiếm và kết nối dễ dàng với các đối tác cung cấp dịch vụ tiệc hàng đầu',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.celebration_rounded, color: Color(0xFFFBBF24), size: 36),
                ),
              ],
            ),
          ),

          // Categories List
          ...categories.map((cat) {
            final color = cat['color'] as Color;
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
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/services?category=${cat['title']}'),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            EventNetworkImage(
                              imageUrl: cat['imageUrl'] as String,
                              width: 86,
                              height: 86,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(cat['icon'] as IconData, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      cat['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat['desc'] as String,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.09),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color.withOpacity(0.2), width: 0.8),
                                ),
                                child: Text(
                                  cat['count'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: color,
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
              ),
            );
          }),
        ],
      ),
    );
  }
}
