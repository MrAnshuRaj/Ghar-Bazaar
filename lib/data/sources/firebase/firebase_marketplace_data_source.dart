import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ghar_bazaar/core/constants/app_constants.dart';
import 'package:ghar_bazaar/core/constants/demo_content.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/customer_profile.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/order_model.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/models/vendor_profile.dart';
import 'package:ghar_bazaar/data/sources/marketplace_data_source.dart';

class FirebaseMarketplaceDataSource implements MarketplaceDataSource {
  FirebaseMarketplaceDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _customerProfiles =>
      _firestore.collection('customer_profiles');
  CollectionReference<Map<String, dynamic>> get _vendorProfiles =>
      _firestore.collection('vendor_profiles');
  CollectionReference<Map<String, dynamic>> get _shops =>
      _firestore.collection('shops');
  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  MarketplaceDataException _dataException(
    Object error,
    String fallbackMessage,
  ) {
    if (error is FirebaseException) {
      return MarketplaceDataException(switch (error.code) {
        'permission-denied' =>
          'You do not have permission to load this data right now.',
        'unavailable' =>
          'Firestore is temporarily unavailable. Please check your connection and try again.',
        'failed-precondition' =>
          'Firestore query configuration is incomplete. Please verify your Firebase setup.',
        _ => error.message ?? fallbackMessage,
      });
    }
    return MarketplaceDataException(fallbackMessage);
  }

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[FirebaseMarketplaceDataSource] $message');
    }
  }

  bool _isTransientFirestoreError(Object error) {
    if (error is! FirebaseException) {
      return false;
    }
    return switch (error.code) {
      'unavailable' => true,
      'cancelled' => true,
      'deadline-exceeded' => true,
      'resource-exhausted' => true,
      _ => false,
    };
  }

  Duration _retryDelay(int attempt) {
    final seconds = attempt <= 1 ? 1 : (attempt <= 2 ? 2 : 4);
    return Duration(seconds: seconds);
  }

  Product? _parseProductDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required String context,
  }) {
    final data = Map<String, dynamic>.from(doc.data());
    final existingId = data['id']?.toString().trim();
    data['id'] = (existingId != null && existingId.isNotEmpty)
        ? existingId
        : doc.id;
    try {
      return Product.fromMap(data);
    } catch (error, stackTrace) {
      _logDebug(
        'Skipped malformed product doc "$context/${doc.id}": $error\n$stackTrace',
      );
      return null;
    }
  }

  @override
  Future<void> seedDemoData() async {
    final existing = await _shops.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return;
    }
    final batch = _firestore.batch();
    for (final shop in DemoContent.shops) {
      batch.set(_shops.doc(shop.id), shop.toMap());
    }
    for (final product in DemoContent.products) {
      batch.set(_products.doc(product.id), product.toMap());
    }
    await batch.commit();
  }

  @override
  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return AppUser.fromMap(snapshot.data()!);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Future<CustomerProfile?> getCustomerProfile(String uid) async {
    final snapshot = await _customerProfiles.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return CustomerProfile.fromMap(snapshot.data()!);
  }

  @override
  Future<void> saveCustomerProfile(CustomerProfile profile) async {
    await _customerProfiles
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  @override
  Future<VendorProfile?> getVendorProfile(String uid) async {
    final snapshot = await _vendorProfiles.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return VendorProfile.fromMap(snapshot.data()!);
  }

  @override
  Future<void> saveVendorProfile(VendorProfile profile) async {
    await _vendorProfiles
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  @override
  Stream<List<Shop>> watchShopsByLocality(String locality) {
    return (() async* {
      _logDebug('watchShopsByLocality subscribed locality=$locality');
      try {
        var attempt = 0;
        while (true) {
          try {
            await for (final snapshot
                in _shops.where('locality', isEqualTo: locality).snapshots()) {
              final shops =
                  snapshot.docs.map((doc) => Shop.fromMap(doc.data())).toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));
              attempt = 0;
              yield shops;
            }
            return;
          } catch (error) {
            if (_isTransientFirestoreError(error)) {
              attempt += 1;
              final delay = _retryDelay(attempt);
              _logDebug(
                'Transient watchShopsByLocality failure ($error). Retrying in ${delay.inSeconds}s',
              );
              yield const <Shop>[];
              await Future<void>.delayed(delay);
              continue;
            }
            throw _dataException(
              error,
              'Unable to load shops for this locality right now.',
            );
          }
        }
      } finally {
        _logDebug('watchShopsByLocality unsubscribed locality=$locality');
      }
    })();
  }

  @override
  Stream<Shop?> watchVendorShop(String vendorId) {
    return (() async* {
      _logDebug('watchVendorShop subscribed vendorId=$vendorId');
      try {
        var attempt = 0;
        while (true) {
          try {
            await for (final snapshot
                in _shops
                    .where('vendorId', isEqualTo: vendorId)
                    .limit(1)
                    .snapshots()) {
              if (snapshot.docs.isEmpty) {
                yield null;
                continue;
              }
              attempt = 0;
              yield Shop.fromMap(snapshot.docs.first.data());
            }
            return;
          } catch (error) {
            if (_isTransientFirestoreError(error)) {
              attempt += 1;
              final delay = _retryDelay(attempt);
              _logDebug(
                'Transient watchVendorShop failure ($error). Retrying in ${delay.inSeconds}s',
              );
              yield null;
              await Future<void>.delayed(delay);
              continue;
            }
            throw _dataException(
              error,
              'Unable to load your shop details right now.',
            );
          }
        }
      } finally {
        _logDebug('watchVendorShop unsubscribed vendorId=$vendorId');
      }
    })();
  }

  @override
  Future<Shop?> getShop(String shopId) async {
    try {
      final snapshot = await _shops.doc(shopId).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return Shop.fromMap(snapshot.data()!);
    } catch (error) {
      throw _dataException(error, 'Unable to load this shop right now.');
    }
  }

  @override
  Future<void> upsertShop(Shop shop) async {
    await _shops.doc(shop.id).set(shop.toMap(), SetOptions(merge: true));
  }

  @override
  Stream<List<Product>> watchShopProducts(String shopId) {
    return (() async* {
      _logDebug('watchShopProducts subscribed for shopId=$shopId');
      try {
        var attempt = 0;
        while (true) {
          try {
            await for (final snapshot
                in _products.where('shopId', isEqualTo: shopId).snapshots()) {
              final products = <Product>[];
              for (final doc in snapshot.docs) {
                final parsed = _parseProductDoc(
                  doc,
                  context: 'watchShopProducts:$shopId',
                );
                if (parsed == null || !parsed.isAvailable) {
                  continue;
                }
                products.add(parsed);
              }
              products.sort((a, b) => a.name.compareTo(b.name));
              attempt = 0;
              _logDebug(
                'watchShopProducts shopId=$shopId returned ${products.length} available products from ${snapshot.docs.length} docs',
              );
              yield products;
            }
            return;
          } catch (error) {
            if (_isTransientFirestoreError(error)) {
              attempt += 1;
              final delay = _retryDelay(attempt);
              _logDebug(
                'Transient watchShopProducts failure ($error). Retrying in ${delay.inSeconds}s',
              );
              yield const <Product>[];
              await Future<void>.delayed(delay);
              continue;
            }
            throw _dataException(error, 'Unable to load shop items right now.');
          }
        }
      } finally {
        _logDebug('watchShopProducts unsubscribed for shopId=$shopId');
      }
    })();
  }

  @override
  Stream<List<Product>> watchVendorProducts(String vendorId) {
    return (() async* {
      _logDebug('watchVendorProducts subscribed vendorId=$vendorId');
      try {
        var attempt = 0;
        while (true) {
          try {
            await for (final snapshot
                in _products
                    .where('vendorId', isEqualTo: vendorId)
                    .snapshots()) {
              final products = <Product>[];
              for (final doc in snapshot.docs) {
                final parsed = _parseProductDoc(
                  doc,
                  context: 'watchVendorProducts:$vendorId',
                );
                if (parsed != null) {
                  products.add(parsed);
                }
              }
              products.sort(
                (a, b) => a.category.label.compareTo(b.category.label),
              );
              attempt = 0;
              yield products;
            }
            return;
          } catch (error) {
            if (_isTransientFirestoreError(error)) {
              attempt += 1;
              final delay = _retryDelay(attempt);
              _logDebug(
                'Transient watchVendorProducts failure ($error). Retrying in ${delay.inSeconds}s',
              );
              yield const <Product>[];
              await Future<void>.delayed(delay);
              continue;
            }
            throw _dataException(
              error,
              'Unable to load your products right now.',
            );
          }
        }
      } finally {
        _logDebug('watchVendorProducts unsubscribed vendorId=$vendorId');
      }
    })();
  }

  @override
  Future<Product?> getProduct(String productId) async {
    final snapshot = await _products.doc(productId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    final data = Map<String, dynamic>.from(snapshot.data()!);
    final existingId = data['id']?.toString().trim();
    data['id'] = (existingId != null && existingId.isNotEmpty)
        ? existingId
        : snapshot.id;
    return Product.fromMap(data);
  }

  Future<void> _syncShopCategories(String shopId) async {
    final shopSnapshot = await _shops.doc(shopId).get();
    final shopData = shopSnapshot.data();
    if (shopData == null) {
      return;
    }
    final productsSnapshot = await _products
        .where('shopId', isEqualTo: shopId)
        .get();
    final categories = <String>{};
    for (final doc in productsSnapshot.docs) {
      final parsed = _parseProductDoc(
        doc,
        context: 'syncShopCategories:$shopId',
      );
      if (parsed != null) {
        categories.add(parsed.category.label);
      }
    }
    final sortedCategories = categories.toList()..sort();
    final syncedShop = Shop.fromMap(
      shopData,
    ).copyWith(categories: sortedCategories);
    await _shops.doc(shopId).set(syncedShop.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> upsertProduct(Product product) async {
    try {
      await _products
          .doc(product.id)
          .set(product.toMap(), SetOptions(merge: true));
      await _syncShopCategories(product.shopId);
    } catch (error) {
      throw _dataException(error, 'Unable to save this product right now.');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    final snapshot = await _products.doc(productId).get();
    final product = snapshot.data() == null
        ? null
        : Product.fromMap({...snapshot.data()!, 'id': snapshot.id});
    await _products.doc(productId).delete();
    if (product != null) {
      await _syncShopCategories(product.shopId);
    }
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String customerId) {
    return _orders
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderModel.fromMap(doc.data()))
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  @override
  Stream<List<OrderModel>> watchVendorOrders(String vendorId) {
    return _orders
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderModel.fromMap(doc.data()))
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  @override
  Future<void> createOrder(OrderModel order) async {
    await _orders.doc(order.id).set(order.toMap());
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _orders.doc(orderId).set({
      'status': status.value,
    }, SetOptions(merge: true));
  }

  @override
  Future<List<String>> fetchAvailableLocalities() async {
    final shops = await _shops.get();
    final localities =
        shops.docs.map((doc) => doc.data()['locality'] as String? ?? '').toSet()
          ..addAll(AppConstants.localities);
    return localities.where((item) => item.isNotEmpty).toList()..sort();
  }
}

class MarketplaceDataException implements Exception {
  const MarketplaceDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
