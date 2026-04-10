import 'package:ghar_bazaar/data/models/enums.dart';

class Product {
  const Product({
    required this.id,
    required this.vendorId,
    required this.shopId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.discountPercent,
    required this.stock,
    required this.unit,
    required this.locality,
    required this.isAvailable,
    required this.createdAt,
  });

  final String id;
  final String vendorId;
  final String shopId;
  final String name;
  final String description;
  final String imageUrl;
  final ProductCategory category;
  final double price;
  final double discountPercent;
  final int stock;
  final String unit;
  final String locality;
  final bool isAvailable;
  final DateTime createdAt;

  double get finalPrice => price - (price * discountPercent / 100);

  Product copyWith({
    String? id,
    String? vendorId,
    String? shopId,
    String? name,
    String? description,
    String? imageUrl,
    ProductCategory? category,
    double? price,
    double? discountPercent,
    int? stock,
    String? unit,
    String? locality,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      locality: locality ?? this.locality,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'shopId': shopId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.name,
      'price': price,
      'discount': discountPercent,
      'discountPercent': discountPercent,
      'finalPrice': finalPrice,
      'stock': stock,
      'unit': unit,
      'locality': locality,
      'isAvailable': isAvailable,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      shopId: map['shopId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      category: productCategoryFromValue(map['category'] as String?),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      discountPercent:
          (map['discountPercent'] as num?)?.toDouble() ??
          (map['discount'] as num?)?.toDouble() ??
          0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      unit: map['unit'] as String? ?? '',
      locality: map['locality'] as String? ?? '',
      isAvailable: map['isAvailable'] as bool? ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
