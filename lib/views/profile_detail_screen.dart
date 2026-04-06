import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/controllers/profile_controller.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/media_helper.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/phone_detail.dart';
import 'package:ezymember/models/postcode_detail.dart';
import 'package:ezymember/models/profile_model.dart';
import 'package:ezymember/services/local/connection_service.dart';
import 'package:ezymember/widgets/custom_button.dart';
import 'package:ezymember/widgets/custom_card.dart';
import 'package:ezymember/widgets/custom_modal.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

enum ProfileType { member, working, settings }

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

  PhoneDetail _phoneMember = PhoneDetail();
  PhoneDetail _phoneWorking = PhoneDetail();
  MemberProfileModel _memberProfile = MemberProfileModel.empty();
  WorkingProfileModel _workingProfile = WorkingProfileModel.empty();

  String _selectedGender = "";

  @override
  void initState() {
    super.initState();

    _memberControllers = ProfileDetailControllers(_memberProfile);
    _workingControllers = ProfileDetailControllers(_workingProfile);
    _tabController = TabController(length: ProfileType.values.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProfile());
  }

  void _fetchProfile() async {
    if (_hive.memberProfile.value == null) return;

    await _profileController.loadProfile(_hive.memberProfile.value!.memberCode);

    if (_profileController.memberProfile.value != null) {
      _memberProfile = _profileController.memberProfile.value!;
      _memberControllers = ProfileDetailControllers(_memberProfile);

      await _phoneMember.update(_memberProfile.countryCode);

      if (_memberProfile.gender.isNotEmpty) _selectedGender = _memberProfile.gender;

      _memberControllers[fieldGender].text = AppStrings().genders[_selectedGender] ?? "";
      setState(() {});
    }

    if (_profileController.workingProfile.value != null) {
      _workingProfile = _profileController.workingProfile.value!;
      _workingControllers = ProfileDetailControllers(_workingProfile);

      await _phoneWorking.update(_workingProfile.countryCode);
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: controller.text.isEmpty ? DateTime.now() : controller.text.strToDT,
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

    if (pickedDate != null) controller.text = pickedDate.dtToStr;
  }

  void _updateMemberProfile() async {
    FocusScope.of(context).unfocus();

    if (_memberControllers[fieldContactNumber].text.trim().isEmpty) {
      MessageHelper.error(message: Globalization.msgRequired.trParams({"label": Globalization.phone.tr}));
      return;
    }

    int contactNumber = int.parse(_memberControllers[fieldContactNumber].text.trim());

    final Map<String, dynamic> data = MemberProfileModel.toJsonUpdate(
      memberCode: _memberProfile.memberCode,
      countryCode: _phoneMember.dialCode,
      contactNumber: contactNumber.toString(),
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

    String contactNumber = "";

    if (_workingControllers[fieldContactNumber].text.trim().isNotEmpty) {
      contactNumber = int.parse(_workingControllers[fieldContactNumber].text.trim()).toString();
    }

    final Map<String, dynamic> data = WorkingProfileModel.toJsonUpdate(
      memberCode: _memberProfile.memberCode,
      countryCode: _phoneWorking.dialCode,
      contactNumber: contactNumber,
      address1: _workingControllers[fieldAddress1].text.trim(),
      address2: _workingControllers[fieldAddress2].text.trim(),
      address3: _workingControllers[fieldAddress3].text.trim(),
      address4: _workingControllers[fieldAddress4].text.trim(),
      postcode: _workingControllers[fieldPostcode].text.trim(),
      city: _workingControllers[fieldCity].text.trim(),
      state: _workingControllers[fieldState].text.trim(),
      country: _workingControllers[fieldCountry].text.trim(),
      name: _workingControllers[fieldName].text.trim(),
      email: _workingControllers[fieldEmail].text.trim(),
    );

    _profileController.updateProfile(data, ProfileType.working, _hive.memberProfile.value!.token);
  }

  void _uploadMedia(int imgType) async {
    if (!await ConnectionService.checkConnection()) return;
    if (!mounted) return;

    final pickedSource = await CustomTypePickerDialog.show<ImageSource, String>(
      context: context,
      title: Globalization.selectSource.tr,
      options: AppStrings().imageSrc,
      onDisplay: (option) => option,
    );

    if (pickedSource == null) return;

    XFile? pickedFile = await MediaHelper.processImage(pickedSource.key);

    if (pickedFile == null) return;

    _profileController.uploadMedia(pickedFile, imgType, _hive.memberProfile.value!.memberCode, _hive.memberProfile.value!.token);
  }

  void _removeMedia(int imgType) async {
    if (!await ConnectionService.checkConnection()) return;

    _profileController.removeMedia(imgType, _hive.memberProfile.value!.memberCode, _hive.memberProfile.value!.token);
  }

  void _deleteAccount() async {
    if (!await ConnectionService.checkConnection()) return;

    final bool? result = await MessageHelper.confirmation(
      message: Globalization.msgDeleteAccountConfirmation.tr,
      title: Globalization.deleteAccount.tr,
    );

    if (result == true) _profileController.deleteAccount(_hive.memberProfile.value!.memberCode, _hive.memberProfile.value!.token);
  }

  @override
  void dispose() {
    _memberControllers.dispose();
    _workingControllers.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    rsp.init(context);

    return DefaultTabController(
      length: ProfileType.values.length,
      child: Scaffold(backgroundColor: Theme.of(context).colorScheme.surface, appBar: _buildAppBar(), body: _buildContent()),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    bottom: TabBar(
      controller: _tabController,
      indicatorColor: Theme.of(context).colorScheme.onPrimary,
      labelColor: Theme.of(context).colorScheme.onPrimary,
      unselectedLabelColor: Colors.grey,
      tabs: <Tab>[
        Tab(text: Globalization.member.tr),
        Tab(text: Globalization.working.tr),
        Tab(text: Globalization.settings.tr),
      ],
    ),
    leading: IconButton(
      onPressed: () => Get.back(),
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    ),
    title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
  );

  Widget _buildContent() =>
      TabBarView(controller: _tabController, children: <Widget>[_buildMemberProfile(), _buildWorkingProfile(), _buildSettings()]);

  Widget _buildMemberProfile() => ListView(
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.dp,
        children: <Widget>[
          Obx(
            () => CustomProfileCard(
              backgroundImage: _hive.backgroundImage,
              image: _hive.image,
              memberCode: _memberProfile.memberCode,
              name: _memberProfile.name,
            ),
          ),
          CustomSectionCard(
            title: Globalization.basicInformation.tr,
            children: <Widget>[
              CustomUnderlineTextField(controller: _memberControllers[fieldName], label: Globalization.name.tr),
              CustomUnderlineTextField(enabled: false, controller: _memberControllers[fieldEmail], label: Globalization.email.tr),
              CustomUnderlineTextField(
                controller: _memberControllers[fieldContactNumber],
                phone: _phoneMember,
                label: Globalization.phone.tr,
                type: UnderlineType.phone,
                keyboardType: TextInputType.phone,
                onPhoneChanged: (value) => setState(() => _phoneMember = value),
              ),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(
                    child: CustomUnderlineTextField(
                      controller: _memberControllers[fieldGender],
                      label: Globalization.gender.tr,
                      onTap: () async {
                        final pickedGender = await CustomTypePickerDialog.show<String, String>(
                          context: context,
                          title: Globalization.pickGender.tr,
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
                      label: Globalization.dob.tr,
                      onTap: () => _selectDate(context, _memberControllers[fieldDOB]),
                    ),
                  ),
                ],
              ),
            ],
          ),
          CustomSectionCard(
            title: Globalization.address.tr,
            children: <Widget>[
              CustomUnderlineTextField(controller: _memberControllers[fieldAddress1], label: "${Globalization.addressLine.tr} 1"),
              CustomUnderlineTextField(controller: _memberControllers[fieldAddress2], label: "${Globalization.addressLine.tr} 2"),
              CustomUnderlineTextField(controller: _memberControllers[fieldAddress3], label: "${Globalization.addressLine.tr} 3"),
              CustomUnderlineTextField(controller: _memberControllers[fieldAddress4], label: "${Globalization.addressLine.tr} 4"),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(child: _buildPostCodeField(_memberControllers[fieldPostcode], _memberControllers, Globalization.postcode.tr)),
                  Expanded(child: _buildPostCodeField(_memberControllers[fieldCity], _memberControllers, Globalization.city.tr)),
                ],
              ),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(child: _buildPostCodeField(_memberControllers[fieldState], _memberControllers, Globalization.state.tr)),
                  Expanded(
                    child: CustomUnderlineTextField(
                      controller: _memberControllers[fieldCountry],
                      label: Globalization.country.tr,
                      onTap: () async {
                        PhoneDetail? selectedCountry = await CustomPickerDialog.show<PhoneDetail>(
                          context,
                          loadItems: PhoneDetail.loadAll,
                          toCompare: (item) => item.toCompare(),
                          itemTileBuilder: (context, item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CustomText(PhoneDetail.countryCodeToEmoji(item.countryCode), fontSize: 25.0),
                            title: CustomText(item.country, fontSize: 16.0),
                          ),
                        );

                        if (selectedCountry != null) _memberControllers[fieldCountry].text = selectedCountry.country;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          CustomSectionCard(
            title: Globalization.registrationInformation.tr,
            children: <Widget>[
              CustomUnderlineTextField(controller: _memberControllers[fieldTIN], label: Globalization.tin.tr),
              CustomUnderlineTextField(controller: _memberControllers[fieldSSTRegistrationNo], label: Globalization.sstRegistration.tr),
              CustomUnderlineTextField(controller: _memberControllers[fieldTTXRegistrationNo], label: Globalization.ttxRegistration.tr),
            ],
          ),
          const SizedBox(),
          Padding(
            padding: EdgeInsets.only(bottom: 16.dp, left: 16.dp, right: 16.dp),
            child: CustomFilledButton(label: Globalization.saveChanges.tr, onTap: () => _updateMemberProfile()),
          ),
        ],
      ),
    ],
  );

  Widget _buildPostCodeField(TextEditingController controller, ProfileDetailControllers profile, String label, {bool isRequired = false}) =>
      CustomUnderlineTextField(
        controller: controller,
        isRequired: isRequired,
        label: label,
        onTap: () async {
          PostcodeDetail? selectedPostcode = await CustomPickerDialog.show<PostcodeDetail>(
            context,
            loadItems: PostcodeDetail.loadAll,
            toCompare: (item) => item.toCompare(),
            itemTileBuilder: (context, item) => ListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: CustomText(item.stateName, color: Colors.black54, fontSize: 14.0),
              title: CustomText(item.city, fontSize: 16.0),
              trailing: CustomText(item.postcode, fontSize: 14.0),
            ),
          );

          if (selectedPostcode != null) {
            profile[fieldPostcode].text = selectedPostcode.postcode;
            profile[fieldCity].text = selectedPostcode.city;
            profile[fieldState].text = selectedPostcode.stateName;
          }
        },
      );

  Widget _buildWorkingProfile() => ListView(
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.dp,
        children: <Widget>[
          CustomSectionCard(
            title: Globalization.companyInformation.tr,
            children: <Widget>[
              CustomUnderlineTextField(controller: _workingControllers[fieldName], label: Globalization.name.tr),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldEmail],
                label: Globalization.email.tr,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldContactNumber],
                phone: _phoneWorking,
                label: Globalization.phone.tr,
                type: UnderlineType.phone,
                keyboardType: TextInputType.phone,
                onPhoneChanged: (value) => setState(() => _phoneWorking = value),
              ),
            ],
          ),
          CustomSectionCard(
            title: Globalization.address.tr,
            children: <Widget>[
              CustomUnderlineTextField(controller: _workingControllers[fieldAddress1], label: "${Globalization.addressLine.tr} 1"),
              CustomUnderlineTextField(controller: _workingControllers[fieldAddress2], label: "${Globalization.addressLine.tr} 2"),
              CustomUnderlineTextField(controller: _workingControllers[fieldAddress3], label: "${Globalization.addressLine.tr} 3"),
              CustomUnderlineTextField(controller: _workingControllers[fieldAddress4], label: "${Globalization.addressLine.tr} 4"),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(child: _buildPostCodeField(_workingControllers[fieldPostcode], _workingControllers, Globalization.postcode.tr)),
                  Expanded(child: _buildPostCodeField(_workingControllers[fieldCity], _workingControllers, Globalization.city.tr)),
                ],
              ),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(child: _buildPostCodeField(_workingControllers[fieldState], _workingControllers, Globalization.state.tr)),
                  Expanded(
                    child: CustomUnderlineTextField(
                      controller: _workingControllers[fieldCountry],
                      label: Globalization.country.tr,
                      onTap: () async {
                        PhoneDetail? selectedCountry = await CustomPickerDialog.show<PhoneDetail>(
                          context,
                          loadItems: PhoneDetail.loadAll,
                          toCompare: (item) => item.toCompare(),
                          itemTileBuilder: (context, item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CustomText(PhoneDetail.countryCodeToEmoji(item.countryCode), fontSize: 25.0),
                            title: CustomText(item.country, fontSize: 16.0),
                          ),
                        );

                        if (selectedCountry != null) _workingControllers[fieldCountry].text = selectedCountry.country;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(),
          Padding(
            padding: EdgeInsets.only(bottom: 16.dp, left: 16.dp, right: 16.dp),
            child: CustomFilledButton(label: Globalization.saveChanges.tr, onTap: () => _updateWorkingProfile()),
          ),
        ],
      ),
    ],
  );

  Widget _buildSettings() => ListView(
    children: <Widget>[
      Container(
        padding: EdgeInsets.all(16.dp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24.dp,
          children: <Widget>[
            Wrap(
              runSpacing: 16.dp,
              alignment: WrapAlignment.spaceAround,
              children: <Widget>[
                CustomImageButton(
                  icon: Icons.upload_rounded,
                  label: Globalization.uploadImage.tr,
                  onTap: () async {
                    final selected = await CustomTypePickerDialog.show<int, String>(
                      context: context,
                      title: Globalization.uploadImage.tr,
                      options: {
                        0: Globalization.avatar.tr,
                        1: Globalization.background.tr,
                        2: Globalization.personalEInvoice.tr,
                        3: Globalization.workingEInvoice.tr,
                      },
                      onDisplay: (option) => option,
                    );

                    if (selected != null) _uploadMedia(selected.key);
                  },
                ),
                CustomImageButton(
                  icon: Icons.hide_image_rounded,
                  label: Globalization.removeImage.tr,
                  onTap: () async {
                    final selected = await CustomTypePickerDialog.show<int, String>(
                      context: context,
                      title: Globalization.removeImage.tr,
                      options: {
                        0: Globalization.avatar.tr,
                        1: Globalization.background.tr,
                        2: Globalization.personalEInvoice.tr,
                        3: Globalization.workingEInvoice.tr,
                      },
                      onDisplay: (option) => option,
                    );

                    if (selected != null) _removeMedia(selected.key);
                  },
                ),
                CustomImageButton(
                  icon: Icons.change_circle_rounded,
                  label: Globalization.changePassword.tr,
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
                CustomImageButton(icon: Icons.delete_rounded, label: Globalization.deleteAccount.tr, onTap: () => _deleteAccount()),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
