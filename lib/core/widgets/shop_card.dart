import 'package:flutter/material.dart';
import 'package:ghar_bazaar/core/widgets/marketplace_image.dart';
import 'package:ghar_bazaar/data/models/shop.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({super.key, required this.shop, required this.onTap});

  final Shop shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarketplaceImage(imageUrl: shop.imageUrl, height: 180),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shop.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFA726),
                    size: 18,
                  ),
                  Text(shop.rating.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                shop.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons.pin_drop_outlined,
                    label: shop.locality,
                  ),
                  _MetaChip(
                    icon: Icons.access_time_rounded,
                    label: shop.deliveryEstimate,
                  ),
                  _MetaChip(
                    icon: Icons.dashboard_customize_outlined,
                    label: '${shop.categories.length} categories',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton(onPressed: onTap, child: const Text('View Shop')),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
