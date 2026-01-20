import 'package:ezy_member_v2/models/category_model.dart';
import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class MemberController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var categories = <CategoryModel>[].obs;
  var companies = <CompanyModel>[].obs;
  var members = <MemberModel>[].obs;

  Future<void> loadMembers(String memberCode, {String? companyID}) async {
    isLoading.value = true;

    final Map<String, dynamic> data = {"member_code": memberCode, if (companyID != null) "company_id": companyID};
    final response = await _api.get(endPoint: "get-member-detail", module: "MemberController - loadMembers", data: data);

    if (response == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> categoryList = response.data[CategoryModel.keyCategory] ?? [];
      final List<dynamic> companyList = response.data[CompanyModel.keyCompany] ?? [];
      final List<dynamic> memberList = response.data[MemberModel.keyMember] ?? [];

      categories.value = categoryList.map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e))).toList();
      companies.value = companyList.map((e) => CompanyModel.fromJson(Map<String, dynamic>.from(e))).toList();
      members.value = memberList.map((e) => MemberModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    isLoading.value = false;
  }
}
