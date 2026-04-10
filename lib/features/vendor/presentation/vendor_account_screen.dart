import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/vendor/presentation/widgets/vendor_bottom_nav.dart';

class VendorAccountScreen extends ConsumerWidget {
  const VendorAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      bottomNavigationBar: const VendorBottomNav(currentIndex: 3),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AsyncValueWidget(
            value: ref.watch(vendorProfileProvider),
            data: (profile) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                title: Text(profile?.ownerName ?? 'Vendor profile'),
                subtitle: Text(
                  profile == null
                      ? 'Create your vendor profile to manage your digital store.'
                      : '${profile.shopName}\n${profile.locality}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () => context.push('/vendor/create-profile'),
                  child: const Text('Edit'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AsyncValueWidget(
            value: ref.watch(vendorShopProvider),
            data: (shop) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                title: Text(shop?.name ?? 'Shop not created'),
                subtitle: Text(
                  shop == null
                      ? 'Set up your shop details to go live.'
                      : '${shop.address}\n${shop.deliveryEstimate}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () => context.push('/vendor/create-shop'),
                  child: Text(shop == null ? 'Create' : 'Edit'),
                ),
              ),
            ),
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
