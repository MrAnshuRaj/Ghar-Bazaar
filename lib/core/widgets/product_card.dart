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
    final theme = Theme.of(context);
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
                          product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (product.discountPercent > 0)
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
                            '${product.discountPercent.toStringAsFixed(0)}% OFF',
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
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${product.unit} - Stock ${product.stock}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        AppFormatters.currency(product.finalPrice),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (product.discountPercent > 0)
                        Text(
                          AppFormatters.currency(product.price),
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const Spacer(),
                      if (trailing != null)
                        trailing!
                      else if (quantity > 0)
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: onDecrease,
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text('$quantity'),
                            ),
                            IconButton.filled(
                              onPressed: onIncrease,
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        )
                      else
                        FilledButton(
                          onPressed: onAdd,
                          child: const Text('Add'),
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
  }
}
