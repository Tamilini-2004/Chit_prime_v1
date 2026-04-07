class AuctionModel {
  final String auctionId;
  final String groupId;
  final String groupName;
  final int cycleNumber;
  final String auctionType;
  final DateTime startTime;
  final DateTime endTime;
  final double totalFund;
  final String? winnerUserId;
  final String? winnerName;
  final double? winningBid;
  final String status;
  final List<BidModel> bids;

  const AuctionModel({
    required this.auctionId,
    required this.groupId,
    required this.groupName,
    required this.cycleNumber,
    required this.auctionType,
    required this.startTime,
    required this.endTime,
    required this.totalFund,
    this.winnerUserId,
    this.winnerName,
    this.winningBid,
    required this.status,
    this.bids = const [],
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) => AuctionModel(
        auctionId: json['auction_id'] ?? '',
        groupId: json['group_id'] ?? '',
        groupName: json['group_name'] ?? '',
        cycleNumber: json['cycle_number'] ?? 1,
        auctionType: json['auction_type'] ?? 'auction',
        startTime: DateTime.parse(
            json['start_time'] ?? DateTime.now().toIso8601String()),
        endTime: DateTime.parse(
            json['end_time'] ?? DateTime.now().toIso8601String()),
        totalFund: (json['total_fund'] ?? 0).toDouble(),
        winnerUserId: json['winner_user_id'],
        winnerName: json['winner_name'],
        winningBid: json['winning_bid']?.toDouble(),
        status: json['status'] ?? 'upcoming',
        bids: (json['bids'] as List<dynamic>?)
                ?.map((b) => BidModel.fromJson(b))
                .toList() ??
            [],
      );

  Duration get timeRemaining => endTime.difference(DateTime.now());
  bool get isLive => status == 'live';
  double get highestBid =>
      bids.isEmpty ? 0 : bids.map((b) => b.bidAmount).reduce((a, b) => a > b ? a : b);
}

class BidModel {
  final String bidId;
  final String auctionId;
  final String userId;
  final String userName;
  final double bidAmount;
  final DateTime bidTime;
  final bool isWinning;

  const BidModel({
    required this.bidId,
    required this.auctionId,
    required this.userId,
    required this.userName,
    required this.bidAmount,
    required this.bidTime,
    required this.isWinning,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) => BidModel(
        bidId: json['bid_id'] ?? '',
        auctionId: json['auction_id'] ?? '',
        userId: json['user_id'] ?? '',
        userName: json['user_name'] ?? '',
        bidAmount: (json['bid_amount'] ?? 0).toDouble(),
        bidTime: DateTime.parse(
            json['bid_time'] ?? DateTime.now().toIso8601String()),
        isWinning: json['is_winning'] ?? false,
      );
}
