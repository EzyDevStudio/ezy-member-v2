import 'dart:io';

import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/models/profile_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:ezy_member_v2/views/profile_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final ApiService _api = ApiService();

  var isUpdate = false.obs;
  var memberProfile = Rx<MemberProfileModel?>(null);
  var workingProfile = Rx<WorkingProfileModel?>(null);

  ProfileDetailControllers? memberControllers;
  ProfileDetailControllers? workingControllers;

  Future<void> loadProfile(String memberCode, ProfileType type) async {
    _showLoading("msg_profile_retrieving".tr);

    final bool isMember = type == ProfileType.member;
    final String endpoint = isMember ? "get-personal-profile/$memberCode" : "get-working-profile/$memberCode";
    final String key = isMember ? MemberProfileModel.keyMember : WorkingProfileModel.keyWorking;
    final response = await _api.get(endPoint: endpoint, module: "ProfileController - loadProfile");

    _hideLoading();

    if (response == null || response.data[key] == null) {
      return;
    }

    if (isMember) {
      memberProfile.value = MemberProfileModel.fromJson(response.data[key]);
      memberControllers = ProfileDetailControllers(memberProfile.value!);
    } else {
      workingProfile.value = WorkingProfileModel.fromJson(response.data[key]);
      workingControllers = ProfileDetailControllers(workingProfile.value!);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> json, ProfileType type, String memberToken) async {
    isUpdate.value = false;

    _showLoading("msg_profile_updating".tr);

    final bool isMember = type == ProfileType.member;
    final String endpoint = isMember ? "update-personal-profile" : "update-working-profile";
    final response = await _api.post(endPoint: endpoint, module: "ProfileController - updateProfile", data: json, memberToken: memberToken);

    _hideLoading();

    if (response == null) {
      _showError("msg_system_error".tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        isUpdate.value = true;
        _showSuccess("msg_profile_success".tr);
        break;
      case 401:
        _showError("msg_phone_exists".tr);
        break;
      case 402:
        _showError("msg_email_exists".tr);
        break;
      case 520:
        _showError("msg_token_invalid".tr);
        break;
      default:
        _showError("msg_system_error".tr);
        break;
    }
  }

  Future<void> uploadMedia(File file, int imgType, String memberCode, String memberToken) async {
    _showLoading("msg_profile_updating".tr);

    final Map<String, dynamic> data = {"image_type": imgType, "member_code": memberCode};
    final response = await _api.postFile(
      file: file,
      data: data,
      endPoint: "upload-media",
      memberToken: memberToken,
      module: "ProfileController - uploadMedia",
    );

    _hideLoading();

    if (response == null || response.data["filename"] == null) {
      _showError("msg_system_error".tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        final hive = Get.find<MemberHiveController>();

        if (imgType == 0) hive.updateImage(response.data["filename"]);
        if (imgType == 1) hive.updateBackgroundImage(response.data["filename"]);
        if (imgType == 2) hive.updatePersonalInvoiceImage(response.data["filename"]);
        if (imgType == 3) hive.updateCompanyInvoiceImage(response.data["filename"]);

        _showSuccess("msg_profile_success".tr);

        break;
      case 520:
        _showError("msg_token_invalid".tr);
        break;
      default:
        _showError("msg_system_error".tr);
        break;
    }
  }

  void _showLoading(String message) {
    MessageHelper.showDialog(type: DialogType.loading, message: message, title: "processing".tr);
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

  @override
  void onClose() {
    memberControllers?.dispose();
    workingControllers?.dispose();

    super.onClose();
  }
}

class ProfileDetailControllers {
  final Map<String, TextEditingController> _controllers = {};

  ProfileDetailControllers(ProfileModel profile) {
    _controllers[fieldContactNumber] = TextEditingController(text: profile.contactNumber);
    _controllers[fieldAddress1] = TextEditingController(text: profile.address1);
    _controllers[fieldAddress2] = TextEditingController(text: profile.address2);
    _controllers[fieldAddress3] = TextEditingController(text: profile.address3);
    _controllers[fieldAddress4] = TextEditingController(text: profile.address4);
    _controllers[fieldPostcode] = TextEditingController(text: profile.postcode);
    _controllers[fieldCity] = TextEditingController(text: profile.city);
    _controllers[fieldState] = TextEditingController(text: profile.state);
    _controllers[fieldCountry] = TextEditingController(text: profile.country);
    _controllers[fieldTIN] = TextEditingController(text: profile.tin);
    _controllers[fieldSSTRegistrationNo] = TextEditingController(text: profile.sstRegistrationNo);
    _controllers[fieldTTXRegistrationNo] = TextEditingController(text: profile.ttxRegistrationNo);

    if (profile is MemberProfileModel) {
      _controllers[fieldName] = TextEditingController(text: profile.name);
      _controllers[fieldEmail] = TextEditingController(text: profile.email);
      _controllers[fieldGender] = TextEditingController(text: profile.gender);
      _controllers[fieldDOB] = TextEditingController(text: profile.dob == 0 ? "" : FormatterHelper.timestampToString(profile.dob));
      _controllers[fieldAccountCode] = TextEditingController(text: profile.accountCode);
    }

    if (profile is WorkingProfileModel) {
      _controllers[fieldName] = TextEditingController(text: profile.companyName);
      _controllers[fieldEmail] = TextEditingController(text: profile.companyEmail);
      _controllers[fieldROC] = TextEditingController(text: profile.roc);
      _controllers[fieldMSICCode] = TextEditingController(text: profile.msicCode);
      _controllers[fieldRegistrationSchemeID] = TextEditingController(text: profile.registrationSchemeID);
      _controllers[fieldRegistrationSchemeNo] = TextEditingController(text: profile.registrationSchemeNo);
    }
  }

  TextEditingController operator [](String key) => _controllers[key]!;

  bool validateRequiredFields() {
    final requiredFields = [
      fieldContactNumber,
      fieldAddress1,
      fieldPostcode,
      fieldCity,
      fieldState,
      fieldCountry,
      fieldTIN,
      fieldTTXRegistrationNo,
      fieldName,
      fieldEmail,
      fieldROC,
      fieldMSICCode,
      fieldRegistrationSchemeID,
      fieldRegistrationSchemeNo,
    ];

    for (final key in requiredFields) {
      final text = _controllers[key]?.text.trim() ?? "";

      if (text.isEmpty) return false;
    }

    return true;
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
  }
}
