import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoucherController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var isSuccess = false.obs;
  var vouchers = <VoucherModel>[].obs;
  var collectableVouchers = <VoucherModel>[].obs;

  Future<List<VoucherModel>> _fetchVouchers(String memberCode, {bool collectable = false, int checkStart = 0, String? companyID}) async {
    isLoading.value = true;
    final List<VoucherModel> tmpVouchers = [];

    final Map<String, dynamic> data = {"member_code": memberCode, "company_id": companyID};

    if (!collectable) data["check_start"] = checkStart;

    final response = await _api.get(
      endPoint: collectable ? "get-all-collectable-voucher" : "get-all-voucher",
      module: "VoucherController - _fetchVouchers",
      data: data,
    );

    if (response == null) {
      isLoading.value = false;
      return [];
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> normalList = response.data["normal_voucher"] ?? [];
      final List<dynamic> specialList = response.data["special_voucher"] ?? [];

      tmpVouchers.addAll(normalList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))).toList());
      tmpVouchers.addAll(specialList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
    return tmpVouchers;
  }

  Future<void> loadVouchers(String memberCode, {int checkStart = 0, String? companyID}) async {
    vouchers.value = await _fetchVouchers(memberCode, checkStart: checkStart, companyID: companyID);
  }

  Future<void> loadCollectableVouchers(String memberCode) async {
    collectableVouchers.value = await _fetchVouchers(memberCode, collectable: true);
  }

  Future<void> collectVoucher(String batchCode, String companyID, String memberCode, String memberToken) async {
    isSuccess.value = false;

    final Map<String, dynamic> data = {"batch_code": batchCode, "company_id": companyID, "member_code": memberCode, "member_token": memberToken};
    final response = await _api.post(endPoint: "collect-voucher", module: "VoucherController - collectVoucher", data: data, memberToken: memberToken);

    if (response == null) {
      _showError(AppStrings.msgSystemFailed);
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      isSuccess.value = true;
      _showSuccess(AppStrings.msgCollectVoucherSuccess);
    } else if (response.data[ApiService.keyStatusCode] == 402) {
      _showError(AppStrings.msgAllVouchersCollected);
    } else if (response.data[ApiService.keyStatusCode] == 403) {
      _showError(AppStrings.msgCollectVoucherBefore);
    } else if (response.data[ApiService.keyStatusCode] == 520) {
      _showError(AppStrings.msgInvalidToken);
    } else {
      _showError(AppStrings.msgInvalidToken);
    }
  }

  void _showError(String message) {
    MessageHelper.show(message, backgroundColor: Colors.red, icon: Icons.error_rounded);
  }

  void _showSuccess(String message) {
    MessageHelper.show(message, backgroundColor: Colors.green, icon: Icons.check_circle_outline_rounded);
  }
}
