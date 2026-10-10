import 'package:flutter/foundation.dart';

/// The signed-in user.
class Session {
  final String name;
  final String email;
  final String handle;
  final bool guest;
  Session({required this.name, required this.email, required this.handle, this.guest = false});
}

/// Auth boundary.
///
/// The UI only talks to this interface, so the demo [LocalAuthService] can be
/// swapped for Firebase Auth, or your own auth service running on Google
/// Cloud / AWS / Yotta, without changing any screen.
abstract class AuthService extends ChangeNotifier {
  Session? get session;
  bool get signedIn => session != null;
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUp(String name, String email, String password);
  Future<void> continueAsGuest();
  Future<void> signOut();
}

/// Demo implementation - keeps the session in memory. Replace with a real
/// backend implementation when you connect one.
class LocalAuthService extends AuthService {
  Session? _session;

  @override
  Session? get session => _session;

  String _handleFor(String name) {
    final base = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '@${base.isEmpty ? 'user' : base}';
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final name = email.split('@').first;
    _session = Session(name: name, email: email, handle: _handleFor(name));
    notifyListeners();
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _session = Session(name: name, email: email, handle: _handleFor(name));
    notifyListeners();
  }

  @override
  Future<void> continueAsGuest() async {
    _session = Session(name: 'Anjaan', email: '', handle: '@anjaan', guest: true);
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _session = null;
    notifyListeners();
  }
}

/// The single auth instance the app uses.
final AuthService auth = LocalAuthService();
