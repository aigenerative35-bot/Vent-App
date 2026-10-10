import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// The single storage boundary of the app.
///
/// Screens never touch this directly — they only talk to `AppState`.
/// `AppState` talks to a `DataRepository`. So to move to a real backend you
/// only write ONE new class (e.g. `FirestoreRepository implements
/// DataRepository`) and swap it in `main.dart`. No screen changes at all.
abstract class DataRepository {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> data);
  Future<void> clear();
}

/// Local, on-device storage (survives app restarts). Works on Android, iOS,
/// desktop and web. This is the default "demo backend".
class LocalRepository implements DataRepository {
  static const _key = 'snip_state_v1';

  @override
  Future<Map<String, dynamic>?> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(data));
  }

  @override
  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}

/// In-memory repository — used for tests or as a fallback.
class MemoryRepository implements DataRepository {
  Map<String, dynamic>? _data;

  @override
  Future<Map<String, dynamic>?> load() async => _data;

  @override
  Future<void> save(Map<String, dynamic> data) async => _data = data;

  @override
  Future<void> clear() async => _data = null;
}
