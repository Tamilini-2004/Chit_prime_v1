import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

enum AdminAuthStatus { initial, loading, authenticated, unauthenticated, error }

class AdminAuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  AdminAuthStatus _status = AdminAuthStatus.initial;
  String? _error;
  bool _isAuthenticated = false;
  String _adminName = 'Super Admin';
  String _adminRole = 'Super Admin';

  AdminAuthProvider(this._repo);

  AdminAuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String get adminName => _adminName;
  String get adminRole => _adminRole;

  Future<bool> login(String email, String password) async {
    _status = AdminAuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final success = await _repo.adminLogin(email, password);
      if (success) {
        _isAuthenticated = true;
        _adminName = 'Admin User';
        _adminRole = 'Super Admin';
        _status = AdminAuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _error = 'Invalid credentials. Please try again.';
      _status = AdminAuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _status = AdminAuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _status = AdminAuthStatus.unauthenticated;
    notifyListeners();
  }
}
