import 'dart:io';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/profile_controller.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/media_helper.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/phone_detail.dart';
import 'package:ezy_member_v2/models/profile_model.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_card.dart';
import 'package:ezy_member_v2/widgets/custom_modal.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

enum ProfileType { member, working }

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> with SingleTickerProviderStateMixin {
  final _hive = Get.find<MemberHiveController>();
  final _profileController = Get.put(ProfileController(), tag: "profileDetail");

  late ProfileDetailControllers _memberControllers;
  late ProfileDetailControllers _workingControllers;
  late TabController _tabController;

  bool _isRequired = false;
  PhoneDetail _phoneMember = PhoneDetail();
  PhoneDetail _phoneWorking = PhoneDetail();
  MemberProfileModel _memberProfile = MemberProfileModel.empty();
  WorkingProfileModel _workingProfile = WorkingProfileModel.empty();

  String _selectedGender = "";
  String _selectedIDType = AppStrings().idTypes.keys.first;

  @override
  void initState() {
    super.initState();

    _memberControllers = ProfileDetailControllers(_memberProfile);
    _workingControllers = ProfileDetailControllers(_workingProfile);

    _tabController = TabController(length: 2, vsync: this);
    // Listen to tab change, then retrieve data, "0" for personal and "1" for working
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _fetchProfile(true);
      } else if (_tabController.index == 1) {
        _fetchProfile(false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProfile(true));

    ever(_profileController.isUpdate, (updated) {
      if (updated == true && _tabController.index == 0) {
        _fetchProfile(true);
      } else if (updated == true && _tabController.index == 1) {
        _fetchProfile(false);
      }
    });
  }

  void _fetchProfile(bool isMember) async {
    if (_hive.memberProfile.value == null) return;

    await _profileController.loadProfile(_hive.memberProfile.value!.memberCode, isMember ? ProfileType.member : ProfileType.working);

    if (isMember && _profileController.memberProfile.value != null) {
      _memberProfile = _profileController.memberProfile.value!;
      _memberControllers = ProfileDetailControllers(_memberProfile);

      await _phoneMember.update(_memberProfile.countryCode);

      if (_memberProfile.gender.isNotEmpty) _selectedGender = _memberProfile.gender;

      _memberControllers[fieldGender].text = AppStrings().genders[_selectedGender] ?? "";
      setState(() {});
    } else if (!isMember && _profileController.workingProfile.value != null) {
      _workingProfile = _profileController.workingProfile.value!;
      _workingControllers = ProfileDetailControllers(_workingProfile);

      await _phoneWorking.update(_workingProfile.countryCode);

      if (_workingProfile.registrationSchemeID.isNotEmpty) _selectedIDType = _workingProfile.registrationSchemeID;

      _workingControllers[fieldRegistrationSchemeID].text = AppStrings().idTypes[_selectedIDType] ?? AppStrings().idTypes.values.first;
      setState(() {});
    } else if (!isMember && _profileController.workingProfile.value == null) {
      _workingControllers[fieldRegistrationSchemeID].text = AppStrings().idTypes[_selectedIDType] ?? AppStrings().idTypes.values.first;
      setState(() {});
    }
  }

  void _uploadMedia(int isAvatar) async {
    final pickedSource = await CustomTypePickerDialog.show<ImageSource, String>(
      context: context,
      title: "select_source".tr,
      options: AppStrings().imageSrc,
      onDisplay: (option) => option,
    );

    if (pickedSource == null) return;

    File? pickedFile = await MediaHelper.processImage(pickedSource.key);

    if (pickedFile == null) return;

    _profileController.uploadMedia(pickedFile, isAvatar, _hive.memberProfile.value!.memberCode, _hive.memberProfile.value!.token);
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: controller.text.isEmpty ? DateTime.now() : FormatterHelper.stringToDateTime(controller.text),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            surface: Theme.of(context).colorScheme.surface,
            onSurface: Theme.of(context).colorScheme.onSurface,
          ),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary)),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) controller.text = FormatterHelper.timestampToString(pickedDate.millisecondsSinceEpoch);
  }

  void _updateMemberProfile() async {
    FocusScope.of(context).unfocus();

    if (_memberControllers[fieldContactNumber].text.trim().isEmpty) {
      MessageHelper.show("msg_required".trParams({"label": "phone".tr}), backgroundColor: Colors.red, icon: Icons.error_rounded);
      return;
    }

    final Map<String, dynamic> data = MemberProfileModel.toJsonUpdate(
      memberCode: _memberProfile.memberCode,
      countryCode: _phoneMember.dialCode,
      contactNumber: _memberControllers[fieldContactNumber].text.trim(),
      address1: _memberControllers[fieldAddress1].text.trim(),
      address2: _memberControllers[fieldAddress2].text.trim(),
      address3: _memberControllers[fieldAddress3].text.trim(),
      address4: _memberControllers[fieldAddress4].text.trim(),
      postcode: _memberControllers[fieldPostcode].text.trim(),
      city: _memberControllers[fieldCity].text.trim(),
      state: _memberControllers[fieldState].text.trim(),
      country: _memberControllers[fieldCountry].text.trim(),
      tin: _memberControllers[fieldTIN].text.trim(),
      sstRegistrationNo: _memberControllers[fieldSSTRegistrationNo].text.trim(),
      ttxRegistrationNo: _memberControllers[fieldTTXRegistrationNo].text.trim(),
      name: _memberControllers[fieldName].text.trim(),
      gender: _selectedGender,
      dob: _memberControllers[fieldDOB].text.trim(),
      accountCode: _memberControllers[fieldAccountCode].text.trim(),
    );

    _profileController.updateProfile(data, ProfileType.member, _hive.memberProfile.value!.token);
  }

  void _updateWorkingProfile() async {
    FocusScope.of(context).unfocus();

    if (_isRequired && !_workingControllers.validateRequiredFields()) {
      MessageHelper.show("msg_required_e_invoice".tr, backgroundColor: Colors.red, icon: Icons.error_rounded);
      return;
    }

    final Map<String, dynamic> data = WorkingProfileModel.toJsonUpdate(
      memberCode: _memberProfile.memberCode,
      countryCode: _phoneWorking.dialCode,
      contactNumber: _workingControllers[fieldContactNumber].text.trim(),
      address1: _workingControllers[fieldAddress1].text.trim(),
      address2: _workingControllers[fieldAddress2].text.trim(),
      address3: _workingControllers[fieldAddress3].text.trim(),
      address4: _workingControllers[fieldAddress4].text.trim(),
      postcode: _workingControllers[fieldPostcode].text.trim(),
      city: _workingControllers[fieldCity].text.trim(),
      state: _workingControllers[fieldState].text.trim(),
      country: _workingControllers[fieldCountry].text.trim(),
      tin: _workingControllers[fieldTIN].text.trim(),
      sstRegistrationNo: _workingControllers[fieldSSTRegistrationNo].text.trim(),
      ttxRegistrationNo: _workingControllers[fieldTTXRegistrationNo].text.trim(),
      name: _workingControllers[fieldName].text.trim(),
      email: _workingControllers[fieldEmail].text.trim(),
      roc: _workingControllers[fieldROC].text.trim(),
      msic: _workingControllers[fieldMSICCode].text.trim(),
      registrationSchemeID: _selectedIDType,
      registrationSchemeNo: _workingControllers[fieldRegistrationSchemeNo].text.trim(),
    );

    _profileController.updateProfile(data, ProfileType.working, _hive.memberProfile.value!.token);
  }

  @override
  void dispose() {
    _memberControllers.dispose();
    _workingControllers.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: ProfileType.values.length,
    child: Scaffold(body: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildContent()])),
  );

  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    pinned: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    bottom: TabBar(
      controller: _tabController,
      indicatorColor: Theme.of(context).colorScheme.onPrimary,
      labelColor: Theme.of(context).colorScheme.onPrimary,
      unselectedLabelColor: Colors.grey,
      tabs: <Tab>[
        Tab(text: "member".tr),
        Tab(text: "working".tr),
      ],
    ),
    title: Text("profile".tr),
  );

  Widget _buildContent() => SliverFillRemaining(
    child: TabBarView(controller: _tabController, children: <Widget>[_buildMemberProfile(), _buildWorkingProfile()]),
  );

  Widget _buildMemberProfile() => CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ResponsiveHelper.getSpacing(context, 8.0),
          children: <Widget>[
            Obx(
              () => CustomProfileCard(
                backgroundImage: _hive.isSignIn ? _hive.memberProfile.value!.backgroundImage : "",
                image: _hive.isSignIn ? _hive.memberProfile.value!.image : "",
                memberCode: _memberProfile.memberCode,
                name: _memberProfile.name,
                onTapEdit: () => _uploadMedia(1),
                onTapEditBg: () => _uploadMedia(0),
              ),
            ),
            CustomSectionCard(
              title: "basic_information".tr,
              children: <Widget>[
                CustomUnderlineTextField(controller: _memberControllers[fieldName], label: "name".tr),
                CustomUnderlineTextField(enabled: false, controller: _memberControllers[fieldEmail], label: "email".tr),
                CustomUnderlineTextField(
                  controller: _memberControllers[fieldContactNumber],
                  phone: _phoneMember,
                  label: "phone".tr,
                  type: UnderlineType.phone,
                  keyboardType: TextInputType.phone,
                  onPhoneChanged: (value) => setState(() => _phoneMember = value),
                ),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, 32.0),
                  children: <Widget>[
                    Expanded(
                      child: CustomUnderlineTextField(
                        controller: _memberControllers[fieldGender],
                        label: "gender".tr,
                        onTap: () async {
                          final pickedGender = await CustomTypePickerDialog.show<String, String>(
                            context: context,
                            title: "pick_gender".tr,
                            options: AppStrings().genders,
                            onDisplay: (option) => option,
                          );

                          if (pickedGender != null) {
                            _memberControllers[fieldGender].text = pickedGender.value;
                            _selectedGender = pickedGender.key;
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomUnderlineTextField(
                        controller: _memberControllers[fieldDOB],
                        label: "dob".tr,
                        onTap: () => _selectDate(context, _memberControllers[fieldDOB]),
                      ),
                    ),
                  ],
                ),
                CustomUnderlineTextField(controller: _memberControllers[fieldAccountCode], label: "account_code".tr),
              ],
            ),
            CustomSectionCard(
              title: "address".tr,
              children: <Widget>[
                CustomUnderlineTextField(controller: _memberControllers[fieldAddress1], label: "${"address_line".tr} 1"),
                CustomUnderlineTextField(controller: _memberControllers[fieldAddress2], label: "${"address_line".tr} 2"),
                CustomUnderlineTextField(controller: _memberControllers[fieldAddress3], label: "${"address_line".tr} 3"),
                CustomUnderlineTextField(controller: _memberControllers[fieldAddress4], label: "${"address_line".tr} 4"),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, 32.0),
                  children: <Widget>[
                    Expanded(
                      child: CustomUnderlineTextField(
                        controller: _memberControllers[fieldPostcode],
                        label: "postcode".tr,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Expanded(
                      child: CustomUnderlineTextField(controller: _memberControllers[fieldCity], label: "city".tr),
                    ),
                  ],
                ),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, 32.0),
                  children: <Widget>[
                    Expanded(
                      child: CustomUnderlineTextField(controller: _memberControllers[fieldState], label: "state".tr),
                    ),
                    Expanded(
                      child: CustomUnderlineTextField(
                        controller: _memberControllers[fieldCountry],
                        label: "country".tr,
                        onTap: () async {
                          final selectedPhone = await CustomCountryPickerDialog.show(context);

                          if (selectedPhone != null) _memberControllers[fieldCountry].text = selectedPhone.country;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            CustomSectionCard(
              title: "registration_information".tr,
              children: <Widget>[
                CustomUnderlineTextField(controller: _memberControllers[fieldTIN], label: "tin".tr),
                CustomUnderlineTextField(controller: _memberControllers[fieldSSTRegistrationNo], label: "sst_registration".tr),
                CustomUnderlineTextField(controller: _memberControllers[fieldTTXRegistrationNo], label: "ttx_registration".tr),
              ],
            ),
            const SizedBox(),
            Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveHelper.getSpacing(context, 16.0),
                left: ResponsiveHelper.getSpacing(context, 16.0),
                right: ResponsiveHelper.getSpacing(context, 16.0),
              ),
              child: CustomFilledButton(label: "save_changes".tr, onTap: () => _updateMemberProfile()),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildWorkingProfile() => CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ResponsiveHelper.getSpacing(context, 8.0),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadiusM),
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.25),
                    blurRadius: kBlurRadius,
                    offset: const Offset(kOffsetX, kOffsetY),
                  ),
                ],
              ),
              margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(context, 24.0),
                vertical: ResponsiveHelper.getSpacing(context, 16.0),
              ),
              child: CheckboxListTile(
                value: _isRequired,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => _isRequired = value!),
                subtitle: _isRequired ? CustomText("msg_required_e_invoice".tr, fontSize: 14.0) : null,
                title: CustomText(
                  "required_e_invoice".tr,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomSectionCard(
              title: "company_information".tr,
              children: <Widget>[
                CustomUnderlineTextField(controller: _workingControllers[fieldName], isRequired: _isRequired, label: "name".tr),
                CustomUnderlineTextField(
                  controller: _workingControllers[fieldEmail],
                  isRequired: _isRequired,
                  label: "email".tr,
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomUnderlineTextField(
                  controller: _workingControllers[fieldContactNumber],
                  isRequired: _isRequired,
                  phone: _phoneWorking,
                  label: "phone".tr,
                  type: UnderlineType.phone,
                  keyboardType: TextInputType.phone,
                  onPhoneChanged: (value) => setState(() => _phoneWorking = value),
                ),
              ],
            ),
            CustomSectionCard(
              title: "address".tr,
              children: <Widget>[
                CustomUnderlineTextField(controller: _workingControllers[fieldAddress1], isRequired: _isRequired, label: "${"address_line".tr} 1"),
                CustomUnderlineTextField(controller: _workingControllers[fieldAddress2], label: "${"address_line".tr} 2"),
                CustomUnderlineTextField(controller: _workingControllers[fieldAddress3], label: "${"address_line".tr} 3"),
                CustomUnderlineTextField(controller: _workingControllers[fieldAddress4], label: "${"address_line".tr} 4"),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, 32.0),
                  children: <Widget>[
                    Expanded(
                      child: CustomUnderlineTextField(
                        controller: _workingControllers[fieldPostcode],
                        isRequired: _isRequired,
                        label: "postcode".tr,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Expanded(
                      child: CustomUnderlineTextField(controller: _workingControllers[fieldCity], isRequired: _isRequired, label: "city".tr),
                    ),
                  ],
                ),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, 32.0),
                  children: <Widget>[
                    Expanded(
                      child: CustomUnderlineTextField(controller: _workingControllers[fieldState], isRequired: _isRequired, label: "state".tr),
                    ),
                    Expanded(
                      child: CustomUnderlineTextField(
                        controller: _workingControllers[fieldCountry],
                        isRequired: _isRequired,
                        label: "country".tr,
                        onTap: () async {
                          final selectedPhone = await CustomCountryPickerDialog.show(context);

                          if (selectedPhone != null) _workingControllers[fieldCountry].text = selectedPhone.country;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            CustomSectionCard(
              title: "registration_information".tr,
              children: <Widget>[
                CustomUnderlineTextField(
                  typeController: _workingControllers[fieldRegistrationSchemeID],
                  valueController: _workingControllers[fieldRegistrationSchemeNo],
                  isRequired: _isRequired,
                  label: "registration_scheme_id".tr,
                  type: UnderlineType.idType,
                  onTap: () async {
                    final pickedIDTypes = await CustomTypePickerDialog.show<String, String>(
                      context: context,
                      title: "pick_registration_type".tr,
                      options: AppStrings().idTypes,
                      onDisplay: (option) => option,
                    );

                    if (pickedIDTypes != null) {
                      _workingControllers[fieldRegistrationSchemeID].text = pickedIDTypes.value;
                      _selectedIDType = pickedIDTypes.key;
                    }
                  },
                ),
                CustomUnderlineTextField(controller: _workingControllers[fieldTIN], isRequired: _isRequired, label: "tin".tr),
                CustomUnderlineTextField(controller: _workingControllers[fieldSSTRegistrationNo], label: "sst_registration".tr),
                CustomUnderlineTextField(
                  controller: _workingControllers[fieldTTXRegistrationNo],
                  isRequired: _isRequired,
                  label: "ttx_registration".tr,
                ),
                CustomUnderlineTextField(controller: _workingControllers[fieldROC], isRequired: _isRequired, label: "roc".tr),
                CustomUnderlineTextField(controller: _workingControllers[fieldMSICCode], isRequired: _isRequired, label: "msic_code".tr),
              ],
            ),
            const SizedBox(),
            Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveHelper.getSpacing(context, 16.0),
                left: ResponsiveHelper.getSpacing(context, 16.0),
                right: ResponsiveHelper.getSpacing(context, 16.0),
              ),
              child: CustomFilledButton(label: "save_changes".tr, onTap: () => _updateWorkingProfile()),
            ),
          ],
        ),
      ),
    ],
  );
}
