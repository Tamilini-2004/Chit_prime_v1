import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionModel {
  final String auctionId;
  final String groupId;
  final String groupName;
  final int cycleNumber;
  final String auctionType;
  final DateTime startTime;
  final DateTime endTime;
  final double totalFund;
  final String winnerUid;
  final String winnerName;
  final double winningBid;
  final String status;
  final String escrowStatus;
  final List<String> lotteryParticipants;
  final DateTime createdAt;

  const AuctionModel({
    required this.auctionId, required this.groupId, required this.groupName,
    required this.cycleNumber, this.auctionType = 'auction',
    required this.startTime, required this.endTime, required this.totalFund,
    this.winnerUid = '', this.winnerName = '', this.winningBid = 0,
    this.status = 'open', this.escrowStatus = 'held',
    this.lotteryParticipants = const [], required this.createdAt,
  });

  factory AuctionModel.fromDoc(DocumentSnapshot doc) {
    final j = doc.data() as Map<String, dynamic>;
    return AuctionModel(
      auctionId: doc.id, groupId: j['groupId'] ?? '',
      groupName: j['groupName'] ?? '',
      cycleNumber: (j['cycleNumber'] as num?)?.toInt() ?? 1,
      auctionType: j['auctionType'] ?? 'auction',
      startTime: (j['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (j['endTime'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(hours: 24)),
      totalFund: (j['totalFund'] ?? 0).toDouble(),
      winnerUid: j['winnerUid'] ?? '', winnerName: j['winnerName'] ?? '',
      winningBid: (j['winningBid'] ?? 0).toDouble(),
      status: j['status'] ?? 'open', escrowStatus: j['escrowStatus'] ?? 'held',
      lotteryParticipants: List<String>.from(j['lotteryParticipants'] ?? []),
      createdAt: (j['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'auctionId': auctionId, 'groupId': groupId, 'groupName': groupName,
    'cycleNumber': cycleNumber, 'auctionType': auctionType,
    'startTime': Timestamp.fromDate(startTime), 'endTime': Timestamp.fromDate(endTime),
    'totalFund': totalFund, 'winnerUid': winnerUid, 'winnerName': winnerName,
    'winningBid': winningBid, 'status': status, 'escrowStatus': escrowStatus,
    'lotteryParticipants': lotteryParticipants, 'createdAt': Timestamp.fromDate(createdAt),
  };

  Duration get timeRemaining => endTime.difference(DateTime.now());
  bool get isLive => status == 'active';
  bool get isOpen => status == 'open' || status == 'active';
}

class BidModel {
  final String bidId;
  final String auctionId;
  final String userId;
  final String userName;
  final double bidAmount;
  final int bidTime;
  final bool isWinning;

  const BidModel({
    required this.bidId, required this.auctionId, required this.userId,
    required this.userName, required this.bidAmount, required this.bidTime,
    this.isWinning = false,
  });

  factory BidModel.fromMap(String id, Map<dynamic, dynamic> m) => BidModel(
    bidId: id, auctionId: m['auctionId']?.toString() ?? '',
    userId: m['userId']?.toString() ?? '',
    userName: m['userName']?.toString() ?? '',
    bidAmount: (m['bidAmount'] as num?)?.toDouble() ?? 0,
    bidTime: (m['bidTime'] as num?)?.toInt() ?? 0,
    isWinning: m['isWinning'] as bool? ?? false,
  );

  Map<String, dynamic> toMap() => {
    'bidId': bidId, 'auctionId': auctionId, 'userId': userId,
    'userName': userName, 'bidAmount': bidAmount,
    'bidTime': bidTime, 'isWinning': isWinning,
  };

  DateTime get bidDateTime => DateTime.fromMillisecondsSinceEpoch(bidTime);
}
