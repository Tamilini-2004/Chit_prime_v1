import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

// User contributions — real-time
final myContributionsProvider = StreamProvider<List<ContributionModel>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseService.userContributionsStream(uid);
});

// Group contributions — real-time
final groupContributionsProvider =
    StreamProvider.family<List<ContributionModel>, String>(
        (ref, groupId) => FirebaseService.groupContributionsStream(groupId));

// All contributions (admin) — real-time
final allContributionsProvider = StreamProvider<List<ContributionModel>>(
    (ref) => FirebaseService.allContributionsStream());

// Group payouts — real-time
final groupPayoutsProvider =
    StreamProvider.family<List<PayoutModel>, String>(
        (ref, groupId) => FirebaseService.groupPayoutsStream(groupId));

// Single payout — real-time
final payoutProvider = StreamProvider.family<PayoutModel?, String>(
    (ref, payoutId) => FirebaseService.payoutStream(payoutId));

final paymentNotifierProvider =
    AsyncNotifierProvider<PaymentNotifier, void>(PaymentNotifier.new);

class PaymentNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Map<String, dynamic>> pay({
    required String groupId,
    required String groupName,
    required double amount,
    required int cycleNumber,
    required String method,
  }) =>
      FirebaseService.makePayment(
        groupId: groupId, groupName: groupName,
        amount: amount, cycleNumber: cycleNumber, method: method,
      );

  Future<void> confirmPayout(String payoutId) =>
      FirebaseService.confirmPayout(payoutId);
}
