class ContributionModel {
  final String contributionId;
  final String groupId;
  final String groupName;
  final String userId;
  final double amount;
  final int cycleNumber;
  final DateTime? paymentDate;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final DateTime dueDate;

  const ContributionModel({
    required this.contributionId,
    required this.groupId,
    required this.groupName,
    required this.userId,
    required this.amount,
    required this.cycleNumber,
    this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.dueDate,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) =>
      ContributionModel(
        contributionId: json['contribution_id'] ?? '',
        groupId: json['group_id'] ?? '',
        groupName: json['group_name'] ?? '',
        userId: json['user_id'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        cycleNumber: json['cycle_number'] ?? 1,
        paymentDate: json['payment_date'] != null
            ? DateTime.parse(json['payment_date'])
            : null,
        paymentMethod: json['payment_method'] ?? '',
        transactionId: json['transaction_id'] ?? '',
        status: json['status'] ?? 'pending',
        dueDate: DateTime.parse(
            json['due_date'] ?? DateTime.now().toIso8601String()),
      );
}

class PayoutModel {
  final String payoutId;
  final String groupId;
  final String groupName;
  final String userId;
  final String userName;
  final int cycleNumber;
  final double grossAmount;
  final double platformFee;
  final double gstAmount;
  final double netPayout;
  final String transactionId;
  final DateTime payoutDate;
  final String status;

  const PayoutModel({
    required this.payoutId,
    required this.groupId,
    required this.groupName,
    required this.userId,
    required this.userName,
    required this.cycleNumber,
    required this.grossAmount,
    required this.platformFee,
    required this.gstAmount,
    required this.netPayout,
    required this.transactionId,
    required this.payoutDate,
    required this.status,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) => PayoutModel(
        payoutId: json['payout_id'] ?? '',
        groupId: json['group_id'] ?? '',
        groupName: json['group_name'] ?? '',
        userId: json['user_id'] ?? '',
        userName: json['user_name'] ?? '',
        cycleNumber: json['cycle_number'] ?? 1,
        grossAmount: (json['gross_amount'] ?? 0).toDouble(),
        platformFee: (json['platform_fee'] ?? 0).toDouble(),
        gstAmount: (json['gst_amount'] ?? 0).toDouble(),
        netPayout: (json['net_payout'] ?? 0).toDouble(),
        transactionId: json['transaction_id'] ?? '',
        payoutDate: DateTime.parse(
            json['payout_date'] ?? DateTime.now().toIso8601String()),
        status: json['status'] ?? 'pending',
      );
}
