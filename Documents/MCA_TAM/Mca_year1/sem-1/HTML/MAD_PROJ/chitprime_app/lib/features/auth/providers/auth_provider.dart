import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  String? _pendingPhone;

  AuthProvider(this._repo);

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  String? get pendingPhone => _pendingPhone;
  bool get isAuthenticated => _user != null;

  Future<bool> sendOtp(String phone) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _pendingPhone = phone;
    // Auto verify for demo - skip OTP step
    final user = await _repo.verifyOtp(phone, '123456');
    if (user != null) {
      _user = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return _user != null;
  }

  Future<bool> verifyOtp(String otp) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final user = await _repo.verifyOtp(_pendingPhone ?? '', otp);
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _error = 'Invalid OTP. Please try again.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.register({...data, 'phone': _pendingPhone});
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateUser(UserModel user) async {
    _user = await _repo.updateProfile(user);
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
