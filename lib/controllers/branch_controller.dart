import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/models/branch_model.dart';
import 'package:ezymember/services/remote/api_service.dart';
import 'package:get/get.dart';

class BranchController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var branches = <BranchModel>[].obs;

  Future<void> loadBranches({String? companyID}) async {
    isLoading.value = true;

    final response = await _api.get(
      baseUrl: "${AppStrings.serverEzyPos}/${AppStrings.serverDirectory}",
      endPoint: "get-branch-list",
      module: "BranchController - loadBranches",
      data: {"company_id": companyID},
    );

    if (response == null || response.data[BranchModel.keyBranch] == null) {
      isLoading.value = false;
      return;
    }

    final List<dynamic> list = response.data[BranchModel.keyBranch] ?? [];

    branches.value = list.map((e) => BranchModel.fromJson(Map<String, dynamic>.from(e))).toList();
    isLoading.value = false;
  }
}
