import 'dart:async';

import 'package:ghar_bazaar/core/constants/app_constants.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/customer_profile.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/order_model.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/models/vendor_profile.dart';
import 'package:ghar_bazaar/data/sources/local/local_database.dart';
import 'package:ghar_bazaar/data/sources/marketplace_data_source.dart';

class LocalMarketplaceDataSource implements MarketplaceDataSource {
  LocalMarketplaceDataSource(this._database);

  final LocalDatabase _database;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Future<Map<String, dynamic>> _snapshot() async {
    await _database.ensureSeeded();
    return _database.read();
  }

  List<Map<String, dynamic>> _collection(
    Map<String, dynamic> data,
    String key,
  ) {
    return (data[key] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> _saveCollection(
    String key,
    List<Map<String, dynamic>> collection,
  ) async {
    final data = await _snapshot();
    data[key] = collection;
    await _database.write(data);
    _changes.add(null);
  }

  Future<void> _syncShopCategories(String shopId) async {
    final snapshot = await _snapshot();
    final products = _collection(snapshot, 'products')
        .map(Product.fromMap)
        .where((product) => product.shopId == shopId)
        .toList();
    final shops = _collection(snapshot, 'shops').map(Shop.fromMap).toList();
    final index = shops.indexWhere((shop) => shop.id == shopId);
    if (index == -1) {
      return;
    }
    final categories =
        products.map((product) => product.category.label).toSet().toList()
          ..sort();
    shops[index] = shops[index].copyWith(categories: categories);
    await _saveCollection('shops', shops.map((shop) => shop.toMap()).toList());
  }

  Stream<List<T>> _watchList<T>(Future<List<T>> Function() query) async* {
    yield await query();
    yield* _changes.stream.asyncMap((_) => query());
  }

  Stream<T?> _watchOne<T>(Future<T?> Function() query) async* {
    yield await query();
    yield* _changes.stream.asyncMap((_) => query());
  }

  @override
  Future<void> seedDemoData() async {
    await _database.ensureSeeded();
  }

  @override
  Future<AppUser?> getUser(String uid) async {
    final users = _collection(
      await _snapshot(),
      'users',
    ).map(AppUser.fromMap).toList();
    for (final user in users) {
      if (user.uid == uid) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<void> saveUser(AppUser user) async {
    final users = _collection(
      await _snapshot(),
      'users',
    ).map(AppUser.fromMap).toList();
    final index = users.indexWhere((item) => item.uid == user.uid);
    if (index == -1) {
      users.add(user);
    } else {
      users[index] = user;
    }
    await _saveCollection('users', users.map((item) => item.toMap()).toList());
  }

  @override
  Future<CustomerProfile?> getCustomerProfile(String uid) async {
    final profiles = _collection(
      await _snapshot(),
      'customer_profiles',
    ).map(CustomerProfile.fromMap).toList();
    for (final profile in profiles) {
      if (profile.uid == uid) {
        return profile;
      }
    }
    return null;
  }

  @override
  Future<void> saveCustomerProfile(CustomerProfile profile) async {
    final profiles = _collection(
      await _snapshot(),
      'customer_profiles',
    ).map(CustomerProfile.fromMap).toList();
    final index = profiles.indexWhere((item) => item.uid == profile.uid);
    if (index == -1) {
      profiles.add(profile);
    } else {
      profiles[index] = profile;
    }
    await _saveCollection(
      'customer_profiles',
      profiles.map((item) => item.toMap()).toList(),
    );
  }

  @override
  Future<VendorProfile?> getVendorProfile(String uid) async {
    final profiles = _collection(
      await _snapshot(),
      'vendor_profiles',
    ).map(VendorProfile.fromMap).toList();
    for (final profile in profiles) {
      if (profile.uid == uid) {
        return profile;
      }
    }
    return null;
  }

  @override
  Future<void> saveVendorProfile(VendorProfile profile) async {
    final profiles = _collection(
      await _snapshot(),
      'vendor_profiles',
    ).map(VendorProfile.fromMap).toList();
    final index = profiles.indexWhere((item) => item.uid == profile.uid);
    if (index == -1) {
      profiles.add(profile);
    } else {
      profiles[index] = profile;
    }
    await _saveCollection(
      'vendor_profiles',
      profiles.map((item) => item.toMap()).toList(),
    );
  }

  @override
  Stream<List<Shop>> watchShopsByLocality(String locality) {
    return _watchList(() async {
      final shops =
          _collection(await _snapshot(), 'shops').map(Shop.fromMap).toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
      return shops.where((shop) => shop.locality == locality).toList();
    });
  }

  @override
  Stream<Shop?> watchVendorShop(String vendorId) {
    return _watchOne(() async {
      final shops = _collection(
        await _snapshot(),
        'shops',
      ).map(Shop.fromMap).toList();
      for (final shop in shops) {
        if (shop.vendorId == vendorId) {
          return shop;
        }
      }
      return null;
    });
  }

  @override
  Future<Shop?> getShop(String shopId) async {
    final shops = _collection(
      await _snapshot(),
      'shops',
    ).map(Shop.fromMap).toList();
    for (final shop in shops) {
      if (shop.id == shopId) {
        return shop;
      }
    }
    return null;
  }

  @override
  Future<void> upsertShop(Shop shop) async {
    final shops = _collection(
      await _snapshot(),
      'shops',
    ).map(Shop.fromMap).toList();
    final index = shops.indexWhere((item) => item.id == shop.id);
    if (index == -1) {
      shops.add(shop);
    } else {
      shops[index] = shop;
    }
    await _saveCollection('shops', shops.map((item) => item.toMap()).toList());
  }

  @override
  Stream<List<Product>> watchShopProducts(String shopId) {
    return _watchList(() async {
      final products = _collection(
        await _snapshot(),
        'products',
      ).map(Product.fromMap).toList()..sort((a, b) => a.name.compareTo(b.name));
      return products.where((product) => product.shopId == shopId).toList();
    });
  }

  @override
  Stream<List<Product>> watchVendorProducts(String vendorId) {
    return _watchList(() async {
      final products =
          _collection(
              await _snapshot(),
              'products',
            ).map(Product.fromMap).toList()
            ..sort((a, b) => a.category.label.compareTo(b.category.label));
      return products.where((product) => product.vendorId == vendorId).toList();
    });
  }

  @override
  Future<Product?> getProduct(String productId) async {
    final products = _collection(
      await _snapshot(),
      'products',
    ).map(Product.fromMap).toList();
    for (final product in products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

  @override
  Future<void> upsertProduct(Product product) async {
    final products = _collection(
      await _snapshot(),
      'products',
    ).map(Product.fromMap).toList();
    final index = products.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      products.add(product);
    } else {
      products[index] = product;
    }
    await _saveCollection(
      'products',
      products.map((item) => item.toMap()).toList(),
    );
    await _syncShopCategories(product.shopId);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    final snapshot = await _snapshot();
    final products = _collection(
      snapshot,
      'products',
    ).map(Product.fromMap).toList();
    final product = products.where((item) => item.id == productId).firstOrNull;
    if (product == null) {
      return;
    }
    products.removeWhere((item) => item.id == productId);
    await _saveCollection(
      'products',
      products.map((item) => item.toMap()).toList(),
    );
    await _syncShopCategories(product.shopId);
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String customerId) {
    return _watchList(() async {
      final orders =
          _collection(
              await _snapshot(),
              'orders',
            ).map(OrderModel.fromMap).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders.where((order) => order.customerId == customerId).toList();
    });
  }

  @override
  Stream<List<OrderModel>> watchVendorOrders(String vendorId) {
    return _watchList(() async {
      final orders =
          _collection(
              await _snapshot(),
              'orders',
            ).map(OrderModel.fromMap).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders.where((order) => order.vendorId == vendorId).toList();
    });
  }

  @override
  Future<void> createOrder(OrderModel order) async {
    final orders = _collection(
      await _snapshot(),
      'orders',
    ).map(OrderModel.fromMap).toList();
    orders.add(order);
    await _saveCollection(
      'orders',
      orders.map((item) => item.toMap()).toList(),
    );
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final orders = _collection(
      await _snapshot(),
      'orders',
    ).map(OrderModel.fromMap).toList();
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return;
    }
    orders[index] = orders[index].copyWith(status: status);
    await _saveCollection(
      'orders',
      orders.map((item) => item.toMap()).toList(),
    );
  }

  @override
  Future<List<String>> fetchAvailableLocalities() async {
    final shops = _collection(
      await _snapshot(),
      'shops',
    ).map(Shop.fromMap).toList();
    final discovered = shops.map((shop) => shop.locality).toSet().toList()
      ..sort();
    return {...AppConstants.localities, ...discovered}.toList()..sort();
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
