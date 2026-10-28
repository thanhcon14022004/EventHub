import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/event_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../services/models/product_model.dart';
import '../../services/providers/product_approval_provider.dart';

class ProviderServicesScreen extends ConsumerStatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  ConsumerState<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends ConsumerState<ProviderServicesScreen> {
  String _selectedFilter = 'Tất cả';
  final ImagePicker _imagePicker = ImagePicker();

  void _showAddServiceDialog({ProductModel? existingProduct}) {
    final titleCtrl = TextEditingController(text: existingProduct?.title ?? '');
    final priceCtrl = TextEditingController(
      text: existingProduct != null
          ? existingProduct.price.replaceAll('₫', '').trim()
          : '',
    );
    final descCtrl = TextEditingController(text: existingProduct?.description ?? '');

    const categories = [
      'Trang trí sự kiện',
      'Chụp ảnh & Quay phim',
      'Ẩm thực & Catering',
      'Địa điểm & Hội trường',
      'Âm thanh & Ánh sáng',
      'MC & Nhân sự sự kiện',
    ];
    String category = (existingProduct != null && categories.contains(existingProduct.category))
        ? existingProduct.category
        : 'Trang trí sự kiện';

    const maxImages = 6;
    final List<String> uploadedImages = existingProduct != null
        ? (existingProduct.galleryUrls.isNotEmpty
            ? List<String>.from(existingProduct.galleryUrls)
            : (existingProduct.imageUrl.isNotEmpty ? <String>[existingProduct.imageUrl] : <String>[]))
        : <String>[];

    final categoryImages = {
      'Trang trí sự kiện': 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80',
      'Chụp ảnh & Quay phim': 'https://images.unsplash.com/photo-1606800052052-a08af7148866?auto=format&fit=crop&w=600&q=80',
      'Ẩm thực & Catering': 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
      'Địa điểm & Hội trường': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=600&q=80',
      'Âm thanh & Ánh sáng': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=600&q=80',
      'MC & Nhân sự sự kiện': 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=600&q=80',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          Future<void> pickFromGallery() async {
            if (uploadedImages.length >= maxImages) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tối đa 6 ảnh cho mỗi gói dịch vụ.')),
              );
              return;
            }
            try {
              final pickedFiles = await _imagePicker.pickMultiImage(
                imageQuality: 85,
                maxWidth: 1400,
              );
              if (pickedFiles.isNotEmpty) {
                setModalState(() {
                  for (final file in pickedFiles) {
                    if (uploadedImages.length < maxImages && !uploadedImages.contains(file.path)) {
                      uploadedImages.add(file.path);
                    }
                  }
                });
              }
            } catch (_) {
              try {
                final single = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 1400,
                );
                if (single != null && uploadedImages.length < maxImages && !uploadedImages.contains(single.path)) {
                  setModalState(() => uploadedImages.add(single.path));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể mở thư viện ảnh: $e')),
                  );
                }
              }
            }
          }

          Future<void> pickFromCamera() async {
            if (uploadedImages.length >= maxImages) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tối đa 6 ảnh cho mỗi gói dịch vụ.')),
              );
              return;
            }
            try {
              final photo = await _imagePicker.pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
                maxWidth: 1400,
              );
              if (photo != null && !uploadedImages.contains(photo.path)) {
                setModalState(() => uploadedImages.add(photo.path));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể mở máy ảnh: $e')),
                );
              }
            }
          }

          Future<void> showPasteUrlDialog() async {
            if (uploadedImages.length >= maxImages) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tối đa 6 ảnh cho mỗi gói dịch vụ.')),
              );
              return;
            }
            final urlCtrl = TextEditingController();
            final pastedUrl = await showDialog<String>(
              context: ctx,
              builder: (dCtx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: const Text('Thêm ảnh bằng đường dẫn URL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                content: TextField(
                  controller: urlCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com/anh-su-kien.jpg',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dCtx),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dCtx, urlCtrl.text.trim()),
                    child: const Text('Thêm ảnh'),
                  ),
                ],
              ),
            );
            if (pastedUrl != null && pastedUrl.isNotEmpty) {
              if (pastedUrl.startsWith('http://') || pastedUrl.startsWith('https://')) {
                if (!uploadedImages.contains(pastedUrl)) {
                  setModalState(() => uploadedImages.add(pastedUrl));
                }
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập link ảnh bắt đầu bằng http:// hoặc https://')),
                );
              }
            }
          }

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            existingProduct != null ? 'Cập nhật dịch vụ & hình ảnh' : 'Thêm dịch vụ sự kiện mới',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFD97706)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sản phẩm mới thêm hoặc cập nhật sẽ được gửi đến Quản trị viên EventHub phê duyệt trước khi hiển thị công khai.',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Image Upload Section
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Hình ảnh dịch vụ',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Đã tải ${uploadedImages.length}/$maxImages ảnh',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickFromGallery,
                            icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                            label: const Text('Thư viện', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              minimumSize: const Size(0, 38),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickFromCamera,
                            icon: const Icon(Icons.camera_alt_outlined, size: 15),
                            label: const Text('Chụp ảnh', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              minimumSize: const Size(0, 38),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton.icon(
                          onPressed: showPasteUrlDialog,
                          icon: const Icon(Icons.link_rounded, size: 15),
                          label: const Text('URL', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF475569),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (uploadedImages.isEmpty)
                      InkWell(
                        onTap: pickFromGallery,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.primary),
                              SizedBox(height: 6),
                              Text(
                                'Nhấn để tải ảnh thực tế của dịch vụ lên',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Có thể chọn nhiều ảnh cùng lúc (ảnh đầu tiên sẽ làm ảnh bìa)',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 102,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: uploadedImages.length < maxImages
                              ? uploadedImages.length + 1
                              : uploadedImages.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (_, idx) {
                            if (idx == uploadedImages.length) {
                              return InkWell(
                                onTap: pickFromGallery,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 26),
                                      SizedBox(height: 4),
                                      Text(
                                        'Thêm ảnh',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final imgPath = uploadedImages[idx];
                            final isCover = idx == 0;
                            return GestureDetector(
                              onTap: () {
                                if (!isCover) {
                                  setModalState(() {
                                    final selected = uploadedImages.removeAt(idx);
                                    uploadedImages.insert(0, selected);
                                  });
                                }
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCover ? AppColors.primary : const Color(0xFFE2E8F0),
                                        width: isCover ? 2 : 1,
                                      ),
                                    ),
                                    child: EventNetworkImage(
                                      imageUrl: imgPath,
                                      width: 96,
                                      height: 96,
                                      borderRadius: BorderRadius.circular(10),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => setModalState(() => uploadedImages.removeAt(idx)),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.65),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 4,
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: isCover
                                            ? AppColors.primary.withValues(alpha: 0.92)
                                            : Colors.black.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isCover ? 'Ảnh bìa' : 'Đặt làm bìa',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 14),
                    const Text('Tên dịch vụ *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(hintText: 'Ví dụ: Trang trí hoa tươi bàn tiệc cưới cao cấp...'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Danh mục *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(),
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Giá khởi điểm (VNĐ) *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Ví dụ: 12.000.000'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Mô tả chi tiết dịch vụ *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Mô tả chi tiết các hạng mục bao gồm trong gói, cam kết chất lượng...',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tên dịch vụ trước khi gửi duyệt.')),
                            );
                            return;
                          }

                          final user = ref.read(authProvider).user;
                          final providerName = user?.fullName.isNotEmpty == true
                              ? user!.fullName
                              : 'Ánh Dương Wedding & Decor';
                          final providerPhone = user?.phoneNumber ?? '0987654321';
                          final providerEmail = user?.email ?? 'provider@eventhub.vn';

                          final rawPrice = priceCtrl.text
                              .trim()
                              .replaceAll('.', '')
                              .replaceAll(',', '')
                              .replaceAll('₫', '')
                              .replaceAll(' ', '');
                          final priceNum = double.tryParse(rawPrice) ?? 10000000.0;
                          final formattedPrice = '${priceCtrl.text.trim().isNotEmpty ? priceCtrl.text.trim() : '10.000.000'} ₫';
                          final description = descCtrl.text.trim().isNotEmpty
                              ? descCtrl.text.trim()
                              : 'Dịch vụ chất lượng cao do đối tác $providerName cung cấp theo tiêu chuẩn hàng đầu EventHub.';

                          final defaultCategoryImg = categoryImages[category] ??
                              'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=600&q=80';
                          final primaryImg = uploadedImages.isNotEmpty ? uploadedImages.first : defaultCategoryImg;
                          final galleryList = uploadedImages.isNotEmpty
                              ? List<String>.from(uploadedImages)
                              : <String>[primaryImg];

                          if (existingProduct != null) {
                            ref.read(productApprovalProvider.notifier).updateProduct(
                              id: existingProduct.id,
                              title: titleCtrl.text.trim(),
                              category: category,
                              price: formattedPrice,
                              priceNum: priceNum,
                              description: description,
                              imageUrl: primaryImg,
                              galleryUrls: galleryList,
                            );
                          } else {
                            ref.read(productApprovalProvider.notifier).addProduct(
                              title: titleCtrl.text.trim(),
                              category: category,
                              price: formattedPrice,
                              priceNum: priceNum,
                              description: description,
                              imageUrl: primaryImg,
                              galleryUrls: galleryList,
                              providerName: providerName,
                              providerId: user?.id ?? 'prv-1',
                              providerPhone: providerPhone,
                              providerEmail: providerEmail,
                            );
                          }

                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã gửi "${titleCtrl.text.trim()}" (${galleryList.length} ảnh) lên hệ thống! Đang chờ Quản trị viên duyệt.',
                              ),
                              backgroundColor: const Color(0xFFD97706),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded),
                        label: Text(
                          existingProduct != null ? 'Lưu cập nhật & Gửi duyệt lại' : 'Lưu & Gửi phê duyệt ngay',
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
      ),
    );
  }

  void _showServicePreviewSheet(ProductModel product) {
    final images = product.galleryUrls.isNotEmpty ? product.galleryUrls : <String>[product.imageUrl];
    int activeIdx = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetCtx).size.height * 0.85),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Xem trước dịch vụ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _showAddServiceDialog(existingProduct: product);
                      },
                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 17),
                      label: const Text('Sửa / Thêm ảnh', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    EventNetworkImage(
                      imageUrl: images[activeIdx],
                      width: double.infinity,
                      height: 210,
                      borderRadius: BorderRadius.circular(16),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${activeIdx + 1}/${images.length} ảnh',
                          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                if (images.length > 1) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 62,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, idx) {
                        final selected = idx == activeIdx;
                        return GestureDetector(
                          onTap: () => setSheetState(() => activeIdx = idx),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: EventNetworkImage(
                              imageUrl: images[idx],
                              width: 58,
                              height: 58,
                              borderRadius: BorderRadius.circular(8),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                    const Spacer(),
                    _buildServiceStatusBadge(product),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  product.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Text(
                  product.price,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                ),
                const SizedBox(height: 10),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.45),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productApprovalProvider);
    final user = ref.watch(authProvider).user;
    final providerName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Ánh Dương Wedding & Decor';

    // Provider's services (filtered by this provider, or all if demo)
    final providerProducts = state.products.where((p) =>
      p.providerId == (user?.id ?? 'prv-1') ||
      (user?.providerProfileId != null && p.providerId == user!.providerProfileId) ||
      p.providerName.toLowerCase().contains('ánh dương') ||
      p.providerName.toLowerCase() == providerName.toLowerCase()
    ).toList();

    // Filter by tab
    final filtered = providerProducts.where((p) {
      if (_selectedFilter == 'Tất cả') return true;
      if (_selectedFilter == 'Đang hoạt động') return p.isApproved;
      if (_selectedFilter == 'Chờ duyệt') return p.isPending;
      if (_selectedFilter == 'Bị từ chối') return p.isRejected;
      if (_selectedFilter == 'Tạm ẩn') return p.isHidden;
      return true;
    }).toList();

    final pendingCount = providerProducts.where((p) => p.isPending).length;
    final approvedCount = providerProducts.where((p) => p.isApproved).length;
    final rejectedCount = providerProducts.where((p) => p.isRejected).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Kho Dịch vụ của bạn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            onPressed: () => _showAddServiceDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('Tất cả (${providerProducts.length})', 'Tất cả'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đang hoạt động ($approvedCount)', 'Đang hoạt động'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Chờ duyệt ($pendingCount)', 'Chờ duyệt', hasBadge: pendingCount > 0, badgeColor: const Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  if (rejectedCount > 0) ...[
                    _buildFilterChip('Bị từ chối ($rejectedCount)', 'Bị từ chối', hasBadge: true, badgeColor: const Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                  ],
                  _buildFilterChip('Tạm ẩn', 'Tạm ẩn'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Product List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.inventory_2_outlined, size: 52, color: AppColors.textMuted.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Không có dịch vụ nào trong mục này',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Thử chuyển sang tab khác hoặc nhấn dấu (+) để thêm dịch vụ mới',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showAddServiceDialog(),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Thêm dịch vụ ngay', style: TextStyle(fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 44),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return _buildServiceCard(context, ref, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, WidgetRef ref, ProductModel product) {
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
          width: product.isPending ? 1.5 : 1,
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
          onTap: () => _showServicePreviewSheet(product),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Image + Info + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Stack(
                      children: [
                        EventNetworkImage(
                          imageUrl: product.imageUrl,
                          width: 62,
                          height: 62,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_library_rounded, size: 9, color: Colors.white),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${product.galleryUrls.length}',
                                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                                  ),
                                ],
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
                          const SizedBox(height: 5),
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
                    _buildServiceStatusBadge(product),
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
                      const Icon(Icons.category_outlined, size: 14, color: AppColors.primary),
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
                        '${product.packages.isNotEmpty ? product.packages.length : product.packagesCount} gói • ${product.views} xem',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                // Pending note
                if (product.isPending) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 15, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đang chờ Quản trị viên duyệt để hiển thị cho khách hàng.',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Rejected note
                if (product.isRejected && product.rejectionReason != null) ...[
                  const SizedBox(height: 10),
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

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Controls row
                Row(
                  children: [
                    if (product.isApproved || product.isHidden)
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: 0.75,
                              child: Switch(
                                value: product.isApproved,
                                activeColor: const Color(0xFF059669),
                                onChanged: (val) {
                                  ref.read(productApprovalProvider.notifier).toggleProductActive(product.id);
                                },
                              ),
                            ),
                            Text(
                              product.isApproved ? 'Đang bật' : 'Tạm ẩn',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: product.isApproved ? const Color(0xFF059669) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          product.timeFormatted,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(width: 8),

                    if (product.isRejected)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showAddServiceDialog(existingProduct: product),
                        icon: const Icon(Icons.edit_note_rounded, size: 15),
                        label: const Text('Nộp lại', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      )
                    else
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          minimumSize: const Size(0, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showServicePreviewSheet(product),
                        icon: const Icon(Icons.remove_red_eye_rounded, size: 14, color: Color(0xFF64748B)),
                        label: const Text('Xem trước', style: TextStyle(fontSize: 11, color: Color(0xFF334155), fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceStatusBadge(ProductModel product) {
    Color bg;
    Color fg;
    IconData icon;
    String text;

    switch (product.status) {
      case ProductApprovalStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        icon = Icons.pending_actions_rounded;
        text = 'Chờ duyệt';
        break;
      case ProductApprovalStatus.approved:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        icon = Icons.check_circle_rounded;
        text = 'Hoạt động';
        break;
      case ProductApprovalStatus.rejected:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        text = 'Từ chối';
        break;
      case ProductApprovalStatus.hidden:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        icon = Icons.visibility_off_rounded;
        text = 'Tạm ẩn';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterKey, {bool hasBadge = false, Color? badgeColor}) {
    final isSelected = filterKey == _selectedFilter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedFilter = filterKey),
      selectedColor: AppColors.secondary,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      ),
    );
  }
}
