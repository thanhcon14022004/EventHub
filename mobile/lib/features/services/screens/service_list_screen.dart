import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../../bookings/models/booking_model.dart';
import '../models/product_model.dart';
import '../providers/product_approval_provider.dart';

class ServiceListScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const ServiceListScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _sortBy = 'Phổ biến nhất';
  String _selectedCity = 'Tất cả';
  double _minRating = 0.0;
  RangeValues _priceRange = const RangeValues(0, 50000000);

  final List<String> _categories = [
    'Tất cả',
    'Trang trí sự kiện',
    'Chụp ảnh & Quay phim',
    'Ẩm thực & Catering',
    'Địa điểm & Hội trường',
    'Âm thanh & Ánh sáng',
    'MC & Nhân sự sự kiện',
  ];

  final List<String> _cities = [
    'Tất cả',
    'Hà Nội',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCity != 'Tất cả') count++;
    if (_minRating > 0.0) count++;
    if (_priceRange.start > 0 || _priceRange.end < 50000000) count++;
    if (_selectedCategory != 'Tất cả') count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = 'Tất cả';
      _minRating = 0.0;
      _priceRange = const RangeValues(0, 50000000);
      _selectedCategory = 'Tất cả';
    });
  }

  List<Map<String, dynamic>> _getFilteredServices(List<ProductModel> catalog) {
    final query = _searchController.text.trim().toLowerCase();
    final mapped = catalog.map((p) {
      final city = p.id == 's4'
          ? 'Đà Nẵng'
          : ((p.id == 's2' || p.id == 's3' || p.id == 's6') ? 'TP. Hồ Chí Minh' : 'Hà Nội');
      return <String, dynamic>{
        'id': p.id,
        'title': p.title,
        'provider': p.providerName,
        'price': p.price,
        'priceNum': p.priceNum.round(),
        'rating': p.rating,
        'reviews': p.reviewsCount,
        'city': city,
        'category': p.category,
        'imageUrl': p.imageUrl,
      };
    }).toList();

    var list = mapped.where((item) {
      final matchesCategory = _selectedCategory == 'Tất cả' || item['category'] == _selectedCategory;
      final matchesCity = _selectedCity == 'Tất cả' || item['city'] == _selectedCity;
      final matchesRating = (item['rating'] as double) >= _minRating;
      final price = item['priceNum'] as int;
      final matchesPrice = price >= _priceRange.start && price <= _priceRange.end;

      final matchesQuery = query.isEmpty ||
          (item['title'] as String).toLowerCase().contains(query) ||
          (item['provider'] as String).toLowerCase().contains(query) ||
          (item['category'] as String).toLowerCase().contains(query) ||
          (item['city'] as String).toLowerCase().contains(query);

      return matchesCategory && matchesCity && matchesRating && matchesPrice && matchesQuery;
    }).toList();

    if (_sortBy == 'Giá tăng dần') {
      list.sort((a, b) => (a['priceNum'] as int).compareTo(b['priceNum'] as int));
    } else if (_sortBy == 'Giá giảm dần') {
      list.sort((a, b) => (b['priceNum'] as int).compareTo(a['priceNum'] as int));
    } else if (_sortBy == 'Đánh giá cao') {
      list.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(productApprovalProvider).approvedPublicCatalog;
    final filteredItems = _getFilteredServices(catalog);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm dịch vụ & Sự kiện'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Nhập tên dịch vụ, đơn vị cung cấp...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: _activeFilterCount > 0 ? AppColors.primary : AppColors.textSecondary,
                          ),
                          onPressed: _showFilterModal,
                        ),
                        if (_activeFilterCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$_activeFilterCount',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Active filters indicator bar
          if (_activeFilterCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Đang lọc: ${_selectedCity != 'Tất cả' ? '[$_selectedCity] ' : ''}${_minRating > 0 ? '[≥ $_minRating★] ' : ''}${_priceRange.start > 0 || _priceRange.end < 50000000 ? '[Giá: ${BookingModel.formatVnd(_priceRange.start.round())} - ${BookingModel.formatVnd(_priceRange.end.round())}]' : ''}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: _resetFilters,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Xóa lọc',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Category filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    selectedColor: isDark ? const Color(0xFF312E81) : AppColors.secondary,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? (isDark ? Colors.white : AppColors.primary) : (isDark ? Colors.white70 : AppColors.textPrimary),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF334155) : AppColors.cardBorder),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Search result header & sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tìm thấy ${filteredItems.length} dịch vụ phù hợp',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700),
                  items: ['Phổ biến nhất', 'Giá tăng dần', 'Giá giảm dần', 'Đánh giá cao']
                      .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _sortBy = val);
                  },
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.search_off_rounded, size: 54, color: isDark ? Colors.white38 : AppColors.textMuted.withOpacity(0.6)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không tìm thấy dịch vụ phù hợp',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hãy thử điều chỉnh lại bộ lọc giá hoặc danh mục tìm kiếm',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(140, 42),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Đặt lại bộ lọc'),
                          onPressed: _resetFilters,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => context.push('/services/${item['id']}'),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: EventNetworkImage(
                                      imageUrl: item['imageUrl'] as String,
                                      width: 95,
                                      height: 95,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF312E81) : AppColors.secondary,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                item['category'] as String,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? const Color(0xFFC7D2FE) : AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${item['rating']}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                            ),
                                            Text(
                                              ' (${item['reviews']})',
                                              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            height: 1.25,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.storefront_rounded, size: 14, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['provider'] as String,
                                                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(Icons.location_on_outlined, size: 13, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                                            const SizedBox(width: 2),
                                            Text(
                                              item['city'] as String,
                                              style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item['price'] as String,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.primary,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF312E81) : const Color(0xFFEDE9FE),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Chi tiết',
                                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
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
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        String tempCity = _selectedCity;
        double tempMinRating = _minRating;
        RangeValues tempPrice = _priceRange;

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isDark = Theme.of(modalCtx).brightness == Brightness.dark;

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(modalCtx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text('Bộ lọc tìm kiếm thông minh', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempCity = 'Tất cả';
                            tempMinRating = 0.0;
                            tempPrice = const RangeValues(0, 50000000);
                          });
                        },
                        child: const Text('Đặt lại', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // City selector
                  const Text('Địa điểm tổ chức', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _cities.map((city) {
                      final isSelected = city == tempCity;
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSelected,
                        selectedColor: isDark ? const Color(0xFF312E81) : AppColors.secondary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : AppColors.textPrimary),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => tempCity = city);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Price range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Khoảng giá dịch vụ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                      Text(
                        '${BookingModel.formatVnd(tempPrice.start.round())} - ${BookingModel.formatVnd(tempPrice.end.round())}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12.5),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: tempPrice,
                    min: 0,
                    max: 50000000,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    inactiveColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    onChanged: (val) {
                      setModalState(() => tempPrice = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Rating filter
                  const Text('Đánh giá chất lượng', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: tempMinRating == 0.0,
                        selectedColor: isDark ? const Color(0xFF312E81) : AppColors.secondary,
                        onSelected: (_) => setModalState(() => tempMinRating = 0.0),
                      ),
                      ChoiceChip(
                        label: const Text('Từ 4.0 ⭐ trở lên'),
                        selected: tempMinRating == 4.0,
                        selectedColor: isDark ? const Color(0xFF312E81) : AppColors.secondary,
                        onSelected: (_) => setModalState(() => tempMinRating = 4.0),
                      ),
                      ChoiceChip(
                        label: const Text('Từ 4.5 ⭐ (Rất hài lòng)'),
                        selected: tempMinRating == 4.5,
                        selectedColor: isDark ? const Color(0xFF312E81) : AppColors.secondary,
                        onSelected: (_) => setModalState(() => tempMinRating = 4.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCity = tempCity;
                          _minRating = tempMinRating;
                          _priceRange = tempPrice;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Áp dụng bộ lọc ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
