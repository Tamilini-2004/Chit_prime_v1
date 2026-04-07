import 'package:flutter/material.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/repositories/auction_repository.dart';

class AuctionProvider extends ChangeNotifier {
  final AuctionRepository _repo;
  AuctionModel? _currentAuction;
  List<AuctionModel> _auctionHistory = [];
  bool _isLoading = false;
  bool _isPlacingBid = false;
  String? _error;

  AuctionProvider(this._repo);

  AuctionModel? get currentAuction => _currentAuction;
  List<AuctionModel> get auctionHistory => _auctionHistory;
  bool get isLoading => _isLoading;
  bool get isPlacingBid => _isPlacingBid;
  String? get error => _error;

  Future<void> loadAuction(String groupId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentAuction = await _repo.getLiveAuction(groupId);
      _auctionHistory = await _repo.getGroupAuctions(groupId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> placeBid({
    required String auctionId,
    required String userId,
    required String userName,
    required double amount,
  }) async {
    _isPlacingBid = true;
    _error = null;
    notifyListeners();
    try {
      final bid = await _repo.placeBid(
        auctionId: auctionId,
        userId: userId,
        userName: userName,
        amount: amount,
      );
      if (_currentAuction != null) {
        final updatedBids = [
          ..._currentAuction!.bids.map((b) => BidModel(
                bidId: b.bidId,
                auctionId: b.auctionId,
                userId: b.userId,
                userName: b.userName,
                bidAmount: b.bidAmount,
                bidTime: b.bidTime,
                isWinning: false,
              )),
          bid,
        ];
        _currentAuction = AuctionModel(
          auctionId: _currentAuction!.auctionId,
          groupId: _currentAuction!.groupId,
          groupName: _currentAuction!.groupName,
          cycleNumber: _currentAuction!.cycleNumber,
          auctionType: _currentAuction!.auctionType,
          startTime: _currentAuction!.startTime,
          endTime: _currentAuction!.endTime,
          totalFund: _currentAuction!.totalFund,
          status: _currentAuction!.status,
          bids: updatedBids,
        );
      }
      _isPlacingBid = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isPlacingBid = false;
      notifyListeners();
      return false;
    }
  }
}
