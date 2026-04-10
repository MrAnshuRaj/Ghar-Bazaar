import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghar_bazaar/core/utils/formatters.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/order_status_chip.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/providers.dart';

class CustomerOrdersScreen extends ConsumerWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: AsyncValueWidget(
        value: ref.watch(customerOrdersProvider),
        data: (orders) => ListView(
          padding: const EdgeInsets.all(20),
          children: orders.isEmpty
              ? const [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('No orders placed yet.'),
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
                                      order.shopName,
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
                              Text(
                                'Order ID: ${order.id.substring(0, 8).toUpperCase()}',
                              ),
                              Text(
                                AppFormatters.orderTimestamp(order.createdAt),
                              ),
                              Text(
                                '${order.itemCount} items • ${AppFormatters.currency(order.total)}',
                              ),
                              Text('Payment: ${order.paymentMethod.label}'),
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
