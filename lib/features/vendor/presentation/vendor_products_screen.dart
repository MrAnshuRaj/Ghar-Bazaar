import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/empty_state_card.dart';
import 'package:ghar_bazaar/core/widgets/product_card.dart';
import 'package:ghar_bazaar/core/widgets/section_header.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/vendor/presentation/widgets/vendor_bottom_nav.dart';

class VendorProductsScreen extends ConsumerWidget {
  const VendorProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () => context.push('/vendor/add-product'),
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      bottomNavigationBar: const VendorBottomNav(currentIndex: 1),
      body: AsyncValueWidget(
        value: ref.watch(vendorProductsProvider),
        data: (products) {
          if (products.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyStateCard(
                title: 'No products listed yet',
                subtitle: 'Add your first product to start selling online.',
                icon: Icons.inventory_2_outlined,
                action: FilledButton(
                  onPressed: () => context.push('/vendor/add-product'),
                  child: const Text('Add Product'),
                ),
              ),
            );
          }
          final grouped = groupBy(
            products,
            (product) => product.category.label,
          );
          return ListView(
            padding: const EdgeInsets.all(20),
            children: grouped.entries
                .map(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: entry.key),
                      const SizedBox(height: 12),
                      ...entry.value.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProductCard(
                            product: product,
                            onAdd: () {},
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.filledTonal(
                                  onPressed: () => context.push(
                                    '/vendor/edit-product/${product.id}',
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: () => ref
                                      .read(marketplaceRepositoryProvider)
                                      .deleteProduct(product.id),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                )
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vendor/add-product'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
      ),
    );
  }
}
