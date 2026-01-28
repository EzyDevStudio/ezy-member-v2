import 'dart:math';

import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/pin_model.dart';
import 'package:ezymember/services/remote/api_service.dart';
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
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final json = Map<String, dynamic>.from(response.data[PinModel.keyPin]);

      pin.value = PinModel.fromJson(json);
    } else if (response.data[ApiService.keyStatusCode] == 520) {
      _showError(Globalization.msgTokenInvalid.tr);
    } else {
      _showError(Globalization.msgSystemError.tr);
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
