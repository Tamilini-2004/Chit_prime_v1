import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class SeedData {
  static final _db = FirebaseFirestore.instance;
  static final _rtdb = FirebaseDatabase.instance;

  static Future<void> seedIfEmpty() async {
    try {
      final snap =
          await _db.collection('users').limit(1).get();
      if (snap.docs.isNotEmpty) return;
      await _seed();
    } catch (_) {}
  }

  static Future<void> _seed() async {
    final batch = _db.batch();
    final now = Timestamp.now();

    // Users
    final users = [
      {'uid': 'admin_001', 'phone': '+919000000001', 'name': 'Admin User', 'email': 'test@admin.com', 'role': 'super_admin', 'creditScore': 900, 'kycStatus': 'verified', 'accountStatus': 'active', 'createdAt': now, 'updatedAt': now, 'isOnline': false},
      {'uid': 'foreman_001', 'phone': '+919876543210', 'name': 'Rajesh Kumar', 'email': 'rajesh@test.com', 'role': 'foreman', 'creditScore': 820, 'kycStatus': 'verified', 'accountStatus': 'active', 'createdAt': now, 'updatedAt': now, 'isOnline': false},
      {'uid': 'member_001', 'phone': '+919876543211', 'name': 'Priya Sharma', 'email': 'priya@test.com', 'role': 'member', 'creditScore': 750, 'kycStatus': 'verified', 'accountStatus': 'active', 'createdAt': now, 'updatedAt': now, 'isOnline': false},
      {'uid': 'member_002', 'phone': '+919876543212', 'name': 'Amit Patel', 'email': 'amit@test.com', 'role': 'member', 'creditScore': 680, 'kycStatus': 'verified', 'accountStatus': 'active', 'createdAt': now, 'updatedAt': now, 'isOnline': false},
      {'uid': 'member_003', 'phone': '+919876543213', 'name': 'Sunita Devi', 'email': 'sunita@test.com', 'role': 'member', 'creditScore': 800, 'kycStatus': 'verified', 'accountStatus': 'active', 'createdAt': now, 'updatedAt': now, 'isOnline': false},
    ];
    for (final u in users) {
      batch.set(_db.collection('users').doc(u['uid'] as String), u);
    }

    // Groups with memberUids
    const g1 = 'group_001';
    const g2 = 'group_002';

    batch.set(_db.collection('groups').doc(g1), {
      'groupId': g1, 'groupCode': 'CP-2024-1001',
      'groupName': 'Kumar Textiles Chit',
      'fundType': 'auction', 'foremanUid': 'foreman_001',
      'foremanName': 'Rajesh Kumar',
      'monthlyContribution': 5000, 'totalMembers': 10,
      'currentMembers': 4, 'cycleDuration': 10, 'currentCycle': 3,
      'startDate': Timestamp.fromDate(DateTime(2024, 1, 1)),
      'status': 'active', 'totalFund': 50000,
      'commissionRate': 0.03, 'gstRate': 0.18,
      'nextAuctionDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
      'auctionWindowHours': 24, 'minCreditScore': 0, 'privacy': 'public',
      'memberUids': ['foreman_001', 'member_001', 'member_002', 'member_003'],
      'createdAt': now,
    });

    batch.set(_db.collection('groups').doc(g2), {
      'groupId': g2, 'groupCode': 'CP-2024-1002',
      'groupName': 'Patel Provisions Savings',
      'fundType': 'lottery', 'foremanUid': 'foreman_001',
      'foremanName': 'Rajesh Kumar',
      'monthlyContribution': 3000, 'totalMembers': 8,
      'currentMembers': 2, 'cycleDuration': 8, 'currentCycle': 2,
      'startDate': Timestamp.fromDate(DateTime(2024, 3, 1)),
      'status': 'active', 'totalFund': 24000,
      'commissionRate': 0.03, 'gstRate': 0.18,
      'nextAuctionDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      'auctionWindowHours': 24, 'minCreditScore': 0, 'privacy': 'public',
      'memberUids': ['foreman_001', 'member_001'],
      'createdAt': now,
    });

    // Members subcollections
    final g1Members = [
      {'uid': 'foreman_001', 'name': 'Rajesh Kumar', 'role': 'foreman', 'joinedAt': now, 'paymentStatusThisMonth': 'paid', 'creditScore': 820, 'totalContributed': 15000},
      {'uid': 'member_001', 'name': 'Priya Sharma', 'role': 'member', 'joinedAt': now, 'paymentStatusThisMonth': 'paid', 'creditScore': 750, 'totalContributed': 15000},
      {'uid': 'member_002', 'name': 'Amit Patel', 'role': 'member', 'joinedAt': now, 'paymentStatusThisMonth': 'pending', 'creditScore': 680, 'totalContributed': 10000},
      {'uid': 'member_003', 'name': 'Sunita Devi', 'role': 'member', 'joinedAt': now, 'paymentStatusThisMonth': 'paid', 'creditScore': 800, 'totalContributed': 15000},
    ];
    for (final m in g1Members) {
      batch.set(_db.collection('groups').doc(g1).collection('members').doc(m['uid'] as String), m);
    }

    final g2Members = [
      {'uid': 'foreman_001', 'name': 'Rajesh Kumar', 'role': 'foreman', 'joinedAt': now, 'paymentStatusThisMonth': 'paid', 'creditScore': 820, 'totalContributed': 6000},
      {'uid': 'member_001', 'name': 'Priya Sharma', 'role': 'member', 'joinedAt': now, 'paymentStatusThisMonth': 'paid', 'creditScore': 750, 'totalContributed': 6000},
    ];
    for (final m in g2Members) {
      batch.set(_db.collection('groups').doc(g2).collection('members').doc(m['uid'] as String), m);
    }

    // Contributions
    final contributions = [
      {'contributionId': 'con_001', 'groupId': g1, 'userId': 'member_001', 'userName': 'Priya Sharma', 'groupName': 'Kumar Textiles Chit', 'amount': 5000, 'cycleNumber': 1, 'month': 1, 'year': 2024, 'paymentDate': Timestamp.fromDate(DateTime(2024, 1, 5)), 'paymentMethod': 'UPI', 'transactionId': 'TXN20240105001', 'status': 'success', 'failureReason': ''},
      {'contributionId': 'con_002', 'groupId': g1, 'userId': 'member_001', 'userName': 'Priya Sharma', 'groupName': 'Kumar Textiles Chit', 'amount': 5000, 'cycleNumber': 2, 'month': 2, 'year': 2024, 'paymentDate': Timestamp.fromDate(DateTime(2024, 2, 6)), 'paymentMethod': 'Net Banking', 'transactionId': 'TXN20240206001', 'status': 'success', 'failureReason': ''},
      {'contributionId': 'con_003', 'groupId': g1, 'userId': 'member_001', 'userName': 'Priya Sharma', 'groupName': 'Kumar Textiles Chit', 'amount': 5000, 'cycleNumber': 3, 'month': 3, 'year': 2024, 'paymentDate': Timestamp.fromDate(DateTime(2024, 3, 4)), 'paymentMethod': 'UPI', 'transactionId': 'TXN20240304001', 'status': 'success', 'failureReason': ''},
      {'contributionId': 'con_004', 'groupId': g2, 'userId': 'member_001', 'userName': 'Priya Sharma', 'groupName': 'Patel Provisions Savings', 'amount': 3000, 'cycleNumber': 1, 'month': 3, 'year': 2024, 'paymentDate': Timestamp.fromDate(DateTime(2024, 3, 5)), 'paymentMethod': 'UPI', 'transactionId': 'TXN20240305003', 'status': 'success', 'failureReason': ''},
    ];
    for (final c in contributions) {
      batch.set(_db.collection('contributions').doc(c['contributionId'] as String), c);
    }

    // Active Auction
    const auctionId = 'auction_001';
    batch.set(_db.collection('auctions').doc(auctionId), {
      'auctionId': auctionId, 'groupId': g1,
      'groupName': 'Kumar Textiles Chit',
      'cycleNumber': 3, 'auctionType': 'auction',
      'startTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 22))),
      'totalFund': 50000, 'winnerUid': '', 'winnerName': '', 'winningBid': 0,
      'status': 'active', 'escrowStatus': 'held', 'lotteryParticipants': [],
      'createdAt': now,
    });

    // Notifications
    final notifications = [
      {'notificationId': 'notif_001', 'toUid': 'member_001', 'fromUid': 'system', 'type': 'auction', 'title': '🔨 Auction Started!', 'message': 'Cycle 3 auction for Kumar Textiles Chit is now live!', 'isRead': false, 'relatedId': auctionId, 'relatedType': 'auction', 'actionRoute': '/auction/$auctionId', 'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2)))},
      {'notificationId': 'notif_002', 'toUid': 'member_001', 'fromUid': 'system', 'type': 'payment', 'title': '✅ Payment Confirmed', 'message': 'Your payment of ₹5,000 for Kumar Textiles Chit was successful.', 'isRead': false, 'relatedId': 'con_003', 'relatedType': 'contribution', 'actionRoute': '/payment/$g1', 'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)))},
      {'notificationId': 'notif_003', 'toUid': 'foreman_001', 'fromUid': 'system', 'type': 'payment', 'title': '💰 Payment Received', 'message': 'Priya Sharma paid ₹5,000 for Kumar Textiles Chit.', 'isRead': false, 'relatedId': 'con_003', 'relatedType': 'contribution', 'actionRoute': '/groups/$g1', 'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)))},
      {'notificationId': 'notif_004', 'toUid': 'admin_001', 'fromUid': 'system', 'type': 'system', 'title': '⚠️ Fraud Alert', 'message': 'Suspicious bidding pattern detected.', 'isRead': false, 'relatedId': 'alert_001', 'relatedType': 'fraud', 'actionRoute': '/admin/fraud', 'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5)))},
    ];
    for (final n in notifications) {
      batch.set(_db.collection('notifications').doc(n['notificationId'] as String), n);
    }

    // Fraud Alert
    batch.set(_db.collection('fraud_alerts').doc('alert_001'), {
      'alertId': 'alert_001', 'userId': 'member_002', 'userName': 'Amit Patel',
      'groupId': g1, 'alertType': 'fake_bid', 'severity': 'medium',
      'description': 'Bid placed within 200ms of previous bid — possible bot activity',
      'evidence': {'bidTime': '200ms', 'pattern': 'repeated', 'count': 3},
      'aiConfidence': 0.78, 'status': 'open',
      'detectedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
      'resolvedAt': null, 'resolvedByUid': '', 'resolutionNotes': '',
    });

    // Platform settings
    batch.set(_db.collection('settings').doc('platform'), {
      'commissionRate': 0.03, 'gstRate': 0.18, 'minGroupSize': 2,
      'maxGroupSize': 50, 'defaultAuctionWindowHours': 24,
      'payoutConfirmationTimeoutHours': 48, 'maintenanceMode': false,
      'maintenanceMessage': '',
    });

    await batch.commit();

    // Seed Realtime DB bids
    try {
      await _rtdb.ref('auctions/$auctionId').set({
        'currentHighest': 44000,
        'currentHighestUserId': 'member_003',
        'totalBids': 3,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'bids': {
          'bid_001': {'bidId': 'bid_001', 'auctionId': auctionId, 'userId': 'member_001', 'userName': 'Priya Sharma', 'bidAmount': 42000, 'bidTime': DateTime.now().subtract(const Duration(minutes: 45)).millisecondsSinceEpoch, 'isWinning': false},
          'bid_002': {'bidId': 'bid_002', 'auctionId': auctionId, 'userId': 'member_002', 'userName': 'Amit Patel', 'bidAmount': 43000, 'bidTime': DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch, 'isWinning': false},
          'bid_003': {'bidId': 'bid_003', 'auctionId': auctionId, 'userId': 'member_003', 'userName': 'Sunita Devi', 'bidAmount': 44000, 'bidTime': DateTime.now().subtract(const Duration(minutes: 10)).millisecondsSinceEpoch, 'isWinning': true},
        },
      });
    } catch (_) {}
  }
}
