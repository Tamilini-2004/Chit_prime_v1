import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firebase_keys.dart';
import '../../../core/constants/test_bypass.dart';
import '../../../core/utils/notification_service.dart';

final adminAuthNotifierProvider = AsyncNotifierProvider<AdminAuthNotifier, void>(AdminAuthNotifier.new);

class AdminAuthNotifier extends AsyncNotifier<void> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  Future<void> build() async {}

  Future<bool> login(String email, String password) async {
    try {
      // Test bypass
      if (TestBypass.isEnabled && email == TestBypass.testAdminEmail) {
        try {
          await _auth.signInWithEmailAndPassword(email: email, password: password.isEmpty ? 'admin123' : password);
        } on FirebaseAuthException {
          await _auth.createUserWithEmailAndPassword(email: email, password: password.isEmpty ? 'admin123' : password);
          await _db.collection(FirebaseKeys.users).doc(_auth.currentUser!.uid).set({
            'uid': _auth.currentUser!.uid, 'phone': '', 'name': 'Admin User',
            'email': email, 'role': 'super_admin', 'creditScore': 900,
            'kycStatus': 'verified', 'accountStatus': 'active',
            'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(), 'isOnline': true,
          });
        }
        await _updateFcmToken();
        return true;
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Verify admin role
      final doc = await _db.collection(FirebaseKeys.users).doc(_auth.currentUser!.uid).get();
      final role = doc.data()?['role'] ?? 'member';
      if (role != 'admin' && role != 'super_admin') {
        await _auth.signOut();
        return false;
      }
      await _updateFcmToken();
      return true;
    } catch (_) { return false; }
  }

  Future<void> _updateFcmToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final token = await NotificationService.getToken();
    if (token != null) await _db.collection(FirebaseKeys.users).doc(uid).update({'fcmToken': token});
  }

  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _db.collection(FirebaseKeys.users).doc(uid).update({'isOnline': false});
    await _auth.signOut();
  }
}
