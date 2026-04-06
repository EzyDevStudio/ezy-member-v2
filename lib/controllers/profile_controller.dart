import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/constants/enum.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/profile_model.dart';
import 'package:ezymember/services/local/connection_service.dart';
import 'package:ezymember/services/remote/api_service.dart';
import 'package:ezymember/views/profile_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final ApiService _api = ApiService();

  var isUpdate = false.obs;
  var memberProfile = Rx<MemberProfileModel?>(null);
  var workingProfile = Rx<WorkingProfileModel?>(null);

  ProfileDetailControllers? memberControllers;
  ProfileDetailControllers? workingControllers;

  Future<void> loadProfile(String memberCode) async {
    _showLoading(Globalization.msgProfileRetrieving.tr);

    final response = await _api.get(endPoint: "get-profile/$memberCode", module: "ProfileController - loadProfile");

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    if (response.data[MemberProfileModel.keyMember] != null) {
      memberProfile.value = MemberProfileModel.fromJson(response.data[MemberProfileModel.keyMember]);
      memberControllers = ProfileDetailControllers(memberProfile.value!);
    }

    if (response.data[WorkingProfileModel.keyWorking] != null) {
      workingProfile.value = WorkingProfileModel.fromJson(response.data[WorkingProfileModel.keyWorking]);
      workingControllers = ProfileDetailControllers(workingProfile.value!);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> json, ProfileType type, String memberToken) async {
    if (!await ConnectionService.checkConnection()) return;

    _showLoading(Globalization.msgProfileUpdating.tr);

    final bool isMember = type == ProfileType.member;
    final String endpoint = isMember ? "update-personal-profile" : "update-working-profile";
    final response = await _api.post(endPoint: endpoint, module: "ProfileController - updateProfile", data: json, memberToken: memberToken);

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        _showSuccess(Globalization.msgProfileSuccess.tr);
        break;
      case 401:
        _showError(Globalization.msgPhoneExists.tr);
        break;
      case 402:
        _showError(Globalization.msgEmailExists.tr);
        break;
      case 520:
        _showError(Globalization.msgTokenInvalid.tr);
        break;
      default:
        _showError(Globalization.msgSystemError.tr);
        break;
    }
  }

  Future<void> uploadMedia(XFile file, int imgType, String memberCode, String memberToken) async {
    _showLoading(Globalization.msgProfileUpdating.tr);

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
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        final hive = Get.find<MemberHiveController>();
        final bytes = await file.readAsBytes();

        await hive.updateMedia(bytes, MediaType.values[imgType]);

        _showSuccess(Globalization.msgProfileSuccess.tr);

        break;
      case 520:
        _showError(Globalization.msgTokenInvalid.tr);
        break;
      default:
        _showError(Globalization.msgSystemError.tr);
        break;
    }
  }

  Future<void> removeMedia(int imgType, String memberCode, String memberToken) async {
    _showLoading(Globalization.msgProfileUpdating.tr);

    final Map<String, dynamic> data = {"image_type": imgType, "member_code": memberCode};
    final response = await _api.post(data: data, endPoint: "remove-media", memberToken: memberToken, module: "ProfileController - removeMedia");

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        final hive = Get.find<MemberHiveController>();

        await hive.clearMedia(MediaType.values[imgType]);

        _showSuccess(Globalization.msgProfileSuccess.tr);

        break;
      case 520:
        _showError(Globalization.msgTokenInvalid.tr);
        break;
      default:
        _showError(Globalization.msgSystemError.tr);
        break;
    }
  }

  Future<void> changePassword(Map<String, dynamic> data, String memberToken) async {
    if (!await ConnectionService.checkConnection()) return;

    isUpdate.value = false;

    _showLoading(Globalization.msgPasswordUpdating.tr);

    final response = await _api.post(endPoint: "change-password", module: "ProfileController - changePassword", data: data, memberToken: memberToken);

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        isUpdate.value = true;
        _showSuccess(Globalization.msgPasswordSuccess.tr);
        break;
      case 520:
        _showError(Globalization.msgTokenInvalid.tr);
        break;
      case 401:
        _showError(Globalization.msgOldPasswordNotMatch.tr);
        break;
      default:
        _showError(Globalization.msgSystemError.tr);
        break;
    }
  }

  Future<void> forgotPassword(Map<String, dynamic> data) async {
    if (!await ConnectionService.checkConnection()) return;

    _api.post(endPoint: "forgot-password", module: "ProfileController - forgotPassword", data: data);
  }

  Future<void> deleteAccount(String memberCode, String memberToken) async {
    _showLoading(Globalization.msgDeleteAccountProcessing.tr);

    final Map<String, dynamic> data = {"member_code": memberCode};
    final response = await _api.post(endPoint: "delete-account", module: "ProfileController - deleteAccount", data: data, memberToken: memberToken);

    _hideLoading();

    if (response == null) {
      _showError(Globalization.msgSystemError.tr);
      return;
    }

    switch (response.data[ApiService.keyStatusCode]) {
      case 200:
        final hive = Get.find<MemberHiveController>();
        await hive.signOut();

        Get.offNamed(AppRoutes.home);
        _showSuccess(Globalization.msgDeleteAccountSuccess.tr);

        break;
      case 520:
        _showError(Globalization.msgTokenInvalid.tr);
        break;
      default:
        _showError(Globalization.msgSystemError.tr);
        break;
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

    if (profile is MemberProfileModel) {
      _controllers[fieldName] = TextEditingController(text: profile.name);
      _controllers[fieldEmail] = TextEditingController(text: profile.email);
      _controllers[fieldGender] = TextEditingController(text: profile.gender);
      _controllers[fieldDOB] = TextEditingController(text: profile.dob == 0 ? "" : profile.dob.tsToStr);
      _controllers[fieldAccountCode] = TextEditingController(text: profile.accountCode);
      _controllers[fieldTIN] = TextEditingController(text: profile.tin);
      _controllers[fieldSSTRegistrationNo] = TextEditingController(text: profile.sstRegistrationNo);
      _controllers[fieldTTXRegistrationNo] = TextEditingController(text: profile.ttxRegistrationNo);
    }

    if (profile is WorkingProfileModel) {
      _controllers[fieldName] = TextEditingController(text: profile.companyName);
      _controllers[fieldEmail] = TextEditingController(text: profile.companyEmail);
    }
  }

  TextEditingController operator [](String key) => _controllers[key]!;

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
  }
}
