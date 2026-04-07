import 'package:flutter/material.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';

class GroupManagementProvider extends ChangeNotifier {
  final GroupRepository _repo;
  List<GroupModel> _groups = [];
  bool isLoading = false;
  String _filterStatus = 'all';

  GroupManagementProvider(this._repo);

  List<GroupModel> get filteredGroups {
    if (_filterStatus == 'all') return _groups;
    return _groups.where((g) => g.status == _filterStatus).toList();
  }

  void setFilter(String filter) {
    _filterStatus = filter;
    notifyListeners();
  }

  Future<void> loadGroups() async {
    isLoading = true;
    notifyListeners();
    _groups = await _repo.getAllGroups();
    isLoading = false;
    notifyListeners();
  }

  Future<void> suspendGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _groups.indexWhere((g) => g.groupId == groupId);
    if (index != -1) {
      final g = _groups[index];
      _groups[index] = GroupModel(
        groupId: g.groupId, groupName: g.groupName, adminUserId: g.adminUserId,
        totalMembers: g.totalMembers, currentMembers: g.currentMembers,
        monthlyContribution: g.monthlyContribution, cycleDuration: g.cycleDuration,
        currentCycle: g.currentCycle, startDate: g.startDate, status: 'suspended',
        totalFund: g.totalFund, createdAt: g.createdAt,
      );
      notifyListeners();
    }
  }
}
