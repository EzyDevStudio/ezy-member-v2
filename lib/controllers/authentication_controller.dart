import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/hive/member_profile_hive.dart';
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

    _showLoading(AppStrings.msgSignUpProcessing);

    final response = await _api.post(endPoint: "register-account", module: "AuthenticationController - signUp", data: data);

    _hideLoading();

    if (response == null) {
      _showError(AppStrings.msgSystemFailed);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        isSuccess.value = true;
        _showSuccess(AppStrings.msgSignUpSuccess);
        break;
      case 401:
        _showError(AppStrings.msgEmailExists);
        break;
      case 402:
        _showError(AppStrings.msgPhoneExists);
        break;
      default:
        _showError(AppStrings.msgSystemFailed);
        break;
    }
  }

  Future<void> signIn(Map<String, dynamic> data) async {
    isSuccess.value = false;
    memberProfile.value = null;

    _showLoading(AppStrings.msgSignInProcessing);

    final response = await _api.post(endPoint: "login-account", module: "AuthenticationController - signIn", data: data);

    _hideLoading();

    if (response == null) {
      _showError(AppStrings.msgSystemFailed);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        final json = Map<String, dynamic>.from(response.data[MemberProfileModel.keyMember]);
        final profile = MemberProfileModel.fromJson(json);

        memberProfile.value = profile;
        isSuccess.value = true;

        final hive = Get.find<MemberHiveController>();
        await hive.signIn(MemberProfileHive(id: profile.id, memberCode: profile.memberCode, name: profile.name, token: profile.token));

        _showSuccess(AppStrings.msgSignInSuccess);
        Get.offAllNamed(AppRoutes.home);
        break;
      case 400:
        _showError(AppStrings.msgSignInFail);
        break;
      case 401:
        _showError(AppStrings.msgEmailNotFound);
        break;
      case 402:
        _showError(AppStrings.msgPhoneNotFound);
        break;
      case 403:
        _showError(AppStrings.msgAccountStatusInactive);
        break;
      default:
        _showError(AppStrings.msgSystemFailed);
        break;
    }
  }

  void _showLoading(String message) {
    MessageHelper.showDialog(type: DialogType.loading, message: message, title: AppStrings.processing);
  }

  void _hideLoading() {
    if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();
  }

  void _showError(String message) {
    MessageHelper.show(message, backgroundColor: Colors.red, icon: Icons.error_rounded);
  }

  void _showSuccess(String message) {
    MessageHelper.show(message, backgroundColor: Colors.green, icon: Icons.check_circle_outline_rounded);
  }
}
