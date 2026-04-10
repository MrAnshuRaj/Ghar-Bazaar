import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/customer_profile.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/order_model.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/models/vendor_profile.dart';
import 'package:ghar_bazaar/data/sources/marketplace_data_source.dart';

class MarketplaceRepository {
  MarketplaceRepository(this._dataSource);

  final MarketplaceDataSource _dataSource;

  Future<void> seedDemoData() => _dataSource.seedDemoData();

  Future<AppUser?> getUser(String uid) => _dataSource.getUser(uid);
  Future<void> saveUser(AppUser user) => _dataSource.saveUser(user);

  Future<CustomerProfile?> getCustomerProfile(String uid) =>
      _dataSource.getCustomerProfile(uid);
  Future<void> saveCustomerProfile(CustomerProfile profile) =>
      _dataSource.saveCustomerProfile(profile);

  Future<VendorProfile?> getVendorProfile(String uid) =>
      _dataSource.getVendorProfile(uid);
  Future<void> saveVendorProfile(VendorProfile profile) =>
      _dataSource.saveVendorProfile(profile);

  Stream<List<Shop>> watchShopsByLocality(String locality) =>
      _dataSource.watchShopsByLocality(locality);
  Stream<Shop?> watchVendorShop(String vendorId) =>
      _dataSource.watchVendorShop(vendorId);
  Future<Shop?> getShop(String shopId) => _dataSource.getShop(shopId);
  Future<void> upsertShop(Shop shop) => _dataSource.upsertShop(shop);

  Stream<List<Product>> watchShopProducts(String shopId) =>
      _dataSource.watchShopProducts(shopId);
  Stream<List<Product>> watchVendorProducts(String vendorId) =>
      _dataSource.watchVendorProducts(vendorId);
  Future<Product?> getProduct(String productId) =>
      _dataSource.getProduct(productId);
  Future<void> upsertProduct(Product product) =>
      _dataSource.upsertProduct(product);
  Future<void> deleteProduct(String productId) =>
      _dataSource.deleteProduct(productId);

  Stream<List<OrderModel>> watchCustomerOrders(String customerId) =>
      _dataSource.watchCustomerOrders(customerId);
  Stream<List<OrderModel>> watchVendorOrders(String vendorId) =>
      _dataSource.watchVendorOrders(vendorId);
  Future<void> createOrder(OrderModel order) => _dataSource.createOrder(order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      _dataSource.updateOrderStatus(orderId, status);

  Future<List<String>> fetchLocalities() =>
      _dataSource.fetchAvailableLocalities();
}
