import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoucherController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var todayCount = 0.obs;
  var redeemedCount = 0.obs;
  var redeemableCount = 0.obs;
  var vouchers = <VoucherModel>[].obs;
  var redeemableVouchers = <VoucherModel>[].obs;

  Future<void> loadOverview(String memberCode) async {
    final response = await _api.get(endPoint: "get-voucher-overview", module: "VoucherController - loadOverview", data: {"member_code": memberCode});

    if (response == null) return;

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data["collectables"] ?? [];

      todayCount.value = response.data["today_count"];
      redeemedCount.value = response.data["redeemed_count"];
      redeemableCount.value = response.data["redeemable_count"];
      vouchers.value = list.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
  }

  Future<void> loadVouchers(String memberCode, {int checkStart = 0, int checkToday = 0, String? companyID}) async {
    isLoading.value = true;

    final Map<String, dynamic> data = {"check_start": checkStart, "check_today": checkToday, "member_code": memberCode, "company_id": companyID};
    final response = await _api.get(endPoint: "get-all-voucher", module: "VoucherController - loadVouchers", data: data);

    if (response == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> normalList = response.data[VoucherModel.keyNormalVoucher] ?? [];
      final List<dynamic> specialList = response.data[VoucherModel.keySpecialVoucher] ?? [];
      final List<dynamic> redeemableList = response.data["redeemable_voucher"] ?? [];

      vouchers.value = [
        ...normalList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))),
        ...specialList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))),
      ];
      redeemableVouchers.value = redeemableList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    isLoading.value = false;
  }

  Future<void> collectVoucher(String batchCode, String companyID, String memberCode, String memberToken) async {
    final Map<String, dynamic> data = {"batch_code": batchCode, "company_id": companyID, "member_code": memberCode};
    final response = await _api.post(endPoint: "collect-voucher", module: "VoucherController - collectVoucher", data: data, memberToken: memberToken);

    if (response == null) {
      _showError("msg_system_error".tr);
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      loadOverview(memberCode);
      _showSuccess("msg_voucher_collect_success".tr);
    } else if (response.data[ApiService.keyStatusCode] == 401) {
      _showError("msg_member_expired".tr);
    } else if (response.data[ApiService.keyStatusCode] == 403) {
      _showError("msg_voucher_all_collected".tr);
    } else if (response.data[ApiService.keyStatusCode] == 404) {
      _showError("msg_voucher_collected_before".tr);
    } else if (response.data[ApiService.keyStatusCode] == 520) {
      _showError("msg_token_invalid".tr);
    } else {
      _showError("msg_system_error".tr);
    }
  }

  Future<void> redeemVoucher(String batchCode, String companyID, String memberCode, String memberToken) async {
    final Map<String, dynamic> data = {"batch_code": batchCode, "company_id": companyID, "member_code": memberCode};
    final response = await _api.post(endPoint: "redeem-voucher", module: "VoucherController - redeemVoucher", data: data, memberToken: memberToken);

    if (response == null) {
      _showError("msg_system_error".tr);
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      loadVouchers(memberCode, checkToday: 1);
      _showSuccess("msg_voucher_collect_success".tr);
    } else if (response.data[ApiService.keyStatusCode] == 401) {
      _showError("msg_member_expired".tr);
    } else if (response.data[ApiService.keyStatusCode] == 403) {
      _showError("msg_voucher_all_collected".tr);
    } else if (response.data[ApiService.keyStatusCode] == 404) {
      _showError("msg_voucher_collected_before".tr);
    } else if (response.data[ApiService.keyStatusCode] == 405) {
      _showError("msg_point_not_enough".tr);
    } else if (response.data[ApiService.keyStatusCode] == 520) {
      _showError("msg_token_invalid".tr);
    } else {
      _showError("msg_system_error".tr);
    }
  }

  void _showError(String message) {
    MessageHelper.show(message, backgroundColor: Colors.red, icon: Icons.error_rounded);
  }

  void _showSuccess(String message) {
    MessageHelper.show(message, backgroundColor: Colors.green, icon: Icons.check_circle_rounded);
  }
}
