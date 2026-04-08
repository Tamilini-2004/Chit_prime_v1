import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String groupCode;
  final String groupName;
  final String fundType;
  final String foremanUid;
  final String foremanName;
  final double monthlyContribution;
  final int totalMembers;
  final int currentMembers;
  final int cycleDuration;
  final int currentCycle;
  final DateTime startDate;
  final String status;
  final double totalFund;
  final double commissionRate;
  final double gstRate;
  final DateTime? nextAuctionDate;
  final int auctionWindowHours;
  final int minCreditScore;
  final String privacy;
  final List<String> memberUids;
  final DateTime createdAt;

  const GroupModel({
    required this.groupId,
    required this.groupCode,
    required this.groupName,
    this.fundType = 'auction',
    required this.foremanUid,
    this.foremanName = '',
    required this.monthlyContribution,
    required this.totalMembers,
    this.currentMembers = 1,
    this.cycleDuration = 12,
    this.currentCycle = 1,
    required this.startDate,
    this.status = 'active',
    this.commissionRate = 0.03,
    this.gstRate = 0.18,
    this.nextAuctionDate,
    this.auctionWindowHours = 24,
    this.minCreditScore = 0,
    this.privacy = 'public',
    this.memberUids = const [],
    required this.createdAt,
  }) : totalFund = monthlyContribution * totalMembers;

  factory GroupModel.fromJson(Map<String, dynamic> j) => GroupModel(
        groupId: j['groupId'] ?? '',
        groupCode: j['groupCode'] ?? '',
        groupName: j['groupName'] ?? '',
        fundType: j['fundType'] ?? 'auction',
        foremanUid: j['foremanUid'] ?? '',
        foremanName: j['foremanName'] ?? '',
        monthlyContribution:
            (j['monthlyContribution'] as num?)?.toDouble() ?? 0,
        totalMembers: (j['totalMembers'] as num?)?.toInt() ?? 10,
        currentMembers: (j['currentMembers'] as num?)?.toInt() ?? 1,
        cycleDuration: (j['cycleDuration'] as num?)?.toInt() ?? 12,
        currentCycle: (j['currentCycle'] as num?)?.toInt() ?? 1,
        startDate: (j['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: j['status'] ?? 'active',
        commissionRate: (j['commissionRate'] as num?)?.toDouble() ?? 0.03,
        gstRate: (j['gstRate'] as num?)?.toDouble() ?? 0.18,
        nextAuctionDate: (j['nextAuctionDate'] as Timestamp?)?.toDate(),
        auctionWindowHours:
            (j['auctionWindowHours'] as num?)?.toInt() ?? 24,
        minCreditScore: (j['minCreditScore'] as num?)?.toInt() ?? 0,
        privacy: j['privacy'] ?? 'public',
        memberUids: List<String>.from(j['memberUids'] ?? []),
        createdAt:
            (j['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  factory GroupModel.fromDoc(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    data['groupId'] = doc.id;
    return GroupModel.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'groupCode': groupCode,
        'groupName': groupName,
        'fundType': fundType,
        'foremanUid': foremanUid,
        'foremanName': foremanName,
        'monthlyContribution': monthlyContribution,
        'totalMembers': totalMembers,
        'currentMembers': currentMembers,
        'cycleDuration': cycleDuration,
        'currentCycle': currentCycle,
        'startDate': Timestamp.fromDate(startDate),
        'status': status,
        'totalFund': totalFund,
        'commissionRate': commissionRate,
        'gstRate': gstRate,
        'nextAuctionDate': nextAuctionDate != null
            ? Timestamp.fromDate(nextAuctionDate!)
            : null,
        'auctionWindowHours': auctionWindowHours,
        'minCreditScore': minCreditScore,
        'privacy': privacy,
        'memberUids': memberUids,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  double get progressPercent =>
      cycleDuration > 0 ? (currentCycle / cycleDuration).clamp(0.0, 1.0) : 0;
  bool get isFull => currentMembers >= totalMembers;
  bool get isActive =>
      status == 'active' || status == 'cycle_in_progress';
}

class MemberModel {
  final String uid;
  final String name;
  final String role;
  final DateTime joinedAt;
  final String paymentStatusThisMonth;
  final bool isPrizedSubscriber;
  final int creditScore;
  final double totalContributed;

  const MemberModel({
    required this.uid,
    required this.name,
    this.role = 'member',
    required this.joinedAt,
    this.paymentStatusThisMonth = 'pending',
    this.isPrizedSubscriber = false,
    this.creditScore = 650,
    this.totalContributed = 0,
  });

  factory MemberModel.fromDoc(DocumentSnapshot doc) {
    final j = doc.data() as Map<String, dynamic>;
    return MemberModel(
      uid: doc.id,
      name: j['name'] ?? '',
      role: j['role'] ?? 'member',
      joinedAt:
          (j['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentStatusThisMonth: j['paymentStatusThisMonth'] ?? 'pending',
      isPrizedSubscriber: j['isPrizedSubscriber'] ?? false,
      creditScore: (j['creditScore'] as num?)?.toInt() ?? 650,
      totalContributed:
          (j['totalContributed'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'role': role,
        'joinedAt': Timestamp.fromDate(joinedAt),
        'paymentStatusThisMonth': paymentStatusThisMonth,
        'isPrizedSubscriber': isPrizedSubscriber,
        'creditScore': creditScore,
        'totalContributed': totalContributed,
      };
}
