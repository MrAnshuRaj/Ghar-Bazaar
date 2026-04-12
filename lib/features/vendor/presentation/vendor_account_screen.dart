import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/empty_state_card.dart';
import 'package:ghar_bazaar/core/widgets/marketplace_image.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/models/vendor_profile.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/vendor/presentation/widgets/vendor_bottom_nav.dart';

class VendorAccountScreen extends ConsumerWidget {
  const VendorAccountScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(currentAppUserProvider);
    ref.invalidate(vendorProfileProvider);
    ref.invalidate(vendorShopProvider);
    ref.invalidate(vendorOrdersProvider);
    try {
      await Future.wait<void>([
        ref.read(currentAppUserProvider.future),
        ref.read(vendorProfileProvider.future),
        ref.read(vendorShopProvider.future),
        ref.read(vendorOrdersProvider.future),
      ]);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[VendorAccountScreen] refresh encountered: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      debugPrint('[VendorAccountScreen] building account layout');
    }
    final userAsync = ref.watch(currentAppUserProvider);
    final profileAsync = ref.watch(vendorProfileProvider);
    final shopAsync = ref.watch(vendorShopProvider);
    final ordersAsync = ref.watch(vendorOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      bottomNavigationBar: const VendorBottomNav(currentIndex: 3),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Vendor account',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Review and update the owner profile, shop details, and store status here.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            AsyncValueWidget(
              value: userAsync,
              data: (user) => _VendorUserCard(
                user: user,
                onEdit: () => context.push('/vendor/create-profile'),
              ),
            ),
            const SizedBox(height: 14),
            AsyncValueWidget(
              value: profileAsync,
              data: (profile) => _VendorProfileCard(
                profile: profile,
                onEdit: () => context.push('/vendor/create-profile'),
              ),
            ),
            const SizedBox(height: 14),
            AsyncValueWidget(
              value: shopAsync,
              data: (shop) => _VendorShopCard(
                shop: shop,
                onEdit: () => context.push('/vendor/create-shop'),
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
                    value: shopAsync,
                    data: (shop) => _MiniStatCard(
                      icon: Icons.storefront_outlined,
                      label: 'Shop status',
                      value: shop == null ? 'Setup needed' : 'Live',
                    ),
                  ),
                ),
              ],
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

class _VendorUserCard extends StatelessWidget {
  const _VendorUserCard({required this.user, required this.onEdit});

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
                        user?.name ?? 'Vendor account',
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
                  icon: Icons.cloud_done_outlined,
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

class _VendorProfileCard extends StatelessWidget {
  const _VendorProfileCard({
    required this.profile,
    required this.onEdit,
  });

  final VendorProfile? profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (profile == null) {
      return EmptyStateCard(
        title: 'Complete your vendor profile',
        subtitle:
            'Add owner and business information so customers can trust your storefront.',
        icon: Icons.badge_outlined,
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
                    'Owner details',
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
              label: 'Owner name',
              value: profile!.ownerName,
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
              icon: Icons.route_outlined,
              label: 'Delivery radius',
              value: profile!.deliveryRadiusKm == null
                  ? 'Not set'
                  : '${profile!.deliveryRadiusKm!.toStringAsFixed(0)} km',
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorShopCard extends StatelessWidget {
  const _VendorShopCard({required this.shop, required this.onEdit});

  final Shop? shop;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (shop == null) {
      return EmptyStateCard(
        title: 'Your shop is not live yet',
        subtitle:
            'Create the storefront to publish products and start receiving orders.',
        icon: Icons.storefront_outlined,
        action: FilledButton(
          onPressed: onEdit,
          child: const Text('Create shop'),
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
                    'Shop details',
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
            MarketplaceImage(
              imageUrl: shop!.imageUrl,
              height: 160,
              borderRadius: BorderRadius.circular(24),
              placeholderIcon: Icons.storefront_rounded,
            ),
            const SizedBox(height: 16),
            Text(
              shop!.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              shop!.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: shop!.address,
            ),
            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Delivery estimate',
              value: shop!.deliveryEstimate,
            ),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Contact',
              value: shop!.contactNumber,
            ),
            if ((shop!.openingHours ?? '').trim().isNotEmpty)
              _DetailRow(
                icon: Icons.schedule_outlined,
                label: 'Opening hours',
                value: shop!.openingHours!,
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
