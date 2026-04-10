import 'package:cloud_firestore/cloud_firestore.dart';
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
      try {
        await for (final snapshot
            in _shops.where('locality', isEqualTo: locality).snapshots()) {
          final shops =
              snapshot.docs.map((doc) => Shop.fromMap(doc.data())).toList()
                ..sort((a, b) => b.rating.compareTo(a.rating));
          yield shops;
        }
      } catch (error) {
        throw _dataException(
          error,
          'Unable to load shops for this locality right now.',
        );
      }
    })();
  }

  @override
  Stream<Shop?> watchVendorShop(String vendorId) {
    return (() async* {
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
          yield Shop.fromMap(snapshot.docs.first.data());
        }
      } catch (error) {
        throw _dataException(
          error,
          'Unable to load your shop details right now.',
        );
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
      try {
        await for (final snapshot
            in _products.where('shopId', isEqualTo: shopId).snapshots()) {
          final products =
              snapshot.docs
                  .map((doc) => Product.fromMap(doc.data()))
                  .where((product) => product.isAvailable)
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name));
          yield products;
        }
      } catch (error) {
        throw _dataException(error, 'Unable to load shop items right now.');
      }
    })();
  }

  @override
  Stream<List<Product>> watchVendorProducts(String vendorId) {
    return (() async* {
      try {
        await for (final snapshot
            in _products.where('vendorId', isEqualTo: vendorId).snapshots()) {
          final products =
              snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList()
                ..sort((a, b) => a.category.label.compareTo(b.category.label));
          yield products;
        }
      } catch (error) {
        throw _dataException(error, 'Unable to load your products right now.');
      }
    })();
  }

  @override
  Future<Product?> getProduct(String productId) async {
    final snapshot = await _products.doc(productId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return Product.fromMap(snapshot.data()!);
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
    final categories =
        productsSnapshot.docs
            .map((doc) => Product.fromMap(doc.data()).category.label)
            .toSet()
            .toList()
          ..sort();
    final shop = Shop.fromMap(shopData).copyWith(categories: categories);
    await _shops.doc(shopId).set(shop.toMap(), SetOptions(merge: true));
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
        : Product.fromMap(snapshot.data()!);
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
