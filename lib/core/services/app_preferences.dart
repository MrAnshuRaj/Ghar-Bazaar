import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingKey = 'onboarding_complete';
  static const _cartKey = 'customer_cart_state';
  static const _selectedLocalityKey = 'selected_locality';
  static const _localDatabaseKey = 'local_database_v1';

  bool get isOnboardingComplete => _prefs.getBool(_onboardingKey) ?? false;
  String? get cartJson => _prefs.getString(_cartKey);
  String? get selectedLocality => _prefs.getString(_selectedLocalityKey);
  String? get localDatabaseJson => _prefs.getString(_localDatabaseKey);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> setSelectedLocality(String? locality) async {
    if (locality == null || locality.isEmpty) {
      await _prefs.remove(_selectedLocalityKey);
    } else {
      await _prefs.setString(_selectedLocalityKey, locality);
    }
    notifyListeners();
  }

  Future<void> saveCartJson(String? json) async {
    if (json == null || json.isEmpty) {
      await _prefs.remove(_cartKey);
    } else {
      await _prefs.setString(_cartKey, json);
    }
  }

  Future<void> saveLocalDatabase(String json) async {
    await _prefs.setString(_localDatabaseKey, json);
  }
}
