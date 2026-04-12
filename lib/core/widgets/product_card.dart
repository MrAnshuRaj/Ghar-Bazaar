import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ghar_bazaar/core/utils/formatters.dart';
import 'package:ghar_bazaar/core/widgets/marketplace_image.dart';
import 'package:ghar_bazaar/data/models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    this.quantity = 0,
    this.onIncrease,
    this.onDecrease,
    this.trailing,
  });

  final Product product;
  final VoidCallback onAdd;
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    try {
      final theme = Theme.of(context);
      final safeName = product.name.trim().isEmpty
          ? 'Unnamed product'
          : product.name.trim();
      final safeDescription = product.description.trim().isEmpty
          ? 'No description available.'
          : product.description.trim();
      final safeUnit = product.unit.trim().isEmpty
          ? 'unit'
          : product.unit.trim();
      final safeStock = product.stock < 0 ? 0 : product.stock;
      final safePrice = product.price.isFinite && product.price >= 0
          ? product.price
          : 0.0;
      final safeDiscount =
          product.discountPercent.isFinite && product.discountPercent > 0
          ? product.discountPercent
          : 0.0;
      final computedFinal = safePrice - (safePrice * safeDiscount / 100);
      final safeFinalPrice = computedFinal.isFinite && computedFinal >= 0
          ? computedFinal
          : 0.0;
      final actionWidget =
          trailing ??
          (quantity > 0
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      onPressed: onDecrease,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('$quantity'),
                    ),
                    IconButton.filled(
                      onPressed: onIncrease,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                )
              : FilledButton(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Add'),
                ));

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarketplaceImage(
                imageUrl: product.imageUrl,
                height: 92,
                width: 92,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            safeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (safeDiscount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0DD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${safeDiscount.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                color: Color(0xFFDB7A00),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      safeDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$safeUnit - Stock $safeStock',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                AppFormatters.currency(safeFinalPrice),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (safeDiscount > 0)
                                Text(
                                  AppFormatters.currency(safePrice),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 170),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: actionWidget,
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
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[ProductCard] Failed to build productId=${product.id}: $error\n$stackTrace',
        );
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.broken_image_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product.name.trim().isEmpty
                      ? 'This product could not be rendered.'
                      : product.name,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
