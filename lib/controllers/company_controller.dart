import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class CompanyController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var company = Rx<CompanyModel?>(null);

  Future<void> loadCompany(String companyID) async {
    isLoading.value = true;

    final Map<String, dynamic> data = {"company_id": companyID};
    final response = await _api.get(endPoint: "get-company", module: "CompanyController - loadCompany", data: data);

    if (response == null || response.data[CompanyModel.keyCompany] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final json = Map<String, dynamic>.from(response.data[CompanyModel.keyCompany]);

      company.value = CompanyModel.fromJson(json);
    }

    isLoading.value = false;
  }

  Future<void> registerMember(String companyID, String memberCode) async {

  }
}
