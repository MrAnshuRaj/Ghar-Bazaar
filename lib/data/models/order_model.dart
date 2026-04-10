import 'package:ghar_bazaar/data/models/address.dart';
import 'package:ghar_bazaar/data/models/cart_item.dart';
import 'package:ghar_bazaar/data/models/enums.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.shopId,
    required this.shopName,
    required this.customerName,
    required this.customerPhone,
    required this.locality,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final String vendorId;
  final String shopId;
  final String shopName;
  final String customerName;
  final String customerPhone;
  final String locality;
  final Address deliveryAddress;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderModel copyWith({OrderStatus? status}) {
    return OrderModel(
      id: id,
      customerId: customerId,
      vendorId: vendorId,
      shopId: shopId,
      shopName: shopName,
      customerName: customerName,
      customerPhone: customerPhone,
      locality: locality,
      deliveryAddress: deliveryAddress,
      items: items,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'vendorId': vendorId,
      'shopId': shopId,
      'shopName': shopName,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'locality': locality,
      'deliveryAddress': deliveryAddress.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'totalAmount': total,
      'total': total,
      'paymentMethod': paymentMethod.value,
      'status': status.value,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      shopId: map['shopId'] as String? ?? '',
      shopName: map['shopName'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      locality: map['locality'] as String? ?? '',
      deliveryAddress: Address.fromMap(
        Map<String, dynamic>.from(map['deliveryAddress'] as Map? ?? {}),
      ),
      items: (map['items'] as List? ?? const [])
          .map(
            (item) => CartItem.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
      total:
          (map['total'] as num?)?.toDouble() ??
          (map['totalAmount'] as num?)?.toDouble() ??
          0,
      paymentMethod: paymentMethodFromValue(map['paymentMethod'] as String?),
      status: orderStatusFromValue(map['status'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
