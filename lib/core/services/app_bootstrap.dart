import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:ghar_bazaar/core/services/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBootstrap {
  const AppBootstrap({
    required this.preferences,
    required this.firebaseEnabled,
  });

  final AppPreferences preferences;
  final bool firebaseEnabled;

  static Future<AppBootstrap> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();

    var firebaseEnabled = false;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      firebaseEnabled = Firebase.apps.isNotEmpty;
    } catch (_) {
      firebaseEnabled = false;
    }

    return AppBootstrap(
      preferences: AppPreferences(prefs),
      firebaseEnabled: firebaseEnabled,
    );
  }
}
