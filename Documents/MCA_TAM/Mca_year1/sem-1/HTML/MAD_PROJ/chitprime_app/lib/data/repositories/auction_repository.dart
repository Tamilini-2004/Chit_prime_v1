import '../models/auction_model.dart';

class AuctionRepository {
  final List<AuctionModel> _auctions = [
    AuctionModel(
      auctionId: 'auc_001',
      groupId: 'grp_001',
      groupName: 'Retailers Gold Circle',
      cycleNumber: 9,
      auctionType: 'auction',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 22)),
      totalFund: 100000,
      status: 'live',
      bids: [
        BidModel(
          bidId: 'bid_001',
          auctionId: 'auc_001',
          userId: 'user_005',
          userName: 'Priya Sharma',
          bidAmount: 92000,
          bidTime: DateTime.now().subtract(const Duration(minutes: 30)),
          isWinning: false,
        ),
        BidModel(
          bidId: 'bid_002',
          auctionId: 'auc_001',
          userId: 'user_006',
          userName: 'Amit Patel',
          bidAmount: 94000,
          bidTime: DateTime.now().subtract(const Duration(minutes: 15)),
          isWinning: false,
        ),
        BidModel(
          bidId: 'bid_003',
          auctionId: 'auc_001',
          userId: 'user_007',
          userName: 'Sunita Devi',
          bidAmount: 96000,
          bidTime: DateTime.now().subtract(const Duration(minutes: 5)),
          isWinning: true,
        ),
      ],
    ),
    AuctionModel(
      auctionId: 'auc_002',
      groupId: 'grp_002',
      groupName: 'Small Business Fund',
      cycleNumber: 6,
      auctionType: 'lottery',
      startTime: DateTime.now().add(const Duration(days: 5)),
      endTime: DateTime.now().add(const Duration(days: 5, hours: 24)),
      totalFund: 45000,
      status: 'upcoming',
      bids: [],
    ),
    AuctionModel(
      auctionId: 'auc_003',
      groupId: 'grp_001',
      groupName: 'Retailers Gold Circle',
      cycleNumber: 8,
      auctionType: 'auction',
      startTime: DateTime(2024, 7, 15),
      endTime: DateTime(2024, 7, 16),
      totalFund: 100000,
      winnerUserId: 'user_008',
      winnerName: 'Mohan Lal',
      winningBid: 95000,
      status: 'completed',
      bids: [],
    ),
  ];

  Future<AuctionModel?> getLiveAuction(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      return _auctions.firstWhere(
        (a) => a.groupId == groupId && a.status == 'live',
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<AuctionModel>> getGroupAuctions(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _auctions.where((a) => a.groupId == groupId).toList();
  }

  Future<AuctionModel?> getAuctionById(String auctionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _auctions.firstWhere((a) => a.auctionId == auctionId);
    } catch (_) {
      return null;
    }
  }

  Future<BidModel> placeBid({
    required String auctionId,
    required String userId,
    required String userName,
    required double amount,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final bid = BidModel(
      bidId: 'bid_${DateTime.now().millisecondsSinceEpoch}',
      auctionId: auctionId,
      userId: userId,
      userName: userName,
      bidAmount: amount,
      bidTime: DateTime.now(),
      isWinning: true,
    );
    final auctionIndex = _auctions.indexWhere((a) => a.auctionId == auctionId);
    if (auctionIndex != -1) {
      final auction = _auctions[auctionIndex];
      final updatedBids = [...auction.bids.map((b) => BidModel(
            bidId: b.bidId,
            auctionId: b.auctionId,
            userId: b.userId,
            userName: b.userName,
            bidAmount: b.bidAmount,
            bidTime: b.bidTime,
            isWinning: false,
          )), bid];
      _auctions[auctionIndex] = AuctionModel(
        auctionId: auction.auctionId,
        groupId: auction.groupId,
        groupName: auction.groupName,
        cycleNumber: auction.cycleNumber,
        auctionType: auction.auctionType,
        startTime: auction.startTime,
        endTime: auction.endTime,
        totalFund: auction.totalFund,
        status: auction.status,
        bids: updatedBids,
      );
    }
    return bid;
  }

  Future<List<AuctionModel>> getAllLiveAuctions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _auctions.where((a) => a.status == 'live').toList();
  }
}
