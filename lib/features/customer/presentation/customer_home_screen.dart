import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/empty_state_card.dart';
import 'package:ghar_bazaar/core/widgets/section_header.dart';
import 'package:ghar_bazaar/core/widgets/shop_card.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/customer/presentation/widgets/customer_bottom_nav.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocality = ref.watch(selectedLocalityProvider);
    final customerProfile = ref.watch(customerProfileProvider);
    final currentUser = ref.watch(currentAppUserProvider);

    customerProfile.whenData((profile) {
      if (profile != null && selectedLocality == null) {
        Future<void>.microtask(
          () => ref
              .read(selectedLocalityProvider.notifier)
              .setLocality(profile.locality),
        );
      }
    });

    return Scaffold(
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(customerProfileProvider);
            ref.invalidate(currentAppUserProvider);
            if (selectedLocality != null) {
              ref.invalidate(shopsByLocalityProvider(selectedLocality));
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              currentUser.when(
                data: (user) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello ${user?.name.split(' ').first ?? 'there'}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your neighborhood grocery market, now online.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search shops in your locality',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 8),
                          const Text('Locality'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AsyncValueWidget(
                              value: ref.watch(localitiesProvider),
                              data: (localities) =>
                                  DropdownButtonFormField<String>(
                                    value:
                                        selectedLocality ??
                                        localities.firstOrNull,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                    ),
                                    items: localities
                                        .map(
                                          (item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        ref
                                            .read(
                                              selectedLocalityProvider.notifier,
                                            )
                                            .setLocality(value);
                                      }
                                    },
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F9E44), Color(0xFF8FCB6C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support your neighborhood stores',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fresh essentials from trusted local grocers, delivered with warmth and speed.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Quick filters',
                subtitle: 'Browse by the kind of essentials you need today',
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _category == 'All',
                      onSelected: (_) => setState(() => _category = 'All'),
                    ),
                    const SizedBox(width: 8),
                    ...ProductCategory.values
                        .take(8)
                        .map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category.label),
                              selected: _category == category.label,
                              onSelected: (_) =>
                                  setState(() => _category = category.label),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Nearby shops',
                subtitle: selectedLocality == null
                    ? 'Choose a locality to explore local grocery shops'
                    : 'Shops available around $selectedLocality',
              ),
              const SizedBox(height: 14),
              if (selectedLocality == null)
                const EmptyStateCard(
                  title: 'Select your locality',
                  subtitle:
                      'We will show stores near you the moment a locality is selected.',
                  icon: Icons.location_searching_rounded,
                )
              else
                AsyncValueWidget(
                  value: ref.watch(shopsByLocalityProvider(selectedLocality)),
                  data: (shops) {
                    final filtered = shops.where((shop) {
                      final query = _searchController.text.trim().toLowerCase();
                      final matchesQuery =
                          query.isEmpty ||
                          shop.name.toLowerCase().contains(query);
                      final matchesCategory =
                          _category == 'All' ||
                          shop.categories.contains(_category);
                      return matchesQuery && matchesCategory;
                    }).toList();
                    if (filtered.isEmpty) {
                      return const EmptyStateCard(
                        title: 'No shops available in this locality yet',
                        subtitle:
                            'Try a different locality or check back soon as more neighborhood stores come online.',
                        icon: Icons.storefront_outlined,
                      );
                    }
                    return Column(
                      children: filtered
                          .map(
                            (shop) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: ShopCard(
                                shop: shop,
                                onTap: () => context.push(
                                  '/customer/shop/${shop.id}',
                                  extra: shop,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNullExt<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
