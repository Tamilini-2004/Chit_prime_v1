import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firebase_service.dart';

// Auth state
final authStateProvider = StreamProvider<User?>((ref) =>
    FirebaseAuth.instance.authStateChanges());

// Current user model — real-time
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return FirebaseService.userStream(uid);
});

// Unread notifications count — real-time
final unreadCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(0);
  return FirebaseService.unreadCountStream(uid);
});

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> signInMember(String phone) async {
    try {
      final email =
          '${phone.replaceAll(RegExp(r'[^0-9]'), '')}@chitprime.test';
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: 'chitprime123');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-credential' ||
            e.code == 'INVALID_LOGIN_CREDENTIALS') {
          final cred = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: email, password: 'chitprime123');
          await FirebaseService.createOrUpdateUser(
            uid: cred.user!.uid,
            phone: phone,
            name: 'User ${phone.substring(phone.length > 4 ? phone.length - 4 : 0)}',
            role: 'member',
          );
        } else {
          return e.message ?? 'Login failed';
        }
      }
      // Ensure user doc exists
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseService.createOrUpdateUser(
          uid: uid, phone: phone, name: 'Member');
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInAdmin(String email, String password) async {
    try {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password.isEmpty ? 'admin123' : password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-credential' ||
            e.code == 'INVALID_LOGIN_CREDENTIALS') {
          final cred = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: email,
                  password: password.isEmpty ? 'admin123' : password);
          await FirebaseService.createOrUpdateUser(
            uid: cred.user!.uid,
            phone: '',
            name: 'Admin User',
            role: 'super_admin',
          );
        } else {
          return e.message ?? 'Login failed';
        }
      }
      // Verify admin role
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final user = await FirebaseService.getUser(uid);
      if (user == null) {
        await FirebaseService.createOrUpdateUser(
            uid: uid, phone: '', name: 'Admin User', role: 'super_admin');
      } else if (!user.isAdmin) {
        await FirebaseAuth.instance.signOut();
        return 'Access denied. Admin credentials required.';
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await FirebaseService.updateUser(uid, data);
  }

  Future<void> completeRegistration({
    required String uid,
    required String name,
    String email = '',
    String bankName = '',
    String ifsc = '',
    String bankMasked = '',
  }) async {
    await FirebaseService.updateUser(uid, {
      'name': name.isEmpty ? 'Test User' : name,
      'email': email,
      'bankName': bankName,
      'ifsc': ifsc,
      'bankMasked': bankMasked,
      'kycStatus': 'verified',
      'accountStatus': 'active',
    });
  }

  Future<void> logout() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseService.updateUser(uid, {'isOnline': false});
    }
    await FirebaseAuth.instance.signOut();
  }
}
