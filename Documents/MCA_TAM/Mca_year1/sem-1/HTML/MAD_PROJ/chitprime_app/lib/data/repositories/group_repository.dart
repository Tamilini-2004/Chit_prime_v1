import '../models/group_model.dart';

class GroupRepository {
  final List<GroupModel> _mockGroups = [
    GroupModel(
      groupId: 'grp_001',
      groupName: 'Retailers Gold Circle',
      adminUserId: 'user_001',
      totalMembers: 20,
      currentMembers: 15,
      monthlyContribution: 5000,
      cycleDuration: 20,
      currentCycle: 8,
      startDate: DateTime(2024, 1, 1),
      status: 'active',
      totalFund: 100000,
      nextAuctionDate: DateTime.now().add(const Duration(days: 5)),
      minCreditScore: 600,
      description: 'Premium chit fund for established retailers',
      isPublic: true,
      createdAt: DateTime(2024, 1, 1),
    ),
    GroupModel(
      groupId: 'grp_002',
      groupName: 'Small Business Fund',
      adminUserId: 'user_002',
      totalMembers: 15,
      currentMembers: 12,
      monthlyContribution: 3000,
      cycleDuration: 15,
      currentCycle: 5,
      startDate: DateTime(2024, 3, 1),
      status: 'active',
      totalFund: 45000,
      nextAuctionDate: DateTime.now().add(const Duration(days: 12)),
      minCreditScore: 500,
      description: 'Affordable chit fund for small businesses',
      isPublic: true,
      createdAt: DateTime(2024, 3, 1),
    ),
    GroupModel(
      groupId: 'grp_003',
      groupName: 'Premium Traders Club',
      adminUserId: 'user_003',
      totalMembers: 30,
      currentMembers: 28,
      monthlyContribution: 10000,
      cycleDuration: 30,
      currentCycle: 12,
      startDate: DateTime(2023, 10, 1),
      status: 'active',
      totalFund: 300000,
      nextAuctionDate: DateTime.now().add(const Duration(days: 3)),
      minCreditScore: 700,
      description: 'High-value chit fund for premium traders',
      isPublic: false,
      createdAt: DateTime(2023, 10, 1),
    ),
    GroupModel(
      groupId: 'grp_004',
      groupName: 'Kirana Store Network',
      adminUserId: 'user_004',
      totalMembers: 10,
      currentMembers: 6,
      monthlyContribution: 2000,
      cycleDuration: 10,
      currentCycle: 2,
      startDate: DateTime(2024, 5, 1),
      status: 'active',
      totalFund: 20000,
      nextAuctionDate: DateTime.now().add(const Duration(days: 20)),
      minCreditScore: 400,
      description: 'Chit fund for kirana store owners',
      isPublic: true,
      createdAt: DateTime(2024, 5, 1),
    ),
  ];

  final List<GroupMemberModel> _mockMembers = [
    GroupMemberModel(
      memberId: 'mem_001',
      groupId: 'grp_001',
      userId: 'user_001',
      userName: 'Rajesh Kumar',
      creditScore: 820,
      joinDate: DateTime(2024, 1, 1),
      paymentStatus: 'paid',
      isAdmin: true,
      isWinner: false,
    ),
    GroupMemberModel(
      memberId: 'mem_002',
      groupId: 'grp_001',
      userId: 'user_005',
      userName: 'Priya Sharma',
      creditScore: 750,
      joinDate: DateTime(2024, 1, 5),
      paymentStatus: 'paid',
      isAdmin: false,
      isWinner: true,
    ),
    GroupMemberModel(
      memberId: 'mem_003',
      groupId: 'grp_001',
      userId: 'user_006',
      userName: 'Amit Patel',
      creditScore: 680,
      joinDate: DateTime(2024, 1, 8),
      paymentStatus: 'pending',
      isAdmin: false,
      isWinner: false,
    ),
    GroupMemberModel(
      memberId: 'mem_004',
      groupId: 'grp_001',
      userId: 'user_007',
      userName: 'Sunita Devi',
      creditScore: 720,
      joinDate: DateTime(2024, 1, 10),
      paymentStatus: 'paid',
      isAdmin: false,
      isWinner: false,
    ),
    GroupMemberModel(
      memberId: 'mem_005',
      groupId: 'grp_001',
      userId: 'user_008',
      userName: 'Mohan Lal',
      creditScore: 640,
      joinDate: DateTime(2024, 1, 12),
      paymentStatus: 'paid',
      isAdmin: false,
      isWinner: false,
    ),
  ];

  Future<List<GroupModel>> getUserGroups(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockGroups.take(2).toList();
  }

  Future<List<GroupModel>> getDiscoverGroups() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockGroups.skip(2).toList();
  }

  Future<GroupModel?> getGroupById(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockGroups.firstWhere((g) => g.groupId == groupId);
    } catch (_) {
      return null;
    }
  }

  Future<List<GroupMemberModel>> getGroupMembers(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockMembers.where((m) => m.groupId == groupId).toList();
  }

  Future<GroupModel> createGroup(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final group = GroupModel(
      groupId: 'grp_${DateTime.now().millisecondsSinceEpoch}',
      groupName: data['groupName'] ?? '',
      adminUserId: data['adminUserId'] ?? '',
      totalMembers: data['totalMembers'] ?? 10,
      currentMembers: 1,
      monthlyContribution: (data['monthlyContribution'] ?? 0).toDouble(),
      cycleDuration: data['cycleDuration'] ?? 12,
      currentCycle: 1,
      startDate: data['startDate'] ?? DateTime.now(),
      status: 'active',
      totalFund: 0,
      minCreditScore: data['minCreditScore'] ?? 0,
      description: data['description'],
      isPublic: data['isPublic'] ?? true,
      createdAt: DateTime.now(),
    );
    _mockGroups.add(group);
    return group;
  }

  Future<bool> joinGroup(String groupId, String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<List<GroupModel>> getAllGroups() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockGroups;
  }
}
