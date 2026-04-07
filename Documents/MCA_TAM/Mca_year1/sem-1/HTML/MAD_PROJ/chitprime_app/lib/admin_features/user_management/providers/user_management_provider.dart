import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class UserManagementProvider extends ChangeNotifier {
  bool isLoading = false;
  String _searchQuery = '';
  String _filterStatus = 'all';

  final List<UserModel> _users = [
    UserModel(userId: 'user_001', phoneNumber: '9876543210', fullName: 'Rajesh Kumar', email: 'rajesh@example.com', creditScore: 820, verificationStatus: 'verified', isActive: true, createdAt: DateTime(2023, 6, 15), updatedAt: DateTime.now()),
    UserModel(userId: 'user_002', phoneNumber: '9876543211', fullName: 'Priya Sharma', email: 'priya@example.com', creditScore: 750, verificationStatus: 'verified', isActive: true, createdAt: DateTime(2023, 7, 20), updatedAt: DateTime.now()),
    UserModel(userId: 'user_003', phoneNumber: '9876543212', fullName: 'Amit Patel', email: 'amit@example.com', creditScore: 680, verificationStatus: 'pending', isActive: true, createdAt: DateTime(2023, 8, 10), updatedAt: DateTime.now()),
    UserModel(userId: 'user_004', phoneNumber: '9876543213', fullName: 'Sunita Devi', email: 'sunita@example.com', creditScore: 720, verificationStatus: 'verified', isActive: true, createdAt: DateTime(2023, 9, 5), updatedAt: DateTime.now()),
    UserModel(userId: 'user_005', phoneNumber: '9876543214', fullName: 'Mohan Lal', email: 'mohan@example.com', creditScore: 640, verificationStatus: 'verified', isActive: false, createdAt: DateTime(2023, 10, 1), updatedAt: DateTime.now()),
    UserModel(userId: 'user_006', phoneNumber: '9876543215', fullName: 'Kavitha Reddy', email: 'kavitha@example.com', creditScore: 580, verificationStatus: 'pending', isActive: true, createdAt: DateTime(2024, 1, 15), updatedAt: DateTime.now()),
  ];

  List<UserModel> get filteredUsers {
    return _users.where((u) {
      final matchesSearch = _searchQuery.isEmpty ||
          u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.phoneNumber.contains(_searchQuery) ||
          (u.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesFilter = _filterStatus == 'all' ||
          (_filterStatus == 'active' && u.isActive) ||
          (_filterStatus == 'inactive' && !u.isActive) ||
          (_filterStatus == 'verified' && u.verificationStatus == 'verified') ||
          (_filterStatus == 'pending' && u.verificationStatus == 'pending');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _filterStatus = filter;
    notifyListeners();
  }

  Future<void> toggleUserStatus(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.userId == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: !_users[index].isActive);
      notifyListeners();
    }
  }

  Future<void> verifyUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.userId == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(verificationStatus: 'verified');
      notifyListeners();
    }
  }
}
