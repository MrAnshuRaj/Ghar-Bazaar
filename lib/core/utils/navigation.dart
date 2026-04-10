import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/providers.dart';

Future<String> resolveStartupRoute(WidgetRef ref) async {
  await ref.read(appInitializationProvider.future);
  final preferences = ref.read(appPreferencesProvider);
  if (!preferences.isOnboardingComplete) {
    return '/onboarding';
  }

  final session = ref.read(authRepositoryProvider).currentSession;
  if (session == null) {
    return '/auth/signin';
  }

  final repository = ref.read(marketplaceRepositoryProvider);
  final user = await repository.getUser(session.uid);
  if (user == null || user.role == UserRole.unknown) {
    return '/role-select';
  }
  if (user.role == UserRole.customer) {
    final profile = await repository.getCustomerProfile(session.uid);
    return profile == null ? '/customer/create-profile' : '/customer/home';
  }
  final profile = await repository.getVendorProfile(session.uid);
  return profile == null ? '/vendor/create-profile' : '/vendor/home';
}
