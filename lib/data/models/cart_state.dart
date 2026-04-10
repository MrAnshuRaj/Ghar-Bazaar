import 'dart:convert';

import 'package:ghar_bazaar/data/models/cart_item.dart';
import 'package:ghar_bazaar/data/models/product.dart';

class CartState {
  const CartState({
    this.shopId,
    this.shopName,
    this.vendorId,
    this.items = const [],
  });

  final String? shopId;
  final String? shopName;
  final String? vendorId;
  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);
  double get savings => items.fold(0, (sum, item) => sum + item.lineSavings);
  double get deliveryFee => isEmpty ? 0 : (subtotal >= 500 ? 0 : 29);
  double get total => subtotal + deliveryFee;

  int quantityFor(String productId) {
    return items
            .where((item) => item.product.id == productId)
            .map((item) => item.quantity)
            .firstOrNull ??
        0;
  }

  CartState copyWith({
    String? shopId,
    String? shopName,
    String? vendorId,
    List<CartItem>? items,
  }) {
    return CartState(
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      vendorId: vendorId ?? this.vendorId,
      items: items ?? this.items,
    );
  }

  CartState add(Product product, {String? resolvedShopName}) {
    final updatedItems = [...items];
    final index = updatedItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index == -1) {
      updatedItems.add(CartItem(product: product, quantity: 1));
    } else {
      final current = updatedItems[index];
      updatedItems[index] = current.copyWith(quantity: current.quantity + 1);
    }
    return CartState(
      shopId: product.shopId,
      shopName: resolvedShopName ?? shopName,
      vendorId: product.vendorId,
      items: updatedItems,
    );
  }

  CartState changeQuantity(String productId, int nextQuantity) {
    final updatedItems = <CartItem>[];
    for (final item in items) {
      if (item.product.id == productId) {
        if (nextQuantity > 0) {
          updatedItems.add(item.copyWith(quantity: nextQuantity));
        }
      } else {
        updatedItems.add(item);
      }
    }
    if (updatedItems.isEmpty) {
      return const CartState();
    }
    return copyWith(items: updatedItems);
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'vendorId': vendorId,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory CartState.fromMap(Map<String, dynamic> map) {
    return CartState(
      shopId: map['shopId'] as String?,
      shopName: map['shopName'] as String?,
      vendorId: map['vendorId'] as String?,
      items: (map['items'] as List? ?? const [])
          .map(
            (item) => CartItem.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }

  factory CartState.fromJson(String source) {
    return CartState.fromMap(
      Map<String, dynamic>.from(jsonDecode(source) as Map),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
