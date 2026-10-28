import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../../services/models/product_model.dart';
import '../../services/providers/product_approval_provider.dart';

class AdminProductApprovalScreen extends ConsumerStatefulWidget {
  const AdminProductApprovalScreen({super.key});

  @override
  ConsumerState<AdminProductApprovalScreen> createState() => _AdminProductApprovalScreenState();
}

class _AdminProductApprovalScreenState extends ConsumerState<AdminProductApprovalScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Trang trí sự kiện',
    'Chụp ảnh & Quay phim',
    'Ẩm thực & Catering',
    'Địa điểm & Hội trường',
    'Âm thanh & Ánh sáng',
    'MC & Nhân sự sự kiện',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRejectDialog(BuildContext context, ProductModel product) {
    final reasonController = TextEditingController();
    String selectedPreset = 'Hình ảnh chất lượng thấp hoặc dính watermark bản quyền';

    final presets = [
      'Hình ảnh chất lượng thấp hoặc dính watermark bản quyền',
      'Thông tin bảng giá và chi tiết gói chưa rõ ràng, thiếu minh bạch',
      'Thiếu chứng nhận ATVSTP hoặc giấy phép ngành nghề bắt buộc',
      'Nội dung mô tả hoặc tên sản phẩm vi phạm quy chuẩn EventHub',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Từ chối duyệt sản phẩm',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sản phẩm: "${product.title}" của ${product.providerName}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Chọn lý do từ chối mẫu:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                ...presets.map((preset) => RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(preset, style: const TextStyle(fontSize: 12)),
                  value: preset,
                  groupValue: selectedPreset,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedPreset = val;
                        reasonController.text = val;
                      });
                    }
                  },
                )),
                const SizedBox(height: 10),
                const Text(
                  'Ghi chú bổ sung cho Đối tác (NCC):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Nhập chi tiết hướng dẫn để NCC chỉnh sửa và nộp lại...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final reason = reasonController.text.trim().isNotEmpty
                    ? reasonController.text.trim()
                    : selectedPreset;
                ref.read(productApprovalProvider.notifier).rejectProduct(product.id, reason);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã từ chối duyệt sản phẩm "${product.title}"'),
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                );
              },
              child: const Text('Xác nhận từ chối', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmApprove(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Phê duyệt dịch vụ này?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sản phẩm "${product.title}" sẽ được kích hoạt ngay và hiển thị công khai trên ứng dụng để khách hàng có thể đặt tiệc/dịch vụ.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'NCC: ${product.providerName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    ),
                  ),
                  Text(
                    product.price,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Xem lại', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ref.read(productApprovalProvider.notifier).approveProduct(product.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã phê duyệt thành công dịch vụ "${product.title}"!'),
                  backgroundColor: const Color(0xFF059669),
                ),
              );
            },
            child: const Text('Phê duyệt ngay', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productApprovalProvider);
    final notifier = ref.read(productApprovalProvider.notifier);
    final products = state.filteredProducts;
    debugPrint('>>> ADMIN PRODUCTS SCREEN: total=${state.totalCount}, filtered=${products.length}');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kiểm duyệt Sản phẩm NCC',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 2),
            Text(
              'Phê duyệt dịch vụ trước khi niêm yết công khai',
              style: TextStyle(fontSize: 11.5, color: Colors.orange.shade800, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: state.pendingCount > 0 ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: state.pendingCount > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.pendingCount > 0 ? Icons.pending_actions_rounded : Icons.check_circle_rounded,
                  size: 15,
                  color: state.pendingCount > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
                ),
                const SizedBox(width: 5),
                Text(
                  state.pendingCount > 0 ? '${state.pendingCount} chờ duyệt' : 'Đã duyệt hết',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: state.pendingCount > 0 ? const Color(0xFFB45309) : const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // 1. Filter Section (Search Bar + Status Tabs + Category Pills)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) => notifier.search(val),
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên sản phẩm, danh mục, nhà cung cấp...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              notifier.search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildStatusTab(
                        label: 'Tất cả (${state.totalCount})',
                        value: 'All',
                        selectedValue: state.statusFilter,
                        onTap: () => notifier.filterStatus('All'),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusTab(
                        label: 'Chờ duyệt',
                        badge: state.pendingCount > 0 ? '${state.pendingCount}' : null,
                        badgeColor: const Color(0xFFD97706),
                        value: 'Pending',
                        selectedValue: state.statusFilter,
                        onTap: () => notifier.filterStatus('Pending'),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusTab(
                        label: 'Đã duyệt (${state.approvedCount})',
                        value: 'Approved',
                        selectedValue: state.statusFilter,
                        onTap: () => notifier.filterStatus('Approved'),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusTab(
                        label: 'Bị từ chối (${state.rejectedCount})',
                        value: 'Rejected',
                        selectedValue: state.statusFilter,
                        onTap: () => notifier.filterStatus('Rejected'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Category Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = state.categoryFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            cat == 'All' ? 'Tất cả danh mục' : cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4F46E5),
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          onSelected: (val) {
                            if (val) notifier.filterCategory(cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 2. Product List
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      debugPrint('>>> ITEMBUILDER index=$index, id=${products[index].id}');
                      return _buildProductCard(context, ref, products[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.isPending
              ? const Color(0xFFFDE68A)
              : product.isApproved
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFFECACA),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/admin/products/${product.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Image + Info + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Stack(
                      children: [
                        EventNetworkImage(
                          imageUrl: product.imageUrl,
                          width: 58,
                          height: 58,
                          borderRadius: BorderRadius.circular(10),
                          placeholderIcon: Icons.inventory_2_outlined,
                        ),
                        if (product.galleryUrls.length > 1)
                          Positioned(
                            right: 3,
                            bottom: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${product.galleryUrls.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.storefront_rounded, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  product.providerName,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status Badge
                    _buildCardStatusBadge(product),
                  ],
                ),

                const SizedBox(height: 10),

                // Category & Packages Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category_outlined, size: 14, color: Color(0xFF6366F1)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.category,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${product.packages.isNotEmpty ? product.packages.length : product.packagesCount} gói dịch vụ',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                if (product.isRejected && product.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Lý do từ chối: ${product.rejectionReason}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action Buttons for Pending
                if (product.isPending) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRejectDialog(context, product),
                          icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFDC2626)),
                          label: const Text('Từ chối', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            backgroundColor: const Color(0xFFFEF2F2),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmApprove(context, product),
                          icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                          label: const Text('Phê duyệt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardStatusBadge(ProductModel product) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);
    IconData icon = Icons.hourglass_top_rounded;
    String label = 'Chờ duyệt';

    if (product.isApproved) {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF059669);
      icon = Icons.check_circle_rounded;
      label = 'Đã duyệt';
    } else if (product.isRejected) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
      icon = Icons.cancel_rounded;
      label = 'Từ chối';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab({
    required String label,
    String? badge,
    Color? badgeColor,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedValue.toLowerCase() == value.toLowerCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : (badgeColor ?? const Color(0xFFEF4444)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy sản phẩm nào',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
