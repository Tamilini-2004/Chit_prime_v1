import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/services/firebase_service.dart';
import '../../../core/constants/firebase_keys.dart';
import '../../../core/utils/app_utils.dart';
import '../../auth/providers/auth_provider.dart';

final _db = FirebaseFirestore.instance;
final _rtdb = FirebaseDatabase.instance;

// Group auctions — real-time
final groupAuctionsProvider =
    StreamProvider.family<List<AuctionModel>, String>(
        (ref, groupId) => FirebaseService.groupAuctionsStream(groupId));

// Single auction — real-time
final auctionProvider = StreamProvider.family<AuctionModel?, String>(
    (ref, id) => FirebaseService.auctionStream(id));

// All active auctions
final allActiveAuctionsProvider = StreamProvider<List<AuctionModel>>(
    (ref) => FirebaseService.activeAuctionsStream());

// Live bids from Realtime DB
final liveBidsProvider =
    StreamProvider.family<List<BidModel>, String>((ref, auctionId) {
  return _rtdb
      .ref('${FirebaseKeys.rtdbAuctions}/$auctionId/${FirebaseKeys.rtdbBids}')
      .onValue
      .map((event) {
    final data = event.snapshot.value;
    if (data == null) return <BidModel>[];
    final map = Map<String, dynamic>.from(data as Map);
    return map.entries
        .map((e) => BidModel.fromMap(
            e.key, Map<dynamic, dynamic>.from(e.value as Map)))
        .toList()
      ..sort((a, b) => b.bidAmount.compareTo(a.bidAmount));
  });
});

// Current highest bid
final currentHighestProvider =
    StreamProvider.family<double, String>((ref, auctionId) {
  return _rtdb
      .ref('${FirebaseKeys.rtdbAuctions}/$auctionId/currentHighest')
      .onValue
      .map((e) => (e.snapshot.value as num?)?.toDouble() ?? 0);
});

final auctionNotifierProvider =
    AsyncNotifierProvider<AuctionNotifier, void>(AuctionNotifier.new);

class AuctionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> placeBid({
    required String auctionId,
    required double amount,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userDoc =
        await _db.collection(FirebaseKeys.users).doc(uid).get();
    final name = userDoc.data()?['name'] ?? 'Bidder';
    final bidId = 'bid_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().millisecondsSinceEpoch;

    // Write to Realtime DB
    await _rtdb
        .ref('${FirebaseKeys.rtdbAuctions}/$auctionId/${FirebaseKeys.rtdbBids}/$bidId')
        .set({
      'bidId': bidId, 'auctionId': auctionId,
      'userId': uid, 'userName': name,
      'bidAmount': amount, 'bidTime': now, 'isWinning': true,
    });

    // Update highest
    await _rtdb.ref('${FirebaseKeys.rtdbAuctions}/$auctionId').update({
      'currentHighest': amount,
      'currentHighestUserId': uid,
      'totalBids': ServerValue.increment(1),
      'lastUpdated': now,
    });

    // Mark previous bids as not winning
    final snap = await _rtdb
        .ref('${FirebaseKeys.rtdbAuctions}/$auctionId/${FirebaseKeys.rtdbBids}')
        .get();
    if (snap.exists) {
      final bids = Map<String, dynamic>.from(snap.value as Map);
      for (final entry in bids.entries) {
        if (entry.key != bidId) {
          await _rtdb
              .ref('${FirebaseKeys.rtdbAuctions}/$auctionId/${FirebaseKeys.rtdbBids}/${entry.key}')
              .update({'isWinning': false});
        }
      }
    }

    // Notify all group members
    final auctionDoc =
        await _db.collection(FirebaseKeys.auctions).doc(auctionId).get();
    final groupId = auctionDoc.data()?['groupId'] ?? '';
    final groupName = auctionDoc.data()?['groupName'] ?? '';
    final members = await _db
        .collection(FirebaseKeys.groups)
        .doc(groupId)
        .collection(FirebaseKeys.members)
        .get();
    final batch = _db.batch();
    for (final m in members.docs) {
      if (m.id == uid) continue;
      final nRef = _db.collection(FirebaseKeys.notifications).doc();
      batch.set(nRef, {
        'toUid': m.id, 'fromUid': uid, 'type': 'auction',
        'title': '🔨 New Bid Placed!',
        'message': '$name bid ${AppUtils.formatCurrency(amount)} in $groupName',
        'isRead': false, 'relatedId': auctionId, 'relatedType': 'auction',
        'actionRoute': '/auction/$auctionId',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> joinLottery(String auctionId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _db.collection(FirebaseKeys.auctions).doc(auctionId).update({
      'lotteryParticipants': FieldValue.arrayUnion([uid]),
    });
  }

  Future<String> openAuction(String groupId) =>
      FirebaseService.openAuction(groupId);

  Future<String> closeAuctionAndSelectWinner(String auctionId) async {
    final auctionDoc =
        await _db.collection(FirebaseKeys.auctions).doc(auctionId).get();
    final auction = AuctionModel.fromDoc(auctionDoc);

    String winnerUid = '';
    String winnerName = '';
    double winningBid = 0;

    if (auction.auctionType == 'auction') {
      final snap = await _rtdb
          .ref('${FirebaseKeys.rtdbAuctions}/$auctionId/${FirebaseKeys.rtdbBids}')
          .get();
      if (snap.exists) {
        final bids = Map<String, dynamic>.from(snap.value as Map);
        BidModel? highest;
        for (final e in bids.entries) {
          final bid = BidModel.fromMap(
              e.key, Map<dynamic, dynamic>.from(e.value as Map));
          if (highest == null || bid.bidAmount > highest.bidAmount) {
            highest = bid;
          }
        }
        if (highest != null) {
          winnerUid = highest.userId;
          winnerName = highest.userName;
          winningBid = highest.bidAmount;
        }
      }
    } else {
      final participants = auction.lotteryParticipants;
      if (participants.isNotEmpty) {
        final idx =
            DateTime.now().millisecondsSinceEpoch % participants.length;
        winnerUid = participants[idx];
        final userDoc =
            await _db.collection(FirebaseKeys.users).doc(winnerUid).get();
        winnerName = userDoc.data()?['name'] ?? 'Winner';
        winningBid = auction.totalFund;
      }
    }

    if (winnerUid.isEmpty) return '';

    // Update auction
    await _db.collection(FirebaseKeys.auctions).doc(auctionId).update({
      'status': 'closed',
      'winnerUid': winnerUid,
      'winnerName': winnerName,
      'winningBid': winningBid,
    });

    // Create payout
    final commission = auction.totalFund * 0.03;
    final gst = commission * 0.18;
    final net = auction.totalFund - commission - gst;
    final payoutRef = _db.collection(FirebaseKeys.payouts).doc();
    await payoutRef.set({
      'payoutId': payoutRef.id,
      'groupId': auction.groupId,
      'groupName': auction.groupName,
      'winnerUid': winnerUid,
      'winnerName': winnerName,
      'auctionId': auctionId,
      'cycleNumber': auction.cycleNumber,
      'grossAmount': auction.totalFund,
      'platformCommission': commission,
      'gstAmount': gst,
      'netPayout': net,
      'escrowStatus': 'held',
      'status': 'pending',
      'confirmedByForeman': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify all members
    final members = await _db
        .collection(FirebaseKeys.groups)
        .doc(auction.groupId)
        .collection(FirebaseKeys.members)
        .get();
    final batch = _db.batch();
    for (final m in members.docs) {
      final nRef = _db.collection(FirebaseKeys.notifications).doc();
      batch.set(nRef, {
        'toUid': m.id, 'fromUid': 'system', 'type': 'auction',
        'title': '🏆 Winner Announced!',
        'message':
            '$winnerName won Cycle ${auction.cycleNumber} for ${auction.groupName}!',
        'isRead': false, 'relatedId': auctionId, 'relatedType': 'auction',
        'actionRoute': '/winner/$auctionId',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return payoutRef.id;
  }
}
