import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/utils/app_feedback.dart';
import 'package:ghar_bazaar/core/utils/formatters.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/app_primary_button.dart';
import 'package:ghar_bazaar/data/models/address.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/order_model.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;
  bool _submitting = false;
  final _uuid = const Uuid();

  Future<void> _placeOrder() async {
    if (_submitting) {
      return;
    }
    final cart = ref.read(cartControllerProvider);
    final session = ref.read(authRepositoryProvider).currentSession;
    if (cart.isEmpty || session == null) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Your session or cart is no longer available. Please try again.',
          isError: true,
        );
      }
      return;
    }
    final customerProfile = await ref.read(customerProfileProvider.future);
    if (customerProfile == null) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Please complete your profile before placing the order.',
          isError: true,
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _submitting = true);
    try {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutScreen] placing order for shop=${cart.shopId}, vendor=${cart.vendorId}, payment=${_paymentMethod.value}',
        );
      }
      if (_paymentMethod != PaymentMethod.cashOnDelivery) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 80),
                const SizedBox(height: 16),
                Text('Processing ${_paymentMethod.label}'),
                const SizedBox(height: 8),
                const Text(
                  'Payment assumed successful for this demo checkout flow.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Confirm Payment'),
                ),
              ],
            ),
          ),
        );
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }

      final orderId = _uuid.v4();
      final order = OrderModel(
        id: orderId,
        customerId: session.uid,
        vendorId: cart.vendorId ?? '',
        shopId: cart.shopId ?? '',
        shopName: cart.shopName ?? 'Your Shop',
        customerName: customerProfile.fullName,
        customerPhone: customerProfile.phoneNumber,
        locality: customerProfile.locality,
        deliveryAddress: Address(
          locality: customerProfile.locality,
          line1: customerProfile.addressLine,
          landmark: customerProfile.landmark,
        ),
        items: cart.items,
        subtotal: cart.subtotal,
        discount: cart.savings,
        deliveryFee: cart.deliveryFee,
        total: cart.total,
        paymentMethod: _paymentMethod,
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
      );
      await ref
          .read(marketplaceRepositoryProvider)
          .createOrder(order)
          .timeout(const Duration(seconds: 12));
      await ref.read(cartControllerProvider.notifier).clear();
      ref.invalidate(customerOrdersProvider);
      ref.invalidate(vendorOrdersProvider);
      ref.invalidate(orderProvider(orderId));
      if (!mounted) {
        return;
      }
      context.go('/customer/order-success/$orderId');
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (kDebugMode) {
        debugPrint('[CheckoutScreen] place order failed: $error');
      }
      showAppSnackBar(
        context,
        'We could not place your order right now. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : AsyncValueWidget(
              value: ref.watch(customerProfileProvider),
              data: (profile) {
                if (profile == null) {
                  return const Center(
                    child: Text('Please complete your profile first.'),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery address',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 10),
                            Text(profile.fullName),
                            Text(profile.addressLine),
                            Text(profile.locality),
                            if ((profile.landmark ?? '').isNotEmpty)
                              Text(profile.landmark!),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment method',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 10),
                            RadioGroup<PaymentMethod>(
                              groupValue: _paymentMethod,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _paymentMethod = value);
                                }
                              },
                              child: Column(
                                children: PaymentMethod.values
                                    .map(
                                      (method) => RadioListTile<PaymentMethod>(
                                        value: method,
                                        title: Text(method.label),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order summary',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 10),
                            ...cart.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.product.name} x${item.quantity}',
                                      ),
                                    ),
                                    Text(
                                      AppFormatters.currency(item.lineTotal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            _CheckoutRow(
                              label: 'Subtotal',
                              value: AppFormatters.currency(cart.subtotal),
                            ),
                            _CheckoutRow(
                              label: 'Savings',
                              value:
                                  '- ${AppFormatters.currency(cart.savings)}',
                            ),
                            _CheckoutRow(
                              label: 'Delivery fee',
                              value: cart.deliveryFee == 0
                                  ? 'Free'
                                  : AppFormatters.currency(cart.deliveryFee),
                            ),
                            const Divider(height: 24),
                            _CheckoutRow(
                              label: 'Total payable',
                              value: AppFormatters.currency(cart.total),
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppPrimaryButton(
                      label: _paymentMethod == PaymentMethod.upi
                          ? 'Pay & Place Order'
                          : 'Place Order',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _placeOrder,
                      isLoading: _submitting,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow({
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
