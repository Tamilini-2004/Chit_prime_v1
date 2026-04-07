import '../models/user_model.dart';

class AuthRepository {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<bool> sendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<UserModel?> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      _currentUser = UserModel(
        userId: 'user_001',
        phoneNumber: phone,
        fullName: 'Rajesh Kumar',
        email: 'rajesh@example.com',
        aadhaarNumber: '123456789012',
        panNumber: 'ABCDE1234F',
        bankAccount: '1234567890123456',
        ifscCode: 'SBIN0001234',
        bankName: 'State Bank of India',
        creditScore: 820,
        verificationStatus: 'verified',
        createdAt: DateTime(2023, 6, 15),
        updatedAt: DateTime.now(),
      );
      return _currentUser;
    }
    return null;
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: data['phone'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'],
      aadhaarNumber: data['aadhaar'],
      panNumber: data['pan'],
      bankAccount: data['bankAccount'],
      ifscCode: data['ifsc'],
      bankName: data['bankName'],
      creditScore: 500,
      verificationStatus: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<bool> adminLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return email == 'admin@chitprime.com' && password == 'Admin@123';
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<UserModel> updateProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = user;
    return user;
  }
}
