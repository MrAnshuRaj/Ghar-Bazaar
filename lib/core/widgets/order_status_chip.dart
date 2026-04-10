import 'package:flutter/material.dart';
import 'package:ghar_bazaar/data/models/enums.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      OrderStatus.placed => scheme.primary,
      OrderStatus.accepted => Colors.indigo,
      OrderStatus.packed => Colors.orange,
      OrderStatus.outForDelivery => Colors.deepPurple,
      OrderStatus.delivered => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}
