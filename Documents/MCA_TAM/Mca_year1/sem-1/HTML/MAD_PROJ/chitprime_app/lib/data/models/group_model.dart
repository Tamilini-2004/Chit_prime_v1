class GroupModel {
  final String groupId;
  final String groupName;
  final String adminUserId;
  final int totalMembers;
  final int currentMembers;
  final double monthlyContribution;
  final int cycleDuration;
  final int currentCycle;
  final DateTime startDate;
  final String status;
  final double totalFund;
  final DateTime? nextAuctionDate;
  final int minCreditScore;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;

  const GroupModel({
    required this.groupId,
    required this.groupName,
    required this.adminUserId,
    required this.totalMembers,
    required this.currentMembers,
    required this.monthlyContribution,
    required this.cycleDuration,
    required this.currentCycle,
    required this.startDate,
    required this.status,
    required this.totalFund,
    this.nextAuctionDate,
    this.minCreditScore = 0,
    this.description,
    this.isPublic = true,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        groupId: json['group_id'] ?? '',
        groupName: json['group_name'] ?? '',
        adminUserId: json['admin_user_id'] ?? '',
        totalMembers: json['total_members'] ?? 0,
        currentMembers: json['current_members'] ?? 0,
        monthlyContribution:
            (json['monthly_contribution'] ?? 0).toDouble(),
        cycleDuration: json['cycle_duration'] ?? 12,
        currentCycle: json['current_cycle'] ?? 1,
        startDate: DateTime.parse(
            json['start_date'] ?? DateTime.now().toIso8601String()),
        status: json['status'] ?? 'active',
        totalFund: (json['total_fund'] ?? 0).toDouble(),
        nextAuctionDate: json['next_auction_date'] != null
            ? DateTime.parse(json['next_auction_date'])
            : null,
        minCreditScore: json['min_credit_score'] ?? 0,
        description: json['description'],
        isPublic: json['is_public'] ?? true,
        createdAt: DateTime.parse(
            json['created_at'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'group_name': groupName,
        'admin_user_id': adminUserId,
        'total_members': totalMembers,
        'current_members': currentMembers,
        'monthly_contribution': monthlyContribution,
        'cycle_duration': cycleDuration,
        'current_cycle': currentCycle,
        'start_date': startDate.toIso8601String(),
        'status': status,
        'total_fund': totalFund,
        'next_auction_date': nextAuctionDate?.toIso8601String(),
        'min_credit_score': minCreditScore,
        'description': description,
        'is_public': isPublic,
        'created_at': createdAt.toIso8601String(),
      };

  double get progressPercent => currentCycle / cycleDuration;
  bool get isFull => currentMembers >= totalMembers;
}

class GroupMemberModel {
  final String memberId;
  final String groupId;
  final String userId;
  final String userName;
  final int creditScore;
  final DateTime joinDate;
  final String paymentStatus;
  final bool isAdmin;
  final bool isWinner;

  const GroupMemberModel({
    required this.memberId,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.creditScore,
    required this.joinDate,
    required this.paymentStatus,
    required this.isAdmin,
    required this.isWinner,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) =>
      GroupMemberModel(
        memberId: json['member_id'] ?? '',
        groupId: json['group_id'] ?? '',
        userId: json['user_id'] ?? '',
        userName: json['user_name'] ?? '',
        creditScore: json['credit_score'] ?? 0,
        joinDate: DateTime.parse(
            json['join_date'] ?? DateTime.now().toIso8601String()),
        paymentStatus: json['payment_status'] ?? 'pending',
        isAdmin: json['is_admin'] ?? false,
        isWinner: json['is_winner'] ?? false,
      );
}
