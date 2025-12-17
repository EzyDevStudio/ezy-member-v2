import 'package:ezy_member_v2/helpers/location_helper.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class MemberController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var members = <MemberModel>[].obs;

  Future<void> loadMembers(String memberCode, {bool getBranch = false}) async {
    isLoading.value = true;

    final Coordinate? c = getBranch ? await LocationHelper.getCurrentCoordinate() : null;
    final Map<String, dynamic> data = {"member_code": memberCode, if (c != null) "latitude": c.latitude, if (c != null) "longitude": c.longitude};
    final response = await _api.get(endPoint: "get-member-detail", module: "MemberController - loadMembers", data: data);

    if (response == null || response.data[MemberModel.keyMember] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[MemberModel.keyMember] ?? [];

      members.value = list.map((e) => MemberModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    isLoading.value = false;
  }
}
