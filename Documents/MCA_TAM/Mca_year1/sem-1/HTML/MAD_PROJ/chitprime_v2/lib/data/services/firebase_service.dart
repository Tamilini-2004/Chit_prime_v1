import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';
import '../models/payment_model.dart';
import '../models/auction_model.dart';
import '../models/notification_model.dart';
import '../../core/constants/firebase_keys.dart';
import '../../core/utils/app_utils.dart';

/// Central Firebase service — all Firestore reads/writes go through here
class FirebaseService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get currentUid => _auth.currentUser?.uid ?? '';

  // ── USER OPERATIONS ────────────────────────────────────────────────────────

  static Future<void> createOrUpdateUser({
    required String uid,
    required String phone,
    required String name,
    String email = '',
    String role = 'member',
    int creditScore = 650,
  }) async {
    final ref = _db.collection(FirebaseKeys.users).doc(uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'uid': uid, 'phone': phone, 'name': name, 'email': email,
        'role': role, 'creditScore': creditScore,
        'kycStatus': 'verified', 'accountStatus': 'active',
        'bankName': '', 'ifsc': '', 'bankMasked': '',
        'aadhaarLast4': '', 'panMasked': '',
        'city': '', 'state': '', 'fcmToken': '',
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({'isOnline': true, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final update = Map<String, dynamic>.from(data);
    update['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(FirebaseKeys.users).doc(uid).update(update);
  }

  static Stream<UserModel?> userStream(String uid) {
    return _db.collection(FirebaseKeys.users).doc(uid).snapshots()
        .map((d) => d.exists ? UserModel.fromDoc(d) : null);
  }

  static Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(FirebaseKeys.users).doc(uid).get();
    return doc.exists ? UserModel.fromDoc(doc) : null;
  }

  static Stream<List<UserModel>> allUsersStream() {
    return _db.collection(FirebaseKeys.users)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromDoc).toList());
  }

  static Future<void> updateCreditScore(String uid, int delta) async {
    await _db.collection(FirebaseKeys.users).doc(uid).update({
      'creditScore': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Store score history
    await _db.collection(FirebaseKeys.users).doc(uid)
        .collection(FirebaseKeys.scoreHistory).add({
      'change': delta,
      'reason': delta > 0 ? 'Payment made on time' : 'Payment missed',
      'date': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> suspendUser(String uid) async {
    await _db.collection(FirebaseKeys.users).doc(uid).update({
      'accountStatus': 'suspended',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _logAdminAction(uid, 'suspend_user', 'user');
    await sendNotification(
      toUid: uid,
      title: '🚫 Account Suspended',
      message: 'Your account has been suspended. Contact support.',
      type: 'system',
      actionRoute: '/profile',
    );
  }

  static Future<void> activateUser(String uid) async {
    await _db.collection(FirebaseKeys.users).doc(uid).update({
      'accountStatus': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _logAdminAction(uid, 'activate_user', 'user');
    await sendNotification(
      toUid: uid,
      title: '✅ Account Activated',
      message: 'Your account has been reactivated. Welcome back!',
      type: 'system',
      actionRoute: '/profile',
    );
  }

  static Future<void> verifyKyc(String uid) async {
    await _db.collection(FirebaseKeys.users).doc(uid).update({
      'kycStatus': 'verified',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _logAdminAction(uid, 'verify_kyc', 'user');
    await sendNotification(
      toUid: uid,
      title: '✅ KYC Verified!',
      message: 'Your KYC documents have been verified. You now have full access.',
      type: 'system',
      actionRoute: '/profile',
    );
  }

  // ── GROUP OPERATIONS ───────────────────────────────────────────────────────

  static Stream<List<GroupModel>> allGroupsStream() {
    return _db.collection(FirebaseKeys.groups)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(GroupModel.fromDoc).toList());
  }

  static Stream<List<GroupModel>> publicGroupsStream() {
    return _db.collection(FirebaseKeys.groups)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(GroupModel.fromDoc)
            .where((g) => g.status != 'terminated').toList());
  }

  static Stream<List<GroupModel>> myGroupsStream(String uid) {
    return _db.collection(FirebaseKeys.groups)
        .where('memberUids', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(GroupModel.fromDoc).toList());
  }

  static Stream<GroupModel?> groupStream(String groupId) {
    return _db.collection(FirebaseKeys.groups).doc(groupId).snapshots()
        .map((d) => d.exists ? GroupModel.fromDoc(d) : null);
  }

  static Stream<List<MemberModel>> groupMembersStream(String groupId) {
    return _db.collection(FirebaseKeys.groups).doc(groupId)
        .collection(FirebaseKeys.members).snapshots()
        .map((s) => s.docs.map(MemberModel.fromDoc).toList());
  }

  static Future<String> createGroup({
    required String name,
    required double contribution,
    required int members,
    required int duration,
    String fundType = 'auction',
    String privacy = 'public',
  }) async {
    final uid = currentUid;
    final userDoc = await _db.collection(FirebaseKeys.users).doc(uid).get();
    final userName = userDoc.data()?['name'] ?? 'Admin';
    final ref = _db.collection(FirebaseKeys.groups).doc();
    final now = DateTime.now();

    await ref.set({
      'groupId': ref.id,
      'groupCode': AppUtils.generateGroupCode(),
      'groupName': name.isEmpty ? 'Chit Group' : name,
      'fundType': fundType,
      'foremanUid': uid,
      'foremanName': userName,
      'monthlyContribution': contribution,
      'totalMembers': members,
      'currentMembers': 1,
      'cycleDuration': duration,
      'currentCycle': 1,
      'startDate': Timestamp.fromDate(now),
      'status': 'active',
      'totalFund': contribution * members,
      'commissionRate': 0.03,
      'gstRate': 0.18,
      'nextAuctionDate': Timestamp.fromDate(now.add(const Duration(days: 30))),
      'auctionWindowHours': 24,
      'minCreditScore': 0,
      'privacy': privacy,
      'memberUids': [uid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await ref.collection(FirebaseKeys.members).doc(uid).set({
      'uid': uid, 'name': userName, 'role': 'foreman',
      'joinedAt': FieldValue.serverTimestamp(),
      'paymentStatusThisMonth': 'paid',
      'creditScore': 650, 'totalContributed': 0,
    });

    await _logAdminAction(ref.id, 'create_group', 'group');
    return ref.id;
  }

  static Future<void> joinGroup(String groupId) async {
    final uid = currentUid;
    if (uid.isEmpty) return;

    final userDoc = await _db.collection(FirebaseKeys.users).doc(uid).get();
    final name = userDoc.data()?['name'] ?? 'Member';
    final creditScore = (userDoc.data()?['creditScore'] as num?)?.toInt() ?? 650;

    final existing = await _db.collection(FirebaseKeys.groups).doc(groupId)
        .collection(FirebaseKeys.members).doc(uid).get();
    if (existing.exists) return;

    final batch = _db.batch();

    // Add to members subcollection
    batch.set(
      _db.collection(FirebaseKeys.groups).doc(groupId).collection(FirebaseKeys.members).doc(uid),
      {
        'uid': uid, 'name': name, 'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
        'paymentStatusThisMonth': 'pending',
        'creditScore': creditScore, 'totalContributed': 0,
      },
    );

    // Update group memberUids + count
    batch.update(_db.collection(FirebaseKeys.groups).doc(groupId), {
      'memberUids': FieldValue.arrayUnion([uid]),
      'currentMembers': FieldValue.increment(1),
    });

    await batch.commit();

    // Notify foreman
    final groupDoc = await _db.collection(FirebaseKeys.groups).doc(groupId).get();
    final foremanUid = groupDoc.data()?['foremanUid'] ?? '';
    final groupName = groupDoc.data()?['groupName'] ?? '';
    if (foremanUid.isNotEmpty && foremanUid != uid) {
      await sendNotification(
        toUid: foremanUid,
        title: '👥 New Member Joined',
        message: '$name joined $groupName',
        type: 'group',
        relatedId: groupId,
        actionRoute: '/groups/$groupId',
      );
    }
  }

  static Future<void> removeMember(String groupId, String memberUid) async {
    final batch = _db.batch();
    batch.delete(_db.collection(FirebaseKeys.groups).doc(groupId)
        .collection(FirebaseKeys.members).doc(memberUid));
    batch.update(_db.collection(FirebaseKeys.groups).doc(groupId), {
      'memberUids': FieldValue.arrayRemove([memberUid]),
      'currentMembers': FieldValue.increment(-1),
    });
    await batch.commit();
    await sendNotification(
      toUid: memberUid,
      title: '⚠️ Removed from Group',
      message: 'You have been removed from the group.',
      type: 'group',
      relatedId: groupId,
      actionRoute: '/groups',
    );
  }

  static Future<void> updateGroupStatus(String groupId, String status) async {
    await _db.collection(FirebaseKeys.groups).doc(groupId).update({'status': status});
    if (status == 'terminated') {
      final members = await _db.collection(FirebaseKeys.groups).doc(groupId)
          .collection(FirebaseKeys.members).get();
      final batch = _db.batch();
      for (final m in members.docs) {
        final nRef = _db.collection(FirebaseKeys.notifications).doc();
        batch.set(nRef, {
          'toUid': m.id, 'fromUid': 'admin', 'type': 'group',
          'title': '🚫 Group Suspended',
          'message': 'Your group has been suspended by admin.',
          'isRead': false, 'relatedId': groupId, 'relatedType': 'group',
          'actionRoute': '/groups', 'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
    await _logAdminAction(groupId, status == 'terminated' ? 'suspend_group' : 'activate_group', 'group');
  }

  // ── CONTRIBUTION OPERATIONS ────────────────────────────────────────────────

  static Stream<List<ContributionModel>> userContributionsStream(String uid) {
    return _db.collection(FirebaseKeys.contributions)
        .where('userId', isEqualTo: uid)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ContributionModel.fromDoc).toList());
  }

  static Stream<List<ContributionModel>> groupContributionsStream(String groupId) {
    return _db.collection(FirebaseKeys.contributions)
        .where('groupId', isEqualTo: groupId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ContributionModel.fromDoc).toList());
  }

  static Stream<List<ContributionModel>> allContributionsStream() {
    return _db.collection(FirebaseKeys.contributions)
        .orderBy('paymentDate', descending: true)
        .limit(200)
        .snapshots()
        .map((s) => s.docs.map(ContributionModel.fromDoc).toList());
  }

  static Future<Map<String, dynamic>> makePayment({
    required String groupId,
    required String groupName,
    required double amount,
    required int cycleNumber,
    required String method,
  }) async {
    final uid = currentUid;
    final userDoc = await _db.collection(FirebaseKeys.users).doc(uid).get();
    final name = userDoc.data()?['name'] ?? 'Member';
    final txnId = AppUtils.generateTxnId();
    final now = DateTime.now();

    final batch = _db.batch();

    // Create contribution record
    batch.set(_db.collection(FirebaseKeys.contributions).doc(txnId), {
      'contributionId': txnId, 'groupId': groupId, 'userId': uid,
      'userName': name, 'groupName': groupName, 'amount': amount,
      'cycleNumber': cycleNumber, 'month': now.month, 'year': now.year,
      'paymentDate': FieldValue.serverTimestamp(),
      'paymentMethod': method, 'transactionId': txnId,
      'status': 'success', 'failureReason': '',
    });

    // Update member payment status
    batch.update(
      _db.collection(FirebaseKeys.groups).doc(groupId).collection(FirebaseKeys.members).doc(uid),
      {'paymentStatusThisMonth': 'paid', 'totalContributed': FieldValue.increment(amount)},
    );

    // Update credit score +3
    batch.update(_db.collection(FirebaseKeys.users).doc(uid), {
      'creditScore': FieldValue.increment(3),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Notify foreman
    final groupDoc = await _db.collection(FirebaseKeys.groups).doc(groupId).get();
    final foremanUid = groupDoc.data()?['foremanUid'] ?? '';
    if (foremanUid.isNotEmpty) {
      await sendNotification(
        toUid: foremanUid,
        title: '💰 Payment Received',
        message: '$name paid ${AppUtils.formatCurrency(amount)} for $groupName',
        type: 'payment',
        relatedId: txnId,
        actionRoute: '/groups/$groupId',
      );
    }

    return {'txnId': txnId, 'amount': amount, 'groupName': groupName, 'method': method, 'date': now};
  }

  // ── AUCTION OPERATIONS ─────────────────────────────────────────────────────

  static Stream<List<AuctionModel>> groupAuctionsStream(String groupId) {
    return _db.collection(FirebaseKeys.auctions)
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AuctionModel.fromDoc).toList());
  }

  static Stream<AuctionModel?> auctionStream(String auctionId) {
    return _db.collection(FirebaseKeys.auctions).doc(auctionId).snapshots()
        .map((d) => d.exists ? AuctionModel.fromDoc(d) : null);
  }

  static Stream<List<AuctionModel>> activeAuctionsStream() {
    return _db.collection(FirebaseKeys.auctions)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((s) => s.docs.map(AuctionModel.fromDoc).toList());
  }

  static Future<String> openAuction(String groupId) async {
    final groupDoc = await _db.collection(FirebaseKeys.groups).doc(groupId).get();
    final group = GroupModel.fromDoc(groupDoc);
    final ref = _db.collection(FirebaseKeys.auctions).doc();
    final now = DateTime.now();

    await ref.set({
      'auctionId': ref.id, 'groupId': groupId, 'groupName': group.groupName,
      'cycleNumber': group.currentCycle, 'auctionType': group.fundType,
      'startTime': Timestamp.fromDate(now),
      'endTime': Timestamp.fromDate(now.add(Duration(hours: group.auctionWindowHours))),
      'totalFund': group.totalFund,
      'winnerUid': '', 'winnerName': '', 'winningBid': 0,
      'status': 'active', 'escrowStatus': 'held',
      'lotteryParticipants': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify all group members
    final members = await _db.collection(FirebaseKeys.groups).doc(groupId)
        .collection(FirebaseKeys.members).get();
    final batch = _db.batch();
    for (final m in members.docs) {
      final nRef = _db.collection(FirebaseKeys.notifications).doc();
      batch.set(nRef, {
        'toUid': m.id, 'fromUid': 'system', 'type': 'auction',
        'title': '🔨 Auction Started!',
        'message': 'Cycle ${group.currentCycle} auction for ${group.groupName} is now live!',
        'isRead': false, 'relatedId': ref.id, 'relatedType': 'auction',
        'actionRoute': '/auction/${ref.id}',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return ref.id;
  }

  // ── PAYOUT OPERATIONS ──────────────────────────────────────────────────────

  static Stream<List<PayoutModel>> groupPayoutsStream(String groupId) {
    return _db.collection(FirebaseKeys.payouts)
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PayoutModel.fromDoc).toList());
  }

  static Stream<PayoutModel?> payoutStream(String payoutId) {
    return _db.collection(FirebaseKeys.payouts).doc(payoutId).snapshots()
        .map((d) => d.exists ? PayoutModel.fromDoc(d) : null);
  }

  static Future<void> confirmPayout(String payoutId) async {
    await _db.collection(FirebaseKeys.payouts).doc(payoutId).update({
      'escrowStatus': 'released', 'status': 'completed',
      'confirmedByForeman': true,
      'foremanConfirmedAt': FieldValue.serverTimestamp(),
      'payoutDate': FieldValue.serverTimestamp(),
    });
    final doc = await _db.collection(FirebaseKeys.payouts).doc(payoutId).get();
    final winnerUid = doc.data()?['winnerUid'] ?? '';
    final netPayout = (doc.data()?['netPayout'] as num?)?.toDouble() ?? 0;
    final groupName = doc.data()?['groupName'] ?? '';
    if (winnerUid.isNotEmpty) {
      await sendNotification(
        toUid: winnerUid,
        title: '🎉 Payout Released!',
        message: '${AppUtils.formatCurrency(netPayout)} transferred to your bank from $groupName!',
        type: 'payment',
        relatedId: payoutId,
        actionRoute: '/escrow/$payoutId',
      );
    }
    await _logAdminAction(payoutId, 'confirm_payout', 'payout');
  }

  // ── NOTIFICATION OPERATIONS ────────────────────────────────────────────────

  static Stream<List<NotificationModel>> notificationsStream(String uid) {
    return _db.collection(FirebaseKeys.notifications)
        .where('toUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(NotificationModel.fromDoc).toList());
  }

  static Stream<int> unreadCountStream(String uid) {
    return _db.collection(FirebaseKeys.notifications)
        .where('toUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  static Future<void> sendNotification({
    required String toUid,
    required String title,
    required String message,
    String type = 'system',
    String relatedId = '',
    String relatedType = '',
    String actionRoute = '',
  }) async {
    await _db.collection(FirebaseKeys.notifications).add({
      'toUid': toUid,
      'fromUid': currentUid.isEmpty ? 'system' : currentUid,
      'type': type, 'title': title, 'message': message,
      'isRead': false, 'relatedId': relatedId,
      'relatedType': relatedType.isEmpty ? type : relatedType,
      'actionRoute': actionRoute,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> notifyAllUsers({
    required String title,
    required String message,
    String type = 'system',
    String relatedId = '',
    String actionRoute = '',
  }) async {
    final users = await _db.collection(FirebaseKeys.users)
        .where('accountStatus', isEqualTo: 'active').get();
    final batch = _db.batch();
    for (final u in users.docs) {
      final role = u.data()['role'] ?? 'member';
      if (role == 'super_admin' || role == 'admin') continue;
      final nRef = _db.collection(FirebaseKeys.notifications).doc();
      batch.set(nRef, {
        'toUid': u.id, 'fromUid': currentUid.isEmpty ? 'system' : currentUid,
        'type': type, 'title': title, 'message': message,
        'isRead': false, 'relatedId': relatedId,
        'relatedType': type, 'actionRoute': actionRoute,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Future<void> markNotificationRead(String notifId) async {
    await _db.collection(FirebaseKeys.notifications).doc(notifId).update({'isRead': true});
  }

  static Future<void> markAllNotificationsRead(String uid) async {
    final snap = await _db.collection(FirebaseKeys.notifications)
        .where('toUid', isEqualTo: uid).where('isRead', isEqualTo: false).get();
    final batch = _db.batch();
    for (final d in snap.docs) batch.update(d.reference, {'isRead': true});
    await batch.commit();
  }

  // ── MESSAGE OPERATIONS ─────────────────────────────────────────────────────

  static Stream<List<MessageModel>> messagesStream(String conversationId) {
    return _db.collection(FirebaseKeys.messages)
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(MessageModel.fromDoc).toList());
  }

  static Future<void> sendMessage({
    required String conversationId,
    required String toUid,
    required String message,
  }) async {
    final uid = currentUid;
    final userDoc = await _db.collection(FirebaseKeys.users).doc(uid).get();
    final name = userDoc.data()?['name'] ?? 'User';
    final role = userDoc.data()?['role'] ?? 'member';
    final ref = _db.collection(FirebaseKeys.messages).doc();
    await ref.set({
      'messageId': ref.id, 'conversationId': conversationId,
      'fromUid': uid, 'fromName': name, 'fromRole': role,
      'toUid': toUid, 'message': message,
      'isRead': false, 'attachmentUrl': '',
      'sentAt': FieldValue.serverTimestamp(),
    });
    await sendNotification(
      toUid: toUid,
      title: '💬 Message from $name',
      message: message,
      type: 'chat',
      relatedId: conversationId,
      actionRoute: '/chat/$conversationId',
    );
  }

  // ── FRAUD ALERT OPERATIONS ─────────────────────────────────────────────────

  static Stream<List<FraudAlertModel>> fraudAlertsStream() {
    return _db.collection(FirebaseKeys.fraudAlerts)
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FraudAlertModel.fromDoc).toList());
  }

  static Future<void> updateFraudAlert(String alertId, String status, {String notes = ''}) async {
    await _db.collection(FirebaseKeys.fraudAlerts).doc(alertId).update({
      'status': status,
      if (status == 'resolved') 'resolvedAt': FieldValue.serverTimestamp(),
      if (notes.isNotEmpty) 'resolutionNotes': notes,
      'resolvedByUid': currentUid,
    });
    await _logAdminAction(alertId, 'update_fraud_alert_$status', 'fraud_alert');
  }

  // ── PLATFORM SETTINGS ──────────────────────────────────────────────────────

  static Stream<Map<String, dynamic>> settingsStream() {
    return _db.collection(FirebaseKeys.settings).doc('platform').snapshots()
        .map((d) => d.data() ?? <String, dynamic>{});
  }

  static Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _db.collection(FirebaseKeys.settings).doc('platform').update(settings);
    await _logAdminAction('platform', 'update_settings', 'settings');
  }

  // ── ADMIN ACTIONS LOG ──────────────────────────────────────────────────────

  static Future<void> _logAdminAction(String targetId, String actionType, String targetType) async {
    final uid = currentUid;
    if (uid.isEmpty) return;
    try {
      final userDoc = await _db.collection(FirebaseKeys.users).doc(uid).get();
      final name = userDoc.data()?['name'] ?? 'Admin';
      await _db.collection(FirebaseKeys.adminActionsLog).add({
        'adminUid': uid, 'adminName': name,
        'actionType': actionType, 'targetId': targetId,
        'targetType': targetType, 'notes': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Stream<List<Map<String, dynamic>>> adminActionsLogStream() {
    return _db.collection(FirebaseKeys.adminActionsLog)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['logId'] = d.id;
              return data;
            }).toList());
  }
}
