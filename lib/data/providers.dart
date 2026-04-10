import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghar_bazaar/core/services/app_bootstrap.dart';
import 'package:ghar_bazaar/core/services/app_preferences.dart';
import 'package:ghar_bazaar/core/services/image_upload_service.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/auth_session.dart';
import 'package:ghar_bazaar/data/models/cart_state.dart';
import 'package:ghar_bazaar/data/models/customer_profile.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/order_model.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/models/vendor_profile.dart';
import 'package:ghar_bazaar/data/repositories/auth_repository.dart';
import 'package:ghar_bazaar/data/repositories/marketplace_repository.dart';
import 'package:ghar_bazaar/data/sources/firebase/firebase_marketplace_data_source.dart';
import 'package:ghar_bazaar/data/sources/local/local_database.dart';
import 'package:ghar_bazaar/data/sources/local/local_marketplace_data_source.dart';
import 'package:ghar_bazaar/data/sources/marketplace_data_source.dart';

final bootstrapProvider = Provider<AppBootstrap>((ref) {
  throw UnimplementedError('bootstrapProvider must be overridden in main()');
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return ref.watch(bootstrapProvider).preferences;
});

final firebaseEnabledProvider = Provider<bool>((ref) {
  return ref.watch(bootstrapProvider).firebaseEnabled;
});

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase(ref.watch(appPreferencesProvider));
});

final marketplaceDataSourceProvider = Provider<MarketplaceDataSource>((ref) {
  if (ref.watch(firebaseEnabledProvider)) {
    return FirebaseMarketplaceDataSource(FirebaseFirestore.instance);
  }
  return LocalMarketplaceDataSource(ref.watch(localDatabaseProvider));
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository(ref.watch(marketplaceDataSourceProvider));
});

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  final service = ImageUploadService();
  ref.onDispose(service.dispose);
  return service;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = AuthRepository(
    firebaseEnabled: ref.watch(firebaseEnabledProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  await ref.read(marketplaceRepositoryProvider).seedDemoData();
});

final authStateChangesProvider = StreamProvider<AuthSession?>((ref) {
  ref.watch(appInitializationProvider);
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  final session = ref.watch(authStateChangesProvider).asData?.value;
  if (session == null) {
    return null;
  }
  return ref.watch(marketplaceRepositoryProvider).getUser(session.uid);
});

final customerProfileProvider = FutureProvider<CustomerProfile?>((ref) async {
  final session = ref.watch(authStateChangesProvider).asData?.value;
  if (session == null) {
    return null;
  }
  return ref
      .watch(marketplaceRepositoryProvider)
      .getCustomerProfile(session.uid);
});

final vendorProfileProvider = FutureProvider<VendorProfile?>((ref) async {
  final session = ref.watch(authStateChangesProvider).asData?.value;
  if (session == null) {
    return null;
  }
  return ref.watch(marketplaceRepositoryProvider).getVendorProfile(session.uid);
});

final localitiesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(marketplaceRepositoryProvider).fetchLocalities();
});

final selectedLocalityProvider =
    NotifierProvider<SelectedLocalityNotifier, String?>(
      SelectedLocalityNotifier.new,
    );

final shopsByLocalityProvider = StreamProvider.family<List<Shop>, String>((
  ref,
  locality,
) {
  return ref
      .watch(marketplaceRepositoryProvider)
      .watchShopsByLocality(locality);
});

final shopProvider = FutureProvider.family<Shop?, String>((ref, shopId) async {
  return ref.watch(marketplaceRepositoryProvider).getShop(shopId);
});

final shopProductsProvider = StreamProvider.family<List<Product>, String>((
  ref,
  shopId,
) {
  return ref.watch(marketplaceRepositoryProvider).watchShopProducts(shopId);
});

final vendorShopProvider = StreamProvider<Shop?>((ref) {
  final session = ref.watch(authStateChangesProvider).asData?.value;
  if (session == null) {
    return Stream.value(null);
  }
  return ref.watch(marketplaceRepositoryProvider).watchVendorShop(session.uid);
});

final vendorProductsProvider = StreamProvider<List<Product>>((ref) {
  final session = ref.watch(authStateChangesProvider).asData?.value;
  if (session == null) {
    return Stream.value(const []);
  }
  return ref
      .watch(marketplaceRepositoryProvider)
      .watchVendorProducts(session.uid);
});

final customerOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final session = ref.watch(authStateChangesProvider).asData?.value;
  if (session == null) {
    return Stream.value(const []);
  }
  return ref
      .watch(marketplaceRepositoryProvider)
      .watchCustomerOrders(session.uid);
});

final vendorOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final session = ref.watch(authStateChangesProvider).asData?.value;
  if (session == null) {
    return Stream.value(const []);
  }
  return ref
      .watch(marketplaceRepositoryProvider)
      .watchVendorOrders(session.uid);
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

class SelectedLocalityNotifier extends Notifier<String?> {
  @override
  String? build() {
    return ref.read(appPreferencesProvider).selectedLocality;
  }

  Future<void> setLocality(String locality) async {
    state = locality;
    await ref.read(appPreferencesProvider).setSelectedLocality(locality);
  }
}

class AuthController extends AsyncNotifier<void> {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  MarketplaceRepository get _marketplaceRepository =>
      ref.read(marketplaceRepositoryProvider);

  @override
  FutureOr<void> build() async {
    await ref.watch(appInitializationProvider.future);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      await _ensureUserRecord(session);
    });
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      await _ensureUserRecord(session, preferredName: name);
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _authRepository.signInWithGoogle();
      await _ensureUserRecord(session);
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authRepository.sendPasswordResetEmail(email),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_authRepository.signOut);
    ref.invalidate(currentAppUserProvider);
    ref.invalidate(customerProfileProvider);
    ref.invalidate(vendorProfileProvider);
  }

  Future<void> _ensureUserRecord(
    AuthSession session, {
    String? preferredName,
  }) async {
    final existing = await _marketplaceRepository.getUser(session.uid);
    if (existing != null) {
      await _marketplaceRepository.saveUser(
        existing.copyWith(
          email: session.email,
          name: session.displayName ?? existing.name,
          photoUrl: session.photoUrl ?? existing.photoUrl,
        ),
      );
      ref.invalidate(currentAppUserProvider);
      return;
    }
    final user = AppUser(
      uid: session.uid,
      email: session.email,
      name:
          preferredName ??
          session.displayName ??
          session.email.split('@').first,
      role: UserRole.unknown,
      photoUrl: session.photoUrl,
      isOnboarded: true,
      createdAt: DateTime.now(),
    );
    await _marketplaceRepository.saveUser(user);
    ref.invalidate(currentAppUserProvider);
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    final raw = ref.read(appPreferencesProvider).cartJson;
    if (raw == null || raw.isEmpty) {
      return const CartState();
    }
    try {
      return CartState.fromJson(raw);
    } catch (_) {
      return const CartState();
    }
  }

  bool canAddProduct(Product product) {
    return state.shopId == null || state.shopId == product.shopId;
  }

  Future<void> addProduct(Product product, {required String shopName}) async {
    state = state.add(product, resolvedShopName: shopName);
    await _persist();
  }

  Future<void> replaceCartAndAdd(
    Product product, {
    required String shopName,
  }) async {
    state = const CartState();
    state = state.add(product, resolvedShopName: shopName);
    await _persist();
  }

  Future<void> changeQuantity(String productId, int nextQuantity) async {
    state = state.changeQuantity(productId, nextQuantity);
    await _persist();
  }

  Future<void> clear() async {
    state = const CartState();
    await _persist();
  }

  Future<void> _persist() {
    return ref
        .read(appPreferencesProvider)
        .saveCartJson(state.isEmpty ? null : state.toJson());
  }
}

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier({
    required Stream<dynamic> stream,
    required Listenable preferences,
  }) {
    _subscription = stream.listen((_) => notifyListeners());
    preferences.addListener(notifyListeners);
    _preferences = preferences;
  }

  late final Listenable _preferences;
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    _preferences.removeListener(notifyListeners);
    super.dispose();
  }
}
