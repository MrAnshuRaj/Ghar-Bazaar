import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghar_bazaar/core/utils/formatters.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/order_status_chip.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/vendor/presentation/widgets/vendor_bottom_nav.dart';

class VendorOrdersScreen extends ConsumerWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      bottomNavigationBar: const VendorBottomNav(currentIndex: 2),
      body: AsyncValueWidget(
        value: ref.watch(vendorOrdersProvider),
        data: (orders) => ListView(
          padding: const EdgeInsets.all(20),
          children: orders.isEmpty
              ? const [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('Incoming orders will appear here.'),
                    ),
                  ),
                ]
              : orders
                    .map(
                      (order) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Order ${order.id.substring(0, 8).toUpperCase()}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  OrderStatusChip(status: order.status),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Customer: ${order.customerName}'),
                              Text(
                                '${order.itemCount} items • ${AppFormatters.currency(order.total)}',
                              ),
                              Text('Payment: ${order.paymentMethod.label}'),
                              Text(
                                AppFormatters.orderTimestamp(order.createdAt),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<OrderStatus>(
                                value: order.status,
                                decoration: const InputDecoration(
                                  labelText: 'Update status',
                                ),
                                items: OrderStatus.values
                                    .map(
                                      (status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                        .read(marketplaceRepositoryProvider)
                                        .updateOrderStatus(order.id, value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
        ),
      ),
    );
  }
}
