import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghar_bazaar/app/app.dart';
import 'package:ghar_bazaar/core/constants/app_secrets.dart';
import 'package:ghar_bazaar/core/services/app_bootstrap.dart';
import 'package:ghar_bazaar/data/providers.dart';

Future<void> main() async {
  if (!hasImgbbApiKey) {
    debugPrint('[config] $imgbbApiKeySetupMessage');
  }
  final bootstrap = await AppBootstrap.initialize();
  runApp(
    ProviderScope(
      overrides: [bootstrapProvider.overrideWithValue(bootstrap)],
      child: const GharBazaarApp(),
    ),
  );
}
