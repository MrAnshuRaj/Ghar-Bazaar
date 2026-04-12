import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/utils/formatters.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/empty_state_card.dart';
import 'package:ghar_bazaar/core/widgets/order_status_chip.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/customer_profile.dart';
import 'package:ghar_bazaar/data/models/order_model.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/customer/presentation/widgets/customer_bottom_nav.dart';

class CustomerAccountScreen extends ConsumerWidget {
  const CustomerAccountScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(currentAppUserProvider);
    ref.invalidate(customerProfileProvider);
    ref.invalidate(customerOrdersProvider);
    try {
      await Future.wait<void>([
        ref.read(currentAppUserProvider.future),
        ref.read(customerProfileProvider.future),
        ref.read(customerOrdersProvider.future),
      ]);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[CustomerAccountScreen] refresh encountered: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      debugPrint('[CustomerAccountScreen] building account layout');
    }
    final userAsync = ref.watch(currentAppUserProvider);
    final profileAsync = ref.watch(customerProfileProvider);
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your account',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your personal details, delivery information, and recent orders.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            AsyncValueWidget(
              value: userAsync,
              data: (user) => _AccountOverviewCard(
                user: user,
                onEdit: () => context.push('/customer/create-profile'),
              ),
            ),
            const SizedBox(height: 14),
            AsyncValueWidget(
              value: profileAsync,
              data: (profile) => _CustomerProfileCard(
                profile: profile,
                onEdit: () => context.push('/customer/create-profile'),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AsyncValueWidget(
                    value: ordersAsync,
                    data: (orders) => _MiniStatCard(
                      icon: Icons.receipt_long_outlined,
                      label: 'Orders',
                      value: '${orders.length}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AsyncValueWidget(
                    value: ordersAsync,
                    data: (orders) => _MiniStatCard(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Last order',
                      value: orders.isEmpty
                          ? 'None yet'
                          : AppFormatters.shortDate(orders.first.createdAt),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
              value: ordersAsync,
              data: (orders) {
                if (orders.isEmpty) {
                  return const EmptyStateCard(
                    title: 'No orders yet',
                    subtitle:
                        'Your order history will appear here after you place your first order.',
                    icon: Icons.receipt_long_outlined,
                  );
                }
                return Column(
                  children: orders
                      .take(3)
                      .map((order) => _CustomerOrderCard(order: order))
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
      ),
    );
  }
}

class _AccountOverviewCard extends StatelessWidget {
  const _AccountOverviewCard({required this.user, required this.onEdit});

  final AppUser? user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _initialsFor(user?.name),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Customer account',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Email not available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _InlineActionButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoChip(
                  icon: Icons.phone_outlined,
                  label: user?.phone?.trim().isNotEmpty == true
                      ? user!.phone!
                      : 'Phone not added',
                ),
                const _InfoChip(
                  icon: Icons.verified_user_outlined,
                  label: 'Synced with Firebase',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerProfileCard extends StatelessWidget {
  const _CustomerProfileCard({
    required this.profile,
    required this.onEdit,
  });

  final CustomerProfile? profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (profile == null) {
      return EmptyStateCard(
        title: 'Complete your delivery profile',
        subtitle:
            'Add your phone number, locality, and address so orders can be delivered correctly.',
        icon: Icons.location_on_outlined,
        action: FilledButton(
          onPressed: onEdit,
          child: const Text('Add details'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Delivery details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _InlineActionButton(
                  onPressed: onEdit,
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Full name',
              value: profile!.fullName,
            ),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: profile!.phoneNumber,
            ),
            _DetailRow(
              icon: Icons.location_city_outlined,
              label: 'Locality',
              value: profile!.locality,
            ),
            _DetailRow(
              icon: Icons.home_outlined,
              label: 'Address',
              value: profile!.addressLine,
            ),
            if ((profile!.landmark ?? '').trim().isNotEmpty)
              _DetailRow(
                icon: Icons.pin_drop_outlined,
                label: 'Landmark',
                value: profile!.landmark!,
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerOrderCard extends StatelessWidget {
  const _CustomerOrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.shopName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Order ${order.id.substring(0, 8).toUpperCase()}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${AppFormatters.orderTimestamp(order.createdAt)} • ${order.itemCount} items',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${AppFormatters.currency(order.total)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _InlineActionButton extends StatelessWidget {
  const _InlineActionButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: child,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _initialsFor(String? name) {
  final parts = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) {
    return 'GB';
  }
  return parts.map((part) => part.substring(0, 1).toUpperCase()).join();
}
