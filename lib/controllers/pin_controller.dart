import 'dart:math';

import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/models/pin_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var pin = Rx<PinModel?>(null);

  Future<void> generatePin(String companyID, String memberCode, String memberToken, String? voucherCode) async {
    isLoading.value = true;

    final Map<String, dynamic> data = {"company_id": companyID, "member_code": memberCode, "pin": pinGenerator(), "voucher_code": voucherCode};
    final response = await _api.post(endPoint: "generate-pin", module: "PinController - generatePin", data: data, memberToken: memberToken);

    if (response == null || response.data[PinModel.keyPin] == null) {
      _showError("msg_system_error".tr);
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final json = Map<String, dynamic>.from(response.data[PinModel.keyPin]);

      pin.value = PinModel.fromJson(json);
    } else if (response.data[ApiService.keyStatusCode] == 520) {
      _showError("msg_token_invalid".tr);
    } else {
      _showError("msg_system_error".tr);
    }

    isLoading.value = false;
  }

  String pinGenerator({int length = 8}) {
    final random = Random();

    String pin = "";

    for (int i = 0; i < length; i++) {
      pin += random.nextInt(10).toString();
    }

    return pin;
  }

  void _showError(String message) {
    MessageHelper.show(message, backgroundColor: Colors.red, icon: Icons.error_rounded);
  }
}
