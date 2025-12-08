import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class MemberController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var members = <MemberModel>[].obs;
  var membersCheckStart = <MemberModel>[].obs;

  Future<List<MemberModel>> _fetchMembers(String memberCode, int checkStart) async {
    isLoading.value = true;
    final List<MemberModel> tmpMembers = [];

    final Map<String, dynamic> data = {"member_code": memberCode, "check_start": checkStart};

    final response = await _api.get(endPoint: "get-member-detail", data: data, module: "MemberController - loadMembers");

    if (response == null || response.data[MemberModel.keyMember] == null) {
      isLoading.value = false;
      return [];
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[MemberModel.keyMember];
      tmpMembers.addAll(list.map((e) => MemberModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
    return tmpMembers;
  }

  Future<void> loadMembers(String memberCode) async {
    members.value = await _fetchMembers(memberCode, 0);
  }

  Future<void> loadMembersCheckStart(String memberCode) async {
    membersCheckStart.value = await _fetchMembers(memberCode, 1);
  }
}
