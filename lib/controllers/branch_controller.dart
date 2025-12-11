import 'package:ezy_member_v2/helpers/location_helper.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class BranchController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var branches = <BranchModel>[].obs;

  Future<void> loadBranches(bool checkNearby) async {
    isLoading.value = true;
    branches.clear();

    Map<String, dynamic>? data;

    if (checkNearby) {
      final Coordinate? current = await LocationHelper.getCurrentCoordinate();

      if (current != null) data = {"latitude": current.latitude, "longitude": current.longitude};
    }

    final response = await _api.get(endPoint: "get-all-branch", module: "BranchController - loadBranches", data: data);

    if (response == null || response.data[BranchModel.keyBranch] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[BranchModel.keyBranch];

      branches.addAll(list.map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
  }
}
