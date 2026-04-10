import 'package:ghar_bazaar/data/models/product.dart';

class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineTotal => product.finalPrice * quantity;
  double get lineSavings => ((product.price - product.finalPrice) * quantity)
      .clamp(0, double.infinity);

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {'product': product.toMap(), 'quantity': quantity};
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(
        Map<String, dynamic>.from(map['product'] as Map),
      ),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
