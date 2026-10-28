import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductApprovalState {
  final List<ProductModel> products;
  final String searchQuery;
  final String statusFilter; // 'All', 'Pending', 'Approved', 'Rejected'
  final String categoryFilter; // 'All' or category name
  final bool isLoading;

  const ProductApprovalState({
    this.products = const [],
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.categoryFilter = 'All',
    this.isLoading = false,
  });

  int get totalCount => products.length;
  int get pendingCount => products.where((p) => p.isPending).length;
  int get approvedCount => products.where((p) => p.isApproved).length;
  int get rejectedCount => products.where((p) => p.isRejected).length;

  List<ProductModel> get recentPending {
    return products.where((p) => p.isPending).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<ProductModel> get filteredProducts {
    return products.where((p) {
      // 1. Search Query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(q);
        final matchProvider = p.providerName.toLowerCase().contains(q);
        final matchCategory = p.category.toLowerCase().contains(q);
        final matchDesc = p.description.toLowerCase().contains(q);
        if (!matchTitle && !matchProvider && !matchCategory && !matchDesc) return false;
      }

      // 2. Status Filter
      if (statusFilter != 'All') {
        if (statusFilter == 'Pending' && !p.isPending) return false;
        if (statusFilter == 'Approved' && !p.isApproved) return false;
        if (statusFilter == 'Rejected' && !p.isRejected) return false;
      }

      // 3. Category Filter
      if (categoryFilter != 'All' && p.category != categoryFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  List<ProductModel> getProductsForProvider(String providerNameOrId) {
    return products.where((p) =>
      p.providerId == providerNameOrId ||
      p.providerName.toLowerCase() == providerNameOrId.toLowerCase()
    ).toList();
  }

  /// Danh sách dịch vụ công khai hiển thị cho Khách hàng (gồm mọi dịch vụ đã được Admin duyệt + catalog nền)
  List<ProductModel> get approvedPublicCatalog {
    final approvedFromProviders = products.where((p) => p.isApproved).toList()
      ..sort((a, b) => (b.reviewedAt ?? b.createdAt).compareTo(a.reviewedAt ?? a.createdAt));

    final existingTitles = approvedFromProviders.map((p) => p.title.toLowerCase().trim()).toSet();
    final existingIds = approvedFromProviders.map((p) => p.id).toSet();

    final merged = <ProductModel>[...approvedFromProviders];
    for (final base in baseMarketplaceCatalog) {
      if (!existingIds.contains(base.id) && !existingTitles.contains(base.title.toLowerCase().trim())) {
        merged.add(base);
      }
    }
    return merged;
  }

  /// Tra cứu thông tin dịch vụ bất kỳ theo ID (phục vụ ServiceDetailScreen & CreateBookingScreen)
  ProductModel resolveServiceById(String serviceId) {
    for (final p in products) {
      if (p.id == serviceId) return p;
    }
    if (serviceId == 's1') {
      final ps1 = products.where((p) => p.id == 'ps1');
      if (ps1.isNotEmpty) return ps1.first;
    }
    for (final base in baseMarketplaceCatalog) {
      if (base.id == serviceId) return base;
    }
    return approvedPublicCatalog.isNotEmpty ? approvedPublicCatalog.first : baseMarketplaceCatalog.first;
  }

  static final List<ProductModel> baseMarketplaceCatalog = [
    ProductModel(
      id: 's1',
      providerId: 'prv-1',
      providerName: 'Ánh Dương Wedding & Decor',
      title: 'Gói Trang trí Tiệc Cưới Phong Cách Rustic Sang Trọng',
      category: 'Trang trí sự kiện',
      price: '15.000.000 ₫',
      priceNum: 15000000,
      description: 'Gói trang trí cao cấp sử dụng 100% hoa tươi nhập khẩu, backdrop gỗ mộc tự nhiên kết hợp dây đèn fairy light ấm cúng, thiết kế riêng cho các cặp đôi yêu thích phong cách rustic lãng mạn.',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80',
      galleryUrls: const [
        'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1469371670807-013ccf25f16a?auto=format&fit=crop&w=600&q=80',
      ],
      status: ProductApprovalStatus.approved,
      createdAt: DateTime(2026, 10, 1),
      rating: 4.9,
      reviewsCount: 28,
    ),
    ProductModel(
      id: 's2',
      providerId: 'prv-2',
      providerName: 'LensCraft Media Group',
      title: 'Quay Phim & Chụp Ảnh Phóng Sự Sự Kiện Trọn Gói',
      category: 'Chụp ảnh & Quay phim',
      price: '8.500.000 ₫',
      priceNum: 8500000,
      description: 'Đội ngũ nhiếp ảnh gia & cameraman chuyên nghiệp ghi lại trọn vẹn mọi khoảnh khắc sự kiện chuẩn 4K, bàn giao toàn bộ ảnh chỉnh màu và video highlight trong 48h.',
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
      galleryUrls: const [
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=600&q=80',
      ],
      status: ProductApprovalStatus.approved,
      createdAt: DateTime(2026, 10, 2),
      rating: 4.8,
      reviewsCount: 19,
    ),
    ProductModel(
      id: 's3',
      providerId: 'prv-royal',
      providerName: 'Royal Catering Saigon',
      title: 'Tiệc Teabreak & Buffet Finger Food Cao Cấp',
      category: 'Ẩm thực & Catering',
      price: '12.000.000 ₫',
      priceNum: 12000000,
      description: 'Thực đơn tiệc trà & Finger Food chuẩn Âu - Á chế biến tươi trong ngày, bày trí sang trọng trên khay sứ & kệ gỗ nghệ thuật cùng đội ngũ phục vụ chuyên nghiệp.',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
      galleryUrls: const [
        'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80',
      ],
      status: ProductApprovalStatus.approved,
      createdAt: DateTime(2026, 10, 3),
      rating: 4.9,
      reviewsCount: 35,
    ),
    ProductModel(
      id: 's4',
      providerId: 'prv-skyline',
      providerName: 'Skyline Convention Hall',
      title: 'Hội Trường Sự Kiện & Hội Nghị Grand Ballroom',
      category: 'Địa điểm & Hội trường',
      price: '25.000.000 ₫',
      priceNum: 25000000,
      description: 'Không gian đại sảnh tiệc không cột sức chứa tới 500 khách, tích hợp màn hình LED P2.5 cực đại, sảnh đón khách sang trọng và bãi đỗ xe rộng rãi.',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
      galleryUrls: const [
        'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=600&q=80',
      ],
      status: ProductApprovalStatus.approved,
      createdAt: DateTime(2026, 10, 4),
      rating: 5.0,
      reviewsCount: 42,
    ),
    ProductModel(
      id: 's6',
      providerId: 'prv-harmony',
      providerName: 'Harmony Entertainment',
      title: 'Ban Nhạc Biểu Diễn Acoustic & MC Song Ngữ Sự Kiện',
      category: 'MC & Nhân sự sự kiện',
      price: '9.000.000 ₫',
      priceNum: 9000000,
      description: 'Cung cấp MC dẫn chương trình chuyên nghiệp cùng ban nhạc Acoustic 4 thành viên khuấy động không khí gala dinner, lễ khai trương và tiệc cưới.',
      imageUrl: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=600&q=80',
      galleryUrls: const [
        'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?auto=format&fit=crop&w=600&q=80',
      ],
      status: ProductApprovalStatus.approved,
      createdAt: DateTime(2026, 10, 5),
      rating: 4.8,
      reviewsCount: 16,
    ),
  ];

  ProductApprovalState copyWith({
    List<ProductModel>? products,
    String? searchQuery,
    String? statusFilter,
    String? categoryFilter,
    bool? isLoading,
  }) {
    return ProductApprovalState(
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProductApprovalNotifier extends StateNotifier<ProductApprovalState> {
  static const String _storageKey = 'eventhub_products_v1';

  ProductApprovalNotifier() : super(const ProductApprovalState()) {
    _initSampleProducts();
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final loaded = decoded
            .map((e) => ProductModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        if (loaded.isNotEmpty) {
          state = state.copyWith(products: loaded);
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.products.map((p) => p.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  void _initSampleProducts() {
    final now = DateTime.now();

    final sampleProducts = [
      // 1. Pending: Birthday background by Ánh Dương Wedding & Decor
      ProductModel(
        id: 'ps2',
        providerId: 'prv-1',
        providerName: 'Ánh Dương Wedding & Decor',
        providerAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        providerPhone: '0987654321',
        providerEmail: 'provider@eventhub.vn',
        title: 'Trang trí Background Sinh Nhật & Thôi Nôi Pastel Dream',
        category: 'Trang trí sự kiện',
        price: '5.500.000 ₫',
        priceNum: 5500000,
        description: 'Set trang trí sinh nhật cho bé với tông màu pastel ngọt ngào, bàn gallery bánh ngọt phong phú, bóng jumbo in tên bé và hình chibi thiết kế riêng 3D theo chủ đề nhân vật hoạt hình.',
        imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=600&q=80',
        galleryUrls: [
          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=600&q=80',
          'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?auto=format&fit=crop&w=600&q=80',
        ],
        packagesCount: 2,
        packages: const [
          ProductPackageItem(
            name: 'Gói Tiêu chuẩn',
            price: '5.500.000 ₫',
            description: 'Backdrop bạt hiflex + bóng nghệ thuật + 1 bàn gallery.',
            includes: ['Backdrop 2.5m x 3m', 'Bóng nghệ thuật tone pastel', 'Bàn gallery sinh nhật', 'Đèn led trang trí'],
          ),
          ProductPackageItem(
            name: 'Gói Cao cấp VIP',
            price: '8.500.000 ₫',
            description: 'Backdrop formex 3D nổi + hoa tươi phụ + 2 hình chibi lớn.',
            includes: ['Backdrop formex 3D', 'Bóng jumbo in chữ tên bé', 'Cắm hoa tươi tone pastel', 'Chibi bé cao 1m', 'Set bánh cupcake decor'],
          ),
        ],
        status: ProductApprovalStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 42)),
        views: 120,
        inquiriesCount: 5,
      ),

      // 2. Pending: Cinematic wedding film by LensCraft Media Group
      ProductModel(
        id: 'ps3',
        providerId: 'prv-2',
        providerName: 'LensCraft Media Group',
        providerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
        providerPhone: '0918889999',
        providerEmail: 'contact@lenscraft.vn',
        title: 'Quay Phim Phóng Sự Cưới Chuẩn Cinematic 4K',
        category: 'Chụp ảnh & Quay phim',
        price: '18.000.000 ₫',
        priceNum: 18000000,
        description: 'Ekip 3 máy quay chuyên nghiệp Sony FX3 chuẩn điện ảnh 4K, trang bị gimbal chống rung và Flycam DJI Mavic 3 quay ngoại cảnh rước dâu. Bao gồm teaser 1 phút giao ngay trong 24h và clip full 5-7 phút.',
        imageUrl: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?auto=format&fit=crop&w=600&q=80',
        galleryUrls: [
          'https://images.unsplash.com/photo-1606800052052-a08af7148866?auto=format&fit=crop&w=600&q=80',
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=600&q=80',
        ],
        packagesCount: 2,
        packages: const [
          ProductPackageItem(
            name: 'Gói Phóng sự 2 Máy',
            price: '18.000.000 ₫',
            description: '2 máy quay Sony FX3 từ lễ đón dâu đến hết tiệc tối.',
            includes: ['2 Cameraman kỳ cựu', 'Teaser 60s mạng xã hội trong 24h', 'Film chính 5-7 phút chỉnh màu màu Cinematic'],
          ),
          ProductPackageItem(
            name: 'Gói Toàn diện 3 Máy + Flycam',
            price: '25.000.000 ₫',
            description: '3 máy quay + 1 Flycam trên không + Livestream màn LED sự kiện.',
            includes: ['3 Cameraman + 1 Drone pilot', 'Quay Flycam rước dâu', 'Xuất hình trực tiếp màn hình LED tiệc cưới', 'Giao file gốc 4K'],
          ),
        ],
        status: ProductApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
        views: 85,
        inquiriesCount: 3,
      ),

      // 3. Pending: Imperial Wedding Catering Menu by Hanoi Grand Catering
      ProductModel(
        id: 'ps4',
        providerId: 'prv-3',
        providerName: 'Hanoi Grand Catering',
        providerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
        providerPhone: '0977112233',
        providerEmail: 'catering@hanoigrand.vn',
        title: 'Menu Tiệc Cưới Hoàng Gia 10 Món Cao Cấp Tặng Rượu Vang',
        category: 'Ẩm thực & Catering',
        price: '45.000.000 ₫',
        priceNum: 45000000,
        description: 'Thực đơn 10 món tiệc cưới phong cách Á - Âu thịnh soạn, nguyên liệu nhập khẩu tươi sạch chuẩn 5 sao, tặng kèm 10 chai rượu vang Chile hảo hạng và đội ngũ nhân sự phục vụ chu đáo tận bàn.',
        imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
        galleryUrls: [
          'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
          'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80',
        ],
        packagesCount: 1,
        packages: const [
          ProductPackageItem(
            name: 'Bàn tiệc 10 người (Menu Hoàng Gia)',
            price: '4.500.000 ₫ / bàn',
            description: 'Áp dụng đặt tối thiểu 10 bàn tiệc.',
            includes: ['Súp hải sâm tổ yến', 'Cá tuyết hấp Hồng Kông', 'Bò Úc sốt vang đỏ', 'Tặng 10 chai rượu vang Chile'],
          ),
        ],
        status: ProductApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 6)),
        views: 210,
        inquiriesCount: 12,
      ),

      // 4. Approved: Rustic Wedding Decor by Ánh Dương Wedding & Decor
      ProductModel(
        id: 'ps1',
        providerId: 'prv-1',
        providerName: 'Ánh Dương Wedding & Decor',
        providerAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        providerPhone: '0987654321',
        providerEmail: 'provider@eventhub.vn',
        title: 'Gói Trang trí Tiệc Cưới Phong Cách Rustic Sang Trọng',
        category: 'Trang trí sự kiện',
        price: '15.000.000 ₫',
        priceNum: 15000000,
        description: 'Gói trang trí cao cấp sử dụng 100% hoa tươi nhập khẩu, backdrop gỗ mộc tự nhiên kết hợp dây đèn fairy light ấm cúng, thiết kế riêng cho các cặp đôi yêu thích phong cách rustic lãng mạn.',
        imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80',
        galleryUrls: [
          'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80',
        ],
        packagesCount: 3,
        status: ProductApprovalStatus.approved,
        createdAt: now.subtract(const Duration(days: 4)),
        reviewedAt: now.subtract(const Duration(days: 3)),
        views: 412,
        inquiriesCount: 28,
        rating: 4.9,
        reviewsCount: 18,
      ),

      // 5. Approved: Audio & Light system by SoundLight Pro Solution
      ProductModel(
        id: 'ps5',
        providerId: 'prv-4',
        providerName: 'SoundLight Pro Solution',
        providerAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=200&q=80',
        providerPhone: '0909556677',
        providerEmail: 'info@soundlightpro.vn',
        title: 'Hệ Thống Âm Thanh & Ánh Sáng Tiệc Cưới Ngoài Trời VIP',
        category: 'Âm thanh & Ánh sáng',
        price: '22.000.000 ₫',
        priceNum: 22000000,
        description: 'Dàn line-array cao cấp công suất lớn phủ sóng 500 khách, hệ thống đèn moving head beam và par led đổi màu tự động theo nhịp nhạc, kèm kỹ thuật viên âm thanh điều chỉnh xuyên suốt sự kiện.',
        imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=600&q=80',
        galleryUrls: [
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=600&q=80',
        ],
        packagesCount: 2,
        status: ProductApprovalStatus.approved,
        createdAt: now.subtract(const Duration(days: 5)),
        reviewedAt: now.subtract(const Duration(days: 4)),
        views: 320,
        inquiriesCount: 19,
        rating: 4.8,
        reviewsCount: 14,
      ),

      // 6. Rejected: Office Teabreak by Hanoi Grand Catering
      ProductModel(
        id: 'ps6',
        providerId: 'prv-3',
        providerName: 'Hanoi Grand Catering',
        providerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
        providerPhone: '0977112233',
        providerEmail: 'catering@hanoigrand.vn',
        title: 'Combo Tiệc Teabreak & Finger Food Văn Phòng Tiết Kiệm',
        category: 'Ẩm thực & Catering',
        price: '3.800.000 ₫',
        priceNum: 3800000,
        description: 'Gói trà chiều 5 loại bánh ngọt Pháp, trái cây tươi nhiệt đới và cà phê/trà túi lọc phục vụ hội thảo, sự kiện doanh nghiệp 30-50 khách.',
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
        packagesCount: 1,
        status: ProductApprovalStatus.rejected,
        createdAt: now.subtract(const Duration(days: 2)),
        reviewedAt: now.subtract(const Duration(days: 1)),
        rejectionReason: 'Hình ảnh đính kèm có độ phân giải thấp và chưa bổ sung chứng nhận Vệ sinh An toàn Thực phẩm (VSATTP) vào hồ sơ dịch vụ. Vui lòng cập nhật hình ảnh chụp thật và upload chứng nhận để được duyệt.',
        views: 45,
        inquiriesCount: 0,
      ),
    ];

    state = state.copyWith(products: sampleProducts);
  }

  // Add new service from NCC
  void addProduct({
    required String title,
    required String category,
    required String price,
    required double priceNum,
    required String description,
    required String imageUrl,
    List<String>? galleryUrls,
    required String providerName,
    required String providerId,
    String? providerAvatar,
    String? providerPhone,
    String? providerEmail,
    List<ProductPackageItem>? packages,
  }) {
    final cleanedGallery = (galleryUrls ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final primaryImage = imageUrl.trim().isNotEmpty
        ? imageUrl.trim()
        : (cleanedGallery.isNotEmpty
            ? cleanedGallery.first
            : 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80');
    final effectiveGallery = cleanedGallery.isNotEmpty
        ? (cleanedGallery.contains(primaryImage)
            ? [primaryImage, ...cleanedGallery.where((u) => u != primaryImage)]
            : [primaryImage, ...cleanedGallery])
        : <String>[primaryImage];

    final newProduct = ProductModel(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      providerId: providerId,
      providerName: providerName,
      providerAvatar: providerAvatar,
      providerPhone: providerPhone,
      providerEmail: providerEmail,
      title: title,
      category: category,
      price: price.contains('₫') ? price : '$price ₫',
      priceNum: priceNum,
      description: description,
      imageUrl: primaryImage,
      galleryUrls: effectiveGallery,
      packagesCount: packages != null && packages.isNotEmpty ? packages.length : 1,
      packages: packages ?? const [],
      status: ProductApprovalStatus.pending,
      createdAt: DateTime.now(),
      views: 0,
      inquiriesCount: 0,
    );

    state = state.copyWith(products: [newProduct, ...state.products]);
    _saveToLocal();
  }

  // Update & resubmit an existing service (e.g. after rejection or adding photos)
  void updateProduct({
    required String id,
    required String title,
    required String category,
    required String price,
    required double priceNum,
    required String description,
    required String imageUrl,
    List<String>? galleryUrls,
  }) {
    final cleanedGallery = (galleryUrls ?? const <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final primaryImage = imageUrl.trim().isNotEmpty
        ? imageUrl.trim()
        : (cleanedGallery.isNotEmpty
            ? cleanedGallery.first
            : 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80');
    final effectiveGallery = cleanedGallery.isNotEmpty
        ? (cleanedGallery.contains(primaryImage)
            ? [primaryImage, ...cleanedGallery.where((u) => u != primaryImage)]
            : [primaryImage, ...cleanedGallery])
        : <String>[primaryImage];

    final updatedList = state.products.map((p) {
      if (p.id == id) {
        return p.copyWith(
          title: title,
          category: category,
          price: price.contains('₫') ? price : '$price ₫',
          priceNum: priceNum,
          description: description,
          imageUrl: primaryImage,
          galleryUrls: effectiveGallery,
          status: ProductApprovalStatus.pending,
          createdAt: DateTime.now(),
        );
      }
      return p;
    }).toList();

    state = state.copyWith(products: updatedList);
    _saveToLocal();
  }

  // Admin approves product
  void approveProduct(String id, {String? notes}) {
    final updatedList = state.products.map((p) {
      if (p.id == id) {
        return p.copyWith(
          status: ProductApprovalStatus.approved,
          reviewedAt: DateTime.now(),
          adminNotes: notes ?? 'Đã phê duyệt đạt tiêu chuẩn niêm yết trên EventHub.',
          rejectionReason: null,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(products: updatedList);
    _saveToLocal();
  }

  // Admin rejects product
  void rejectProduct(String id, String reason) {
    final updatedList = state.products.map((p) {
      if (p.id == id) {
        return p.copyWith(
          status: ProductApprovalStatus.rejected,
          reviewedAt: DateTime.now(),
          rejectionReason: reason,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(products: updatedList);
    _saveToLocal();
  }

  // Toggle active / hidden by provider
  void toggleProductActive(String id) {
    final updatedList = state.products.map((p) {
      if (p.id == id) {
        final newStatus = p.status == ProductApprovalStatus.approved
            ? ProductApprovalStatus.hidden
            : (p.status == ProductApprovalStatus.hidden ? ProductApprovalStatus.approved : p.status);
        return p.copyWith(status: newStatus);
      }
      return p;
    }).toList();

    state = state.copyWith(products: updatedList);
    _saveToLocal();
  }

  // Delete product
  void deleteProduct(String id) {
    state = state.copyWith(
      products: state.products.where((p) => p.id != id).toList(),
    );
    _saveToLocal();
  }

  // Search & Filter
  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void filterStatus(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void filterCategory(String category) {
    state = state.copyWith(categoryFilter: category);
  }

  void resetFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: 'All',
      categoryFilter: 'All',
    );
  }
}

final productApprovalProvider = StateNotifierProvider<ProductApprovalNotifier, ProductApprovalState>((ref) {
  return ProductApprovalNotifier();
});

