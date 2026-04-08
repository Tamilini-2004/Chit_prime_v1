import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/group_model.dart';
import '../../../data/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

// All public groups — real-time
final allPublicGroupsProvider = StreamProvider<List<GroupModel>>(
    (ref) => FirebaseService.publicGroupsStream());

// My groups — real-time, updates when user joins
final myGroupsProvider = StreamProvider<List<GroupModel>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseService.myGroupsStream(uid);
});

// Single group — real-time
final groupProvider = StreamProvider.family<GroupModel?, String>(
    (ref, id) => FirebaseService.groupStream(id));

// Group members — real-time
final groupMembersProvider = StreamProvider.family<List<MemberModel>, String>(
    (ref, groupId) => FirebaseService.groupMembersStream(groupId));

// All groups for admin — real-time
final allGroupsProvider = StreamProvider<List<GroupModel>>(
    (ref) => FirebaseService.allGroupsStream());

final groupsNotifierProvider =
    AsyncNotifierProvider<GroupsNotifier, void>(GroupsNotifier.new);

class GroupsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String> createGroup({
    required String name,
    required double contribution,
    required int members,
    required int duration,
    String fundType = 'auction',
    String privacy = 'public',
  }) =>
      FirebaseService.createGroup(
        name: name, contribution: contribution,
        members: members, duration: duration,
        fundType: fundType, privacy: privacy,
      );

  Future<void> joinGroup(String groupId) =>
      FirebaseService.joinGroup(groupId);

  Future<void> removeMember(String groupId, String memberUid) =>
      FirebaseService.removeMember(groupId, memberUid);

  Future<void> suspendGroup(String groupId) =>
      FirebaseService.updateGroupStatus(groupId, 'terminated');

  Future<void> reactivateGroup(String groupId) =>
      FirebaseService.updateGroupStatus(groupId, 'active');
}
