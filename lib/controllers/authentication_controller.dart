import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/hive/member_profile_hive.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/models/profile_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthenticationController extends GetxController {
  final ApiService _api = ApiService();

  var isSuccess = false.obs;
  var memberProfile = Rx<MemberProfileModel?>(null);

  Future<void> signUp(Map<String, dynamic> data) async {
    isSuccess.value = false;

    _showLoading(Globalization.msgSignUpProcessing.tr);

    final response = await _api.post(endPoint: "register-account", module: "AuthenticationController - signUp", data: data);

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        isSuccess.value = true;
        _showSuccess(Globalization.msgSignUpSuccess.tr);
        break;
      case 401:
        _showError(Globalization.msgEmailExists.tr);
        break;
      case 402:
        _showError(Globalization.msgPhoneExists.tr);
        break;
      default:
        _showError(Globalization.msgSystemError.tr);
        break;
    }
  }

  Future<void> signIn(Map<String, dynamic> data) async {
    isSuccess.value = false;
    memberProfile.value = null;

    _showLoading(Globalization.msgSignInProcessing.tr);

    final response = await _api.post(endPoint: "login-account", module: "AuthenticationController - signIn", data: data);

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        final json = Map<String, dynamic>.from(response.data[MemberProfileModel.keyMember]);
        final profile = MemberProfileModel.fromJson(json);

        memberProfile.value = profile;
        isSuccess.value = true;

        final hive = Get.find<MemberHiveController>();
        await hive.signIn(
          MemberProfileHive(
            id: profile.id,
            memberCode: profile.memberCode,
            name: profile.name,
            token: profile.token,
            image: profile.image,
            backgroundImage: profile.backgroundImage,
            personalInvoice: profile.personalInvoiceImage,
            workingInvoice: response.data["working_e_invoice"],
          ),
        );

        _showSuccess(Globalization.msgSignInSuccess.tr);
        Get.offAllNamed(AppRoutes.home);
        break;
      case 400:
        _showError(Globalization.msgSignInFail.tr);
        break;
      case 401:
        _showError(Globalization.msgEmailNotFound.tr);
        break;
      case 402:
        _showError(Globalization.msgPhoneNotFound.tr);
        break;
      case 403:
        _showError(Globalization.msgAccountInactive.tr);
        break;
      default:
        _showError(Globalization.msgSystemError.tr);
        break;
    }
  }

  Future<void> signInWithGoogle(String email) async {
    isSuccess.value = false;
    memberProfile.value = null;

    _showLoading(Globalization.msgSignInProcessing.tr);

    final response = await _api.post(endPoint: "sign-in-with-google", module: "AuthenticationController - signInWithGoogle", data: {"email": email});

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        final json = Map<String, dynamic>.from(response.data[MemberProfileModel.keyMember]);
        final profile = MemberProfileModel.fromJson(json);

        memberProfile.value = profile;
        isSuccess.value = true;

        final hive = Get.find<MemberHiveController>();
        await hive.signIn(
          MemberProfileHive(
            id: profile.id,
            memberCode: profile.memberCode,
            name: profile.name,
            token: profile.token,
            image: profile.image,
            backgroundImage: profile.backgroundImage,
            personalInvoice: profile.personalInvoiceImage,
            workingInvoice: response.data["working_e_invoice"],
          ),
        );

        _showSuccess(Globalization.msgSignInSuccess.tr);
        Get.offAllNamed(AppRoutes.home);
        break;
      case 400:
        _showError(Globalization.msgEmailNotExists.tr);
        break;
      default:
        _showError(Globalization.msgSystemError.tr);
        break;
    }
  }

  Future<void> checkToken(String memberCode, String memberToken) async {
    final response = await _api.post(
      endPoint: "check-token",
      module: "AuthenticationController - checkToken",
      data: {"member_code": memberCode},
      memberToken: memberToken,
    );

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 520) {
      final hive = Get.find<MemberHiveController>();

      await hive.signOut();

      _showError(Globalization.msgTokenExpired.tr);
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
