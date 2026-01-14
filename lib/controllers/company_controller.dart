import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:flutter/material.dart';
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

  Future<bool> registerMember(String companyID, String memberCode, String referralCode) async {
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
    MessageHelper.showDialog(type: DialogType.loading, message: message, title: Globalization.processing.tr);
  }

  void _hideLoading() {
    if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();
  }

  void _showError(String message) {
    MessageHelper.show(message, backgroundColor: Colors.red, icon: Icons.error_rounded);
  }

  void _showSuccess(String message) {
    MessageHelper.show(message, backgroundColor: Colors.green, icon: Icons.check_circle_rounded);
  }
}
