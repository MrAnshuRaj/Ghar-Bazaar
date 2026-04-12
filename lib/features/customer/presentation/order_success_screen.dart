import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/utils/formatters.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/order_status_chip.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/providers.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: AsyncValueWidget(
        value: ref.watch(orderProvider(orderId)),
        data: (order) {
          if (order == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 52),
                    const SizedBox(height: 16),
                    const Text(
                      'We could not load this order yet.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(orderProvider(orderId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final etaMinutes = _etaMinutesFor(order.id);
          final partner = _deliveryPartnerFor(order.id);
          final cod = order.paymentMethod == PaymentMethod.cashOnDelivery;
          final headline = cod
              ? 'Order confirmed. Keep cash ready.'
              : 'Payment successful and order confirmed.';
          final subtitle = cod
              ? 'Delivery partner ${partner.name} is arriving in about $etaMinutes-${
                  etaMinutes + 5
                } mins and may call you before arrival.'
              : '${partner.name} is expected in about $etaMinutes-${
                  etaMinutes + 5
                } mins. Your order is already marked as paid.';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          cod
                              ? Icons.delivery_dining_rounded
                              : Icons.check_circle_rounded,
                          size: 52,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        headline,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(subtitle, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OrderStatusChip(status: order.status),
                    ],
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
                        'Delivery status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(
                        label: 'Order ID',
                        value: order.id.substring(0, 8).toUpperCase(),
                      ),
                      _InfoRow(label: 'Shop', value: order.shopName),
                      _InfoRow(
                        label: 'Placed at',
                        value: AppFormatters.orderTimestamp(order.createdAt),
                      ),
                      _InfoRow(
                        label: 'ETA',
                        value: '$etaMinutes-${etaMinutes + 5} mins',
                      ),
                      _InfoRow(
                        label: 'Payment',
                        value: cod
                            ? 'Cash on Delivery'
                            : '${order.paymentMethod.label} paid',
                      ),
                    ],
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
                        'Delivery partner',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(partner.name.substring(0, 1)),
                        ),
                        title: Text(partner.name),
                        subtitle: Text(
                          'Rating ${partner.rating.toStringAsFixed(1)} - ${partner.phone}',
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: () => _showCallDialog(context, partner),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Call'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cod
                            ? 'Get ready with cash. The delivery partner may call before reaching your location.'
                            : 'The delivery partner may call if they need directions or a gate code.',
                      ),
                    ],
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
                        'Help & support',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.help_outline_rounded),
                        title: const Text('Need help with this order?'),
                        subtitle: const Text(
                          'Open support tips for delivery, payment, and contact guidance.',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showHelpSheet(context, cod: cod),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/customer/home'),
                child: const Text('Back to Home'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCallDialog(BuildContext context, _DeliveryPartner partner) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call delivery partner'),
        content: Text(
          'Call ${partner.name} at ${partner.phone}.\n\nThis demo shows the partner contact details here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context, {required bool cod}) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help & support',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              const Text('If the order looks delayed, wait a few minutes and refresh your orders page.'),
              const SizedBox(height: 10),
              Text(
                cod
                    ? 'For cash on delivery, keep change ready and keep your phone nearby.'
                    : 'Your payment is treated as successful in this demo flow, so no further payment action is needed.',
              ),
              const SizedBox(height: 10),
              const Text('If the delivery partner calls, confirm your exact address or landmark.'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryPartner {
  const _DeliveryPartner({
    required this.name,
    required this.rating,
    required this.phone,
  });

  final String name;
  final double rating;
  final String phone;
}

int _etaMinutesFor(String orderId) {
  final seed = orderId.codeUnits.fold<int>(0, (sum, value) => sum + value);
  return 10 + (seed % 11);
}

_DeliveryPartner _deliveryPartnerFor(String orderId) {
  const names = [
    'Aman Singh',
    'Rahul Verma',
    'Neha Sharma',
    'Pooja Yadav',
    'Vikram Patel',
  ];
  final seed = orderId.codeUnits.fold<int>(0, (sum, value) => sum + value);
  final partnerIndex = seed % names.length;
  final rating = 4.2 + ((seed % 7) * 0.1);
  final suffix = (1000 + (seed % 9000)).toString();
  return _DeliveryPartner(
    name: names[partnerIndex],
    rating: rating > 4.8 ? 4.8 : rating,
    phone: '+91 98$suffix$suffix'.substring(0, 14),
  );
}
