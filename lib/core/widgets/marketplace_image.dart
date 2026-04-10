import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MarketplaceImage extends StatelessWidget {
  const MarketplaceImage({
    super.key,
    required this.imageUrl,
    this.height = 120,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.shopping_basket_rounded,
  });

  final String imageUrl;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = imageUrl.trim();
    final parsedUrl = Uri.tryParse(normalizedUrl);
    final isWebUrl =
        parsedUrl != null &&
        (parsedUrl.scheme == 'http' || parsedUrl.scheme == 'https') &&
        (parsedUrl.host.isNotEmpty);
    final placeholder = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6EA), Color(0xFFFDF5E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(placeholderIcon, size: 32),
    );

    if (normalizedUrl.isEmpty) {
      return placeholder;
    }
    if (!isWebUrl) {
      final file = File(normalizedUrl);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: Image.file(file, height: height, width: width, fit: fit),
        );
      }
      return placeholder;
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: normalizedUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}
