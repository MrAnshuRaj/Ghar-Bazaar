import 'dart:convert';

import 'package:ghar_bazaar/core/constants/demo_content.dart';
import 'package:ghar_bazaar/core/services/app_preferences.dart';

class LocalDatabase {
  LocalDatabase(this._preferences);

  final AppPreferences _preferences;

  Future<Map<String, dynamic>> read() async {
    final raw = _preferences.localDatabaseJson;
    if (raw == null || raw.isEmpty) {
      final seeded = DemoContent.seededDatabase();
      await write(seeded);
      return seeded;
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> write(Map<String, dynamic> data) {
    return _preferences.saveLocalDatabase(jsonEncode(data));
  }

  Future<void> ensureSeeded() async {
    await read();
  }
}
