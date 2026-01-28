import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/category_model.dart';
import 'package:ezymember/models/company_model.dart';
import 'package:ezymember/models/member_model.dart';
import 'package:ezymember/services/local/connection_service.dart';
import 'package:ezymember/services/remote/api_service.dart';
import 'package:flutter/material.dart';
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

  Future<bool> favoriteMember(int isFavorite, String companyID, String memberCode, String memberToken) async {
    if (!await ConnectionService.checkConnection()) return false;

    final Map<String, dynamic> data = {"is_favorite": isFavorite, "company_id": companyID, "member_code": memberCode};
    final response = await _api.post(endPoint: "favorite-member", module: "MemberController - favoriteMember", data: data, memberToken: memberToken);

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return false;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        return true;
      case 520:
        _showError(Globalization.msgTokenInvalid.tr);
        return false;
      default:
        _showError(Globalization.msgSystemError.tr);
        return false;
    }
  }

  void _showError(String message) {
    MessageHelper.show(message, backgroundColor: Colors.red, icon: Icons.error_rounded);
  }
}
