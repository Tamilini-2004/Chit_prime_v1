import '../models/payment_model.dart';

class PaymentRepository {
  final List<ContributionModel> _contributions = [
    ContributionModel(
      contributionId: 'con_001',
      groupId: 'grp_001',
      groupName: 'Retailers Gold Circle',
      userId: 'user_001',
      amount: 5000,
      cycleNumber: 8,
      paymentDate: DateTime(2024, 8, 5),
      paymentMethod: 'UPI',
      transactionId: 'TXN20240805001',
      status: 'success',
      dueDate: DateTime(2024, 8, 10),
    ),
    ContributionModel(
      contributionId: 'con_002',
      groupId: 'grp_001',
      groupName: 'Retailers Gold Circle',
      userId: 'user_001',
      amount: 5000,
      cycleNumber: 7,
      paymentDate: DateTime(2024, 7, 6),
      paymentMethod: 'UPI',
      transactionId: 'TXN20240706001',
      status: 'success',
      dueDate: DateTime(2024, 7, 10),
    ),
    ContributionModel(
      contributionId: 'con_003',
      groupId: 'grp_002',
      groupName: 'Small Business Fund',
      userId: 'user_001',
      amount: 3000,
      cycleNumber: 5,
      paymentDate: null,
      paymentMethod: '',
      transactionId: '',
      status: 'pending',
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
    ContributionModel(
      contributionId: 'con_004',
      groupId: 'grp_002',
      groupName: 'Small Business Fund',
      userId: 'user_001',
      amount: 3000,
      cycleNumber: 4,
      paymentDate: DateTime(2024, 7, 8),
      paymentMethod: 'Net Banking',
      transactionId: 'TXN20240708002',
      status: 'success',
      dueDate: DateTime(2024, 7, 10),
    ),
  ];

  final List<PayoutModel> _payouts = [
    PayoutModel(
      payoutId: 'pay_001',
      groupId: 'grp_001',
      groupName: 'Retailers Gold Circle',
      userId: 'user_005',
      userName: 'Priya Sharma',
      cycleNumber: 3,
      grossAmount: 100000,
      platformFee: 3000,
      gstAmount: 540,
      netPayout: 96460,
      transactionId: 'PAY20240315001',
      payoutDate: DateTime(2024, 3, 15),
      status: 'completed',
    ),
    PayoutModel(
      payoutId: 'pay_002',
      groupId: 'grp_001',
      groupName: 'Retailers Gold Circle',
      userId: 'user_006',
      userName: 'Amit Patel',
      cycleNumber: 6,
      grossAmount: 100000,
      platformFee: 3000,
      gstAmount: 540,
      netPayout: 96460,
      transactionId: 'PAY20240615002',
      payoutDate: DateTime(2024, 6, 15),
      status: 'completed',
    ),
  ];

  Future<List<ContributionModel>> getUserContributions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _contributions.where((c) => c.userId == userId).toList();
  }

  Future<List<ContributionModel>> getGroupContributions(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _contributions.where((c) => c.groupId == groupId).toList();
  }

  Future<List<ContributionModel>> getPendingPayments(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _contributions
        .where((c) => c.userId == userId && c.status == 'pending')
        .toList();
  }

  Future<ContributionModel> processPayment({
    required String groupId,
    required String userId,
    required double amount,
    required String paymentMethod,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final contribution = ContributionModel(
      contributionId: 'con_${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      groupName: 'Group',
      userId: userId,
      amount: amount,
      cycleNumber: 1,
      paymentDate: DateTime.now(),
      paymentMethod: paymentMethod,
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      status: 'success',
      dueDate: DateTime.now(),
    );
    _contributions.add(contribution);
    return contribution;
  }

  Future<List<PayoutModel>> getGroupPayouts(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _payouts.where((p) => p.groupId == groupId).toList();
  }

  Future<List<ContributionModel>> getAllTransactions() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _contributions;
  }
}
