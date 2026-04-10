import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/utils/formatters.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/order_status_chip.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/customer/presentation/widgets/customer_bottom_nav.dart';

class CustomerAccountScreen extends ConsumerWidget {
  const CustomerAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AsyncValueWidget(
            value: ref.watch(currentAppUserProvider),
            data: (user) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                title: Text(user?.name ?? 'Your profile'),
                subtitle: Text(user?.email ?? ''),
                trailing: FilledButton.tonal(
                  onPressed: () => context.push('/customer/create-profile'),
                  child: const Text('Edit'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AsyncValueWidget(
            value: ref.watch(customerProfileProvider),
            data: (profile) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                title: Text(profile?.locality ?? 'Locality not selected'),
                subtitle: Text(
                  profile == null
                      ? 'Complete your profile to add your delivery address.'
                      : '${profile.addressLine}\n${profile.landmark ?? ''}',
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Recent orders',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/customer/orders'),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AsyncValueWidget(
            value: ref.watch(customerOrdersProvider),
            data: (orders) {
              if (orders.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Your order history will appear here.'),
                  ),
                );
              }
              return Column(
                children: orders
                    .take(3)
                    .map(
                      (order) => Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(18),
                          title: Text(order.shopName),
                          subtitle: Text(
                            '${AppFormatters.orderTimestamp(order.createdAt)} • ${order.itemCount} items',
                          ),
                          trailing: OrderStatusChip(status: order.status),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth/signin');
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
