import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/helpers/location_helper.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/company_model.dart';
import 'package:ezymember/services/local/connection_service.dart';
import 'package:ezymember/services/remote/api_service.dart';
import 'package:get/get.dart';

class CompanyController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var company = CompanyModel.empty().obs;
  var companies = <CompanyModel>[].obs;

  Future<void> loadCompany(String companyID) async {
    isLoading.value = true;

    final responsePOS = await _api.get(
      baseUrl: "${AppStrings.serverEzyPos}/${AppStrings.serverDirectory}",
      endPoint: "get-company-information/$companyID",
      module: "CompanyController - loadCompany",
    );

    if (responsePOS == null) return;

    if (responsePOS.data[ApiService.keyStatusCode] == 200) {
      final response = await _api.get(endPoint: "get-company", module: "CompanyController - loadCompany", data: {"company_id": companyID});

      if (response == null) return;

      if (response.data[ApiService.keyStatusCode] == 200) {
        company.value = CompanyModel.fromJson(responsePOS.data["company_info"], response.data[CompanyModel.keyCompany] ?? {});
      }
    }

    isLoading.value = false;
  }

  Future<void> loadCompanies({bool isLocation = false, String? category, String? search}) async {
    isLoading.value = true;

    final Coordinate? c = isLocation ? await LocationHelper.getCurrentCoordinate() : null;

    final responsePOS = await _api.get(
      baseUrl: "${AppStrings.serverEzyPos}/${AppStrings.serverDirectory}",
      endPoint: "get-company-list",
      module: "CompanyController - loadCompanies",
      data: {if (category != null) "business_category": category, if (c != null) "city": c.city, if (search != null) "search": search},
    );

    if (responsePOS == null || responsePOS.data["company_list"] == null) {
      isLoading.value = false;
      return;
    }

    final List<dynamic> list = responsePOS.data["company_list"] ?? [];

    companies.value = list.map((e) => CompanyModel.fromJson(Map<String, dynamic>.from(e), {})).toList();
    isLoading.value = false;
  }

  Future<bool> registerMember(String companyID, String memberCode, String referralCode) async {
    if (!await ConnectionService.checkConnection()) return false;

    _showLoading(Globalization.msgMemberRegisterProcessing.tr);

    final Map<String, dynamic> data = {"company_id": companyID, "member_code": memberCode, "referral_code": referralCode};
    final response = await _api.post(endPoint: "register-member", module: "CompanyController - registerMember", data: data);

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return false;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      _showSuccess(Globalization.msgMemberRegisterSuccess.tr);
      return true;
    } else {
      _showError(Globalization.msgSystemError.tr);
      return false;
    }
  }

  void _showLoading(String message) {
    MessageHelper.loading(message: message);
  }

  void _hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void _showError(String message) {
    MessageHelper.error(message: message);
  }

  void _showSuccess(String message) {
    MessageHelper.success(message: message);
  }
}
