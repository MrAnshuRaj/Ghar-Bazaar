import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/empty_state_card.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/vendor/presentation/widgets/vendor_bottom_nav.dart';

class VendorHomeScreen extends ConsumerWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider);
    final shop = ref.watch(vendorShopProvider);
    final products = ref.watch(vendorProductsProvider);
    final orders = ref.watch(vendorOrdersProvider);

    return Scaffold(
      bottomNavigationBar: const VendorBottomNav(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(vendorShopProvider);
            ref.invalidate(vendorProductsProvider);
            ref.invalidate(vendorOrdersProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              user.when(
                data: (value) => Text(
                  'Welcome back, ${value?.name.split(' ').first ?? 'Vendor'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              const Text(
                'Run your neighborhood grocery business with a clean digital storefront.',
              ),
              const SizedBox(height: 18),
              AsyncValueWidget(
                value: shop,
                data: (shopData) {
                  if (shopData == null) {
                    return EmptyStateCard(
                      title: 'Create your shop to go live',
                      subtitle:
                          'Add your shop details, then start listing products for local customers.',
                      icon: Icons.storefront_outlined,
                      action: FilledButton(
                        onPressed: () => context.push('/vendor/create-shop'),
                        child: const Text('Create Shop'),
                      ),
                    );
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shopData.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(shopData.description),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(label: Text(shopData.locality)),
                              Chip(label: Text(shopData.deliveryEstimate)),
                              if (shopData.openingHours != null)
                                Chip(label: Text(shopData.openingHours!)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: products.when(
                      data: (items) => _StatCard(
                        label: 'Products',
                        value: '${items.length}',
                        icon: Icons.inventory_2_outlined,
                      ),
                      loading: () => const _StatCard(
                        label: 'Products',
                        value: '...',
                        icon: Icons.inventory_2_outlined,
                      ),
                      error: (_, _) => const _StatCard(
                        label: 'Products',
                        value: '-',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: orders.when(
                      data: (items) => _StatCard(
                        label: 'Orders',
                        value: '${items.length}',
                        icon: Icons.receipt_long_outlined,
                      ),
                      loading: () => const _StatCard(
                        label: 'Orders',
                        value: '...',
                        icon: Icons.receipt_long_outlined,
                      ),
                      error: (_, _) => const _StatCard(
                        label: 'Orders',
                        value: '-',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Quick actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.push('/vendor/create-shop'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.store_mall_directory_outlined),
                    label: const Text('Create shop'),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push('/vendor/add-product'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add_box_outlined),
                    label: const Text('Add product'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/vendor/products'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Manage listings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
