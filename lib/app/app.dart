import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghar_bazaar/app/router.dart';
import 'package:ghar_bazaar/app/theme/app_theme.dart';
import 'package:ghar_bazaar/core/constants/app_constants.dart';

class GharBazaarApp extends ConsumerWidget {
  const GharBazaarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
