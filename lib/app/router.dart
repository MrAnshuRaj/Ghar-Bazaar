import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/auth/presentation/forgot_password_screen.dart';
import 'package:ghar_bazaar/features/auth/presentation/sign_in_screen.dart';
import 'package:ghar_bazaar/features/auth/presentation/sign_up_screen.dart';
import 'package:ghar_bazaar/features/customer/presentation/cart_screen.dart';
import 'package:ghar_bazaar/features/customer/presentation/checkout_screen.dart';
import 'package:ghar_bazaar/features/customer/presentation/customer_account_screen.dart';
import 'package:ghar_bazaar/features/customer/presentation/customer_home_screen.dart';
import 'package:ghar_bazaar/features/customer/presentation/customer_orders_screen.dart';
import 'package:ghar_bazaar/features/customer/presentation/order_success_screen.dart';
import 'package:ghar_bazaar/features/customer/presentation/shop_detail_screen.dart';
import 'package:ghar_bazaar/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ghar_bazaar/features/profile/presentation/customer_profile_form_screen.dart';
import 'package:ghar_bazaar/features/profile/presentation/role_selection_screen.dart';
import 'package:ghar_bazaar/features/profile/presentation/vendor_profile_form_screen.dart';
import 'package:ghar_bazaar/features/splash/presentation/splash_screen.dart';
import 'package:ghar_bazaar/features/vendor/presentation/product_form_screen.dart';
import 'package:ghar_bazaar/features/vendor/presentation/shop_form_screen.dart';
import 'package:ghar_bazaar/features/vendor/presentation/vendor_account_screen.dart';
import 'package:ghar_bazaar/features/vendor/presentation/vendor_home_screen.dart';
import 'package:ghar_bazaar/features/vendor/presentation/vendor_orders_screen.dart';
import 'package:ghar_bazaar/features/vendor/presentation/vendor_products_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier(
    stream: ref.watch(authRepositoryProvider).authStateChanges(),
    preferences: ref.watch(appPreferencesProvider),
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) async {
      final onboardingComplete = ref
          .read(appPreferencesProvider)
          .isOnboardingComplete;
      final currentSession = ref.read(authRepositoryProvider).currentSession;
      final path = state.matchedLocation;
      final isSplash = path == '/splash';
      final isOnboarding = path == '/onboarding';
      final isAuth = path.startsWith('/auth');
      final isRoleSelection = path == '/role-select';
      final isCustomerRoute = path.startsWith('/customer');
      final isVendorRoute = path.startsWith('/vendor');

      if (!onboardingComplete && !isOnboarding && !isSplash) {
        return '/onboarding';
      }
      if (!onboardingComplete && isOnboarding) {
        return null;
      }
      if (onboardingComplete &&
          currentSession == null &&
          !isAuth &&
          !isSplash &&
          !isOnboarding) {
        return '/auth/signin';
      }
      if (currentSession == null) {
        return null;
      }

      final repository = ref.read(marketplaceRepositoryProvider);
      final user = await repository.getUser(currentSession.uid);
      if (isSplash) {
        return null;
      }
      if (user == null || user.role == UserRole.unknown) {
        return isRoleSelection ? null : '/role-select';
      }

      if (user.role == UserRole.customer) {
        final profile = await repository.getCustomerProfile(currentSession.uid);
        if (profile == null) {
          return path == '/customer/create-profile'
              ? null
              : '/customer/create-profile';
        }
        if (isVendorRoute || isRoleSelection || isAuth) {
          return '/customer/home';
        }
        return null;
      }

      final profile = await repository.getVendorProfile(currentSession.uid);
      if (profile == null) {
        return path == '/vendor/create-profile'
            ? null
            : '/vendor/create-profile';
      }
      if (isCustomerRoute || isRoleSelection || isAuth) {
        return '/vendor/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/auth/signin', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/auth/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/role-select',
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/customer/create-profile',
        builder: (_, __) => const CustomerProfileFormScreen(),
      ),
      GoRoute(
        path: '/vendor/create-profile',
        builder: (_, __) => const VendorProfileFormScreen(),
      ),
      GoRoute(
        path: '/customer/home',
        builder: (_, __) => const CustomerHomeScreen(),
      ),
      GoRoute(path: '/customer/cart', builder: (_, __) => const CartScreen()),
      GoRoute(
        path: '/customer/account',
        builder: (_, __) => const CustomerAccountScreen(),
      ),
      GoRoute(
        path: '/customer/orders',
        builder: (_, __) => const CustomerOrdersScreen(),
      ),
      GoRoute(
        path: '/customer/shop/:id',
        builder: (_, state) => ShopDetailScreen(
          shopId: state.pathParameters['id']!,
          initialShop: state.extra is Shop ? state.extra! as Shop : null,
        ),
      ),
      GoRoute(
        path: '/customer/checkout',
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/customer/order-success/:id',
        builder: (_, state) =>
            OrderSuccessScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/vendor/home',
        builder: (_, __) => const VendorHomeScreen(),
      ),
      GoRoute(
        path: '/vendor/products',
        builder: (_, __) => const VendorProductsScreen(),
      ),
      GoRoute(
        path: '/vendor/orders',
        builder: (_, __) => const VendorOrdersScreen(),
      ),
      GoRoute(
        path: '/vendor/account',
        builder: (_, __) => const VendorAccountScreen(),
      ),
      GoRoute(
        path: '/vendor/create-shop',
        builder: (_, __) => const ShopFormScreen(),
      ),
      GoRoute(
        path: '/vendor/add-product',
        builder: (_, __) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/vendor/edit-product/:id',
        builder: (_, state) =>
            ProductFormScreen(productId: state.pathParameters['id']),
      ),
    ],
  );
});
