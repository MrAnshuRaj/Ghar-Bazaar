import 'package:cloud_firestore/cloud_firestore.dart';
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
    final discountRaw =
        _asDouble(map['discountPercent']) ?? _asDouble(map['discount']) ?? 0;
    final createdAt = _asDateTime(map['createdAt']) ?? DateTime.now();
    return Product(
      id: _asString(map['id']),
      vendorId: _asString(map['vendorId']),
      shopId: _asString(map['shopId']),
      name: _asString(map['name']),
      description: _asString(map['description']),
      imageUrl: _asString(map['imageUrl']),
      category: productCategoryFromValue(_asStringOrNull(map['category'])),
      price: _asDouble(map['price']) ?? 0,
      discountPercent: discountRaw.isFinite ? discountRaw : 0,
      stock: _asInt(map['stock']) ?? 0,
      unit: _asString(map['unit']),
      locality: _asString(map['locality']),
      isAvailable: _asBool(map['isAvailable']) ?? true,
      createdAt: createdAt,
    );
  }
}

String _asString(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value.trim();
  }
  return value.toString().trim();
}

String? _asStringOrNull(Object? value) {
  final parsed = _asString(value);
  return parsed.isEmpty ? null : parsed;
}

double? _asDouble(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

int? _asInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? double.tryParse(value.trim())?.toInt();
  }
  return null;
}

bool? _asBool(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }
  return null;
}

DateTime? _asDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    final epoch = int.tryParse(value.trim());
    if (epoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }
    return DateTime.tryParse(value.trim());
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  return null;
}
