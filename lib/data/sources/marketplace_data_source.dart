import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/customer_profile.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/order_model.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/models/vendor_profile.dart';

abstract class MarketplaceDataSource {
  Future<void> seedDemoData();

  Future<AppUser?> getUser(String uid);
  Future<void> saveUser(AppUser user);

  Future<CustomerProfile?> getCustomerProfile(String uid);
  Future<void> saveCustomerProfile(CustomerProfile profile);

  Future<VendorProfile?> getVendorProfile(String uid);
  Future<void> saveVendorProfile(VendorProfile profile);

  Stream<List<Shop>> watchShopsByLocality(String locality);
  Stream<Shop?> watchVendorShop(String vendorId);
  Future<Shop?> getShop(String shopId);
  Future<void> upsertShop(Shop shop);

  Stream<List<Product>> watchShopProducts(String shopId);
  Stream<List<Product>> watchVendorProducts(String vendorId);
  Future<Product?> getProduct(String productId);
  Future<void> upsertProduct(Product product);
  Future<void> deleteProduct(String productId);

  Stream<List<OrderModel>> watchCustomerOrders(String customerId);
  Stream<List<OrderModel>> watchVendorOrders(String vendorId);
  Future<void> createOrder(OrderModel order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  Future<List<String>> fetchAvailableLocalities();
}
