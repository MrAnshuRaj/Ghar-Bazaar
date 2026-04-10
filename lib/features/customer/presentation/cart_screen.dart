import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/utils/formatters.dart';
import 'package:ghar_bazaar/core/widgets/empty_state_card.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/customer/presentation/widgets/customer_bottom_nav.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 1),
      body: cart.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyStateCard(
                title: 'Your cart is empty',
                subtitle:
                    'Add essentials from a nearby store to begin checkout.',
                icon: Icons.shopping_cart_outlined,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cart.shopName ?? 'Selected shop',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.clear,
                          child: const Text('Clear cart'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...cart.items.map(
                  (item) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(item.product.name),
                      subtitle: Text(
                        '${item.product.unit} - ${AppFormatters.currency(item.product.finalPrice)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => controller.changeQuantity(
                              item.product.id,
                              item.quantity - 1,
                            ),
                            icon: const Icon(Icons.remove_rounded),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('${item.quantity}'),
                          ),
                          IconButton.filled(
                            onPressed: () => controller.changeQuantity(
                              item.product.id,
                              item.quantity + 1,
                            ),
                            icon: const Icon(Icons.add_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill summary',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        _PriceRow(
                          label: 'Subtotal',
                          value: AppFormatters.currency(cart.subtotal),
                        ),
                        _PriceRow(
                          label: 'Savings',
                          value: '- ${AppFormatters.currency(cart.savings)}',
                        ),
                        _PriceRow(
                          label: 'Delivery fee',
                          value: cart.deliveryFee == 0
                              ? 'Free'
                              : AppFormatters.currency(cart.deliveryFee),
                        ),
                        const Divider(height: 28),
                        _PriceRow(
                          label: 'Total',
                          value: AppFormatters.currency(cart.total),
                          isBold: true,
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: () => context.push('/customer/checkout'),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}
