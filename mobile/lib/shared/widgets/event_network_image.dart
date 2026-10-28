import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EventNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final IconData placeholderIcon;

  const EventNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.celebration_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(12);

    Widget buildPlaceholder() {
      return Container(
        width: width,
        height: height,
        color: AppColors.secondary,
        child: Icon(
          placeholderIcon,
          color: AppColors.primary.withValues(alpha: 0.7),
          size: (width != null && width!.isFinite && width! < 60) ? 24 : 36,
        ),
      );
    }

    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: buildPlaceholder(),
      );
    }

    final effectiveCacheWidth = (width != null && width!.isFinite) ? (width! * 2).round().clamp(100, 1200) : 600;
    final effectiveCacheHeight = (height != null && height!.isFinite) ? (height! * 2).round().clamp(100, 1200) : 600;

    // 1. Base64 data URI
    if (trimmedUrl.startsWith('data:image/')) {
      final commaIndex = trimmedUrl.indexOf(',');
      if (commaIndex != -1 && commaIndex + 1 < trimmedUrl.length) {
        try {
          final bytes = base64Decode(trimmedUrl.substring(commaIndex + 1));
          return ClipRRect(
            borderRadius: effectiveRadius,
            child: Image.memory(
              bytes,
              width: width,
              height: height,
              fit: fit,
              cacheWidth: effectiveCacheWidth,
              errorBuilder: (_, __, ___) => buildPlaceholder(),
            ),
          );
        } catch (_) {
          return ClipRRect(
            borderRadius: effectiveRadius,
            child: buildPlaceholder(),
          );
        }
      }
    }

    // 2. Local device file path (picked via ImagePicker from Gallery or Camera)
    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      if (kIsWeb) {
        return ClipRRect(
          borderRadius: effectiveRadius,
          child: buildPlaceholder(),
        );
      }
      final localPath = trimmedUrl.startsWith('file://')
          ? Uri.tryParse(trimmedUrl)?.toFilePath() ?? trimmedUrl
          : trimmedUrl;
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: Image.file(
          File(localPath),
          width: width,
          height: height,
          fit: fit,
          cacheWidth: effectiveCacheWidth,
          errorBuilder: (_, __, ___) => buildPlaceholder(),
        ),
      );
    }

    // 3. Remote HTTP/HTTPS URL
    return ClipRRect(
      borderRadius: effectiveRadius,
      child: Image.network(
        trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: effectiveCacheWidth,
        cacheHeight: effectiveCacheHeight,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          double? progressValue;
          if (loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes! > 0) {
            final calculated = loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!;
            if (!calculated.isNaN && !calculated.isInfinite) {
              progressValue = calculated.clamp(0.0, 1.0);
            }
          }

          return Container(
            width: width,
            height: height,
            color: AppColors.secondary,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withValues(alpha: 0.6),
                  value: progressValue,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return buildPlaceholder();
        },
      ),
    );
  }
}
