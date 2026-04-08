import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String contributionId;
  final String groupId;
  final String userId;
  final String userName;
  final String groupName;
  final double amount;
  final int cycleNumber;
  final int month;
  final int year;
  final DateTime? paymentDate;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final String failureReason;

  const ContributionModel({
    required this.contributionId, required this.groupId, required this.userId,
    required this.userName, required this.groupName, required this.amount,
    required this.cycleNumber, required this.month, required this.year,
    this.paymentDate, this.paymentMethod = 'UPI', this.transactionId = '',
    this.status = 'success', this.failureReason = '',
  });

  factory ContributionModel.fromDoc(DocumentSnapshot doc) {
    final j = doc.data() as Map<String, dynamic>;
    return ContributionModel(
      contributionId: doc.id,
      groupId: j['groupId'] ?? '',
      userId: j['userId'] ?? '',
      userName: j['userName'] ?? '',
      groupName: j['groupName'] ?? '',
      amount: (j['amount'] as num?)?.toDouble() ?? 0,
      cycleNumber: (j['cycleNumber'] as num?)?.toInt() ?? 1,
      month: (j['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (j['year'] as num?)?.toInt() ?? DateTime.now().year,
      paymentDate: (j['paymentDate'] as Timestamp?)?.toDate(),
      paymentMethod: j['paymentMethod'] ?? 'UPI',
      transactionId: j['transactionId'] ?? '',
      status: j['status'] ?? 'success',
      failureReason: j['failureReason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'contributionId': contributionId, 'groupId': groupId, 'userId': userId,
    'userName': userName, 'groupName': groupName, 'amount': amount,
    'cycleNumber': cycleNumber, 'month': month, 'year': year,
    'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
    'paymentMethod': paymentMethod, 'transactionId': transactionId,
    'status': status, 'failureReason': failureReason,
  };
}

class PayoutModel {
  final String payoutId;
  final String groupId;
  final String groupName;
  final String winnerUid;
  final String winnerName;
  final String auctionId;
  final int cycleNumber;
  final double grossAmount;
  final double platformCommission;
  final double gstAmount;
  final double netPayout;
  final String escrowStatus;
  final String status;
  final DateTime? payoutDate;
  final bool confirmedByForeman;
  final DateTime createdAt;

  const PayoutModel({
    required this.payoutId, required this.groupId, required this.groupName,
    required this.winnerUid, required this.winnerName, required this.auctionId,
    required this.cycleNumber, required this.grossAmount,
    required this.platformCommission, required this.gstAmount,
    required this.netPayout, this.escrowStatus = 'held', this.status = 'pending',
    this.payoutDate, this.confirmedByForeman = false, required this.createdAt,
  });

  factory PayoutModel.fromDoc(DocumentSnapshot doc) {
    final j = doc.data() as Map<String, dynamic>;
    return PayoutModel(
      payoutId: doc.id,
      groupId: j['groupId'] ?? '',
      groupName: j['groupName'] ?? '',
      winnerUid: j['winnerUid'] ?? '',
      winnerName: j['winnerName'] ?? '',
      auctionId: j['auctionId'] ?? '',
      cycleNumber: (j['cycleNumber'] as num?)?.toInt() ?? 1,
      grossAmount: (j['grossAmount'] as num?)?.toDouble() ?? 0,
      platformCommission: (j['platformCommission'] as num?)?.toDouble() ?? 0,
      gstAmount: (j['gstAmount'] as num?)?.toDouble() ?? 0,
      netPayout: (j['netPayout'] as num?)?.toDouble() ?? 0,
      escrowStatus: j['escrowStatus'] ?? 'held',
      status: j['status'] ?? 'pending',
      payoutDate: (j['payoutDate'] as Timestamp?)?.toDate(),
      confirmedByForeman: j['confirmedByForeman'] ?? false,
      createdAt: (j['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'payoutId': payoutId, 'groupId': groupId, 'groupName': groupName,
    'winnerUid': winnerUid, 'winnerName': winnerName, 'auctionId': auctionId,
    'cycleNumber': cycleNumber, 'grossAmount': grossAmount,
    'platformCommission': platformCommission, 'gstAmount': gstAmount,
    'netPayout': netPayout, 'escrowStatus': escrowStatus, 'status': status,
    'payoutDate': payoutDate != null ? Timestamp.fromDate(payoutDate!) : null,
    'confirmedByForeman': confirmedByForeman,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
