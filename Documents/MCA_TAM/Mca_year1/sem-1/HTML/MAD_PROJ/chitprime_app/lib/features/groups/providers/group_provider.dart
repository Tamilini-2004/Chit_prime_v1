import 'package:flutter/material.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _repo;
  List<GroupModel> _myGroups = [];
  List<GroupModel> _discoverGroups = [];
  GroupModel? _selectedGroup;
  List<GroupMemberModel> _members = [];
  bool _isLoading = false;
  String? _error;

  GroupProvider(this._repo);

  List<GroupModel> get myGroups => _myGroups;
  List<GroupModel> get discoverGroups => _discoverGroups;
  GroupModel? get selectedGroup => _selectedGroup;
  List<GroupMemberModel> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyGroups(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myGroups = await _repo.getUserGroups(userId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDiscoverGroups() async {
    _isLoading = true;
    notifyListeners();
    try {
      _discoverGroups = await _repo.getDiscoverGroups();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadGroupDetail(String groupId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedGroup = await _repo.getGroupById(groupId);
      _members = await _repo.getGroupMembers(groupId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createGroup(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final group = await _repo.createGroup(data);
      _myGroups.insert(0, group);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinGroup(String groupId, String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repo.joinGroup(groupId, userId);
      if (success) {
        await loadMyGroups(userId);
        await loadDiscoverGroups();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
