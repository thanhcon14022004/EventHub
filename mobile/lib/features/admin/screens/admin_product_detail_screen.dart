import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../../services/models/product_model.dart';
import '../../services/providers/product_approval_provider.dart';

class AdminProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const AdminProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<AdminProductDetailScreen> createState() => _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends ConsumerState<AdminProductDetailScreen> {
  int _selectedImageIndex = 0;

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
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w600),
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
    final productList = state.products.where((p) => p.id == widget.productId).toList();

    if (productList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: const Center(child: Text('Không tìm thấy thông tin sản phẩm')),
      );
    }

    final product = productList.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thẩm định Dịch vụ NCC',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: product.statusBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: product.statusColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(product.statusIcon, color: product.statusColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trạng thái: ${product.statusLabel}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: product.statusColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.isPending
                              ? 'NCC nộp lúc: ${product.createdAt.hour}:${product.createdAt.minute} - ${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}'
                              : (product.isApproved ? 'Đã duyệt đạt chuẩn niêm yết' : 'Cần NCC bổ sung chỉnh sửa'),
                          style: TextStyle(fontSize: 11, color: product.statusColor.withOpacity(0.85), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (product.isRejected && product.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.report_problem_rounded, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lý do từ chối đã gửi cho NCC:',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF991B1B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.rejectionReason!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Product Hero Image & Gallery
            Builder(
              builder: (context) {
                final images = product.galleryUrls.isNotEmpty
                    ? product.galleryUrls
                    : <String>[product.imageUrl];
                final safeIndex = _selectedImageIndex < images.length ? _selectedImageIndex : 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        EventNetworkImage(
                          imageUrl: images[safeIndex],
                          height: 220,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(16),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.photo_library_rounded, size: 13, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  '${safeIndex + 1}/${images.length} ảnh',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (images.length > 1) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final isSelected = idx == safeIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedImageIndex = idx),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: EventNetworkImage(
                                  imageUrl: images[idx],
                                  width: 60,
                                  height: 60,
                                  borderRadius: BorderRadius.circular(9.5),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Title, Category, Price
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        product.price,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Provider Info Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: product.providerAvatar != null ? NetworkImage(product.providerAvatar!) : null,
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: product.providerAvatar == null ? const Icon(Icons.storefront_rounded, color: Color(0xFF64748B)) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.providerName,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SĐT: ${product.providerPhone ?? '0987654321'} • ${product.providerEmail ?? 'provider@eventhub.vn'}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF4F46E5), size: 20),
                    onPressed: () {
                      context.push('/chat/system');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Description Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mô tả chi tiết dịch vụ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
                  ),
                ],
              ),
            ),

            // Packages list (if any)
            if (product.packages.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Các gói lựa chọn (${product.packages.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(height: 10),
                    ...product.packages.map((pkg) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text(pkg.price, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669), fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(pkg.description, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                          if (pkg.includes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: pkg.includes.map((inc) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                                  const SizedBox(width: 4),
                                  Text(inc, style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
                                ],
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (product.isPending) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showRejectDialog(context, product),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Từ chối duyệt', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _confirmApprove(context, product),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Phê duyệt ngay', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ] else if (product.isApproved) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ref.read(productApprovalProvider.notifier).toggleProductActive(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã cập nhật trạng thái hiển thị của sản phẩm!')),
                      );
                    },
                    icon: const Icon(Icons.visibility_off_rounded, size: 18),
                    label: const Text('Tạm ẩn dịch vụ', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ] else if (product.isRejected) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _confirmApprove(context, product),
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: const Text('Xét duyệt lại dịch vụ', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
