import 'package:ezymember/constants/app_constants.dart';
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
import 'package:flutter/services.dart';
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
  final List<String> _schemeType = ["BRN", "NRIC", "PASSPORT", "ARMY"];

  late ProfileDetailControllers _memberControllers;
  late ProfileDetailControllers _workingControllers;
  late TabController _tabController;

  List<PostcodeDetail> _postcodes = [];
  PhoneDetail _phoneMember = PhoneDetail();
  PhoneDetail _phoneWorking = PhoneDetail();
  MemberProfileModel _memberProfile = MemberProfileModel.empty();
  WorkingProfileModel _workingProfile = WorkingProfileModel.empty();

  String _selectedGender = "";
  String _selectedSchemePersonal = "";
  String _selectedSchemeWorking = "";

  @override
  void initState() {
    super.initState();

    _loadJson();

    _memberControllers = ProfileDetailControllers(_memberProfile);
    _workingControllers = ProfileDetailControllers(_workingProfile);
    _tabController = TabController(length: ProfileType.values.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProfile());
  }

  void _loadJson() async {
    _postcodes = await PostcodeDetail.loadAll();
    setState(() {});
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
      _selectedSchemePersonal = _schemeType.firstWhere((e) => e == _memberProfile.registrationSchemeID, orElse: () => _schemeType.first);
      _memberControllers[fieldRegistrationSchemeID].text = _selectedSchemePersonal;
      setState(() {});
    }

    if (_profileController.workingProfile.value != null) {
      _workingProfile = _profileController.workingProfile.value!;
      _workingControllers = ProfileDetailControllers(_workingProfile);

      await _phoneWorking.update(_workingProfile.countryCode);

      _selectedSchemeWorking = _schemeType.firstWhere((e) => e == _workingProfile.registrationSchemeID, orElse: () => _schemeType.first);
      _workingControllers[fieldRegistrationSchemeID].text = _selectedSchemeWorking;
      setState(() {});
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
    FocusManager.instance.primaryFocus?.unfocus();

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
      registrationSchemeID: _memberControllers[fieldRegistrationSchemeID].text.trim(),
      registrationSchemeNo: _memberControllers[fieldRegistrationSchemeNo].text.trim(),
      tin: _memberControllers[fieldTIN].text.trim(),
      sstRegistrationNo: _memberControllers[fieldSSTRegistrationNo].text.trim(),
      name: _memberControllers[fieldName].text.trim(),
      gender: _selectedGender,
      dob: _memberControllers[fieldDOB].text.trim(),
      accountCode: _memberControllers[fieldAccountCode].text.trim(),
    );

    _profileController.updateProfile(data, ProfileType.member, _hive.memberProfile.value!.token);
  }

  void _updateWorkingProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();

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
      registrationSchemeID: _workingControllers[fieldRegistrationSchemeID].text.trim(),
      registrationSchemeNo: _workingControllers[fieldRegistrationSchemeNo].text.trim(),
      tin: _workingControllers[fieldTIN].text.trim(),
      sstRegistrationNo: _workingControllers[fieldSSTRegistrationNo].text.trim(),
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
              CustomUnderlineTextField(controller: _memberControllers[fieldName], inputFormatters: kFormatterName, label: Globalization.name.tr),
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
              CustomUnderlineTextField(
                controller: _memberControllers[fieldAddress1],
                inputFormatters: kFormatterAddress,
                label: "${Globalization.addressLine.tr} 1",
              ),
              CustomUnderlineTextField(
                controller: _memberControllers[fieldAddress2],
                inputFormatters: kFormatterAddress,
                label: "${Globalization.addressLine.tr} 2",
              ),
              CustomUnderlineTextField(
                controller: _memberControllers[fieldAddress3],
                inputFormatters: kFormatterAddress,
                label: "${Globalization.addressLine.tr} 3",
              ),
              CustomUnderlineTextField(
                controller: _memberControllers[fieldAddress4],
                inputFormatters: kFormatterAddress,
                label: "${Globalization.addressLine.tr} 4",
              ),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(child: _buildPostcodeAutocomplete(_memberControllers[fieldPostcode], _memberControllers, Globalization.postcode.tr)),
                  Expanded(child: _buildPostcodeAutocomplete(_memberControllers[fieldCity], _memberControllers, Globalization.city.tr)),
                ],
              ),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(child: _buildPostcodeAutocomplete(_memberControllers[fieldState], _memberControllers, Globalization.state.tr)),
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
            title: Globalization.eInvoice.tr,
            children: <Widget>[
              _buildUnderlineDropdown(_memberControllers[fieldRegistrationSchemeID], _selectedSchemePersonal),
              CustomUnderlineTextField(
                controller: _memberControllers[fieldRegistrationSchemeNo],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[A-Z0-9]")), LengthLimitingTextInputFormatter(20)],
                label: Globalization.registrationSchemeNo.tr,
              ),
              CustomUnderlineTextField(
                controller: _memberControllers[fieldTIN],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[A-Z0-9]")), LengthLimitingTextInputFormatter(20)],
                label: Globalization.tin.tr,
              ),
              CustomUnderlineTextField(
                controller: _memberControllers[fieldSSTRegistrationNo],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[A-Z0-9]")), LengthLimitingTextInputFormatter(20)],
                label: Globalization.sstRegistration.tr,
              ),
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

  Widget _buildPostcodeAutocomplete(TextEditingController controller, ProfileDetailControllers profile, String label) => Autocomplete<PostcodeDetail>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      if (textEditingValue.text.isEmpty) return const Iterable<PostcodeDetail>.empty();

      final query = textEditingValue.text.toLowerCase();

      return _postcodes
          .where((item) => item.postcode.contains(query) || item.city.toLowerCase().contains(query) || item.stateName.toLowerCase().contains(query))
          .take(20);
    },
    displayStringForOption: (option) => "${option.postcode} - ${option.city}",
    onSelected: (PostcodeDetail selected) => setState(() {
      profile[fieldPostcode].text = selected.postcode;
      profile[fieldCity].text = selected.city;
      profile[fieldState].text = selected.stateName;
    }),
    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
      textEditingController.text = controller.text;

      return CustomUnderlineTextField(
        controller: textEditingController,
        focusNode: focusNode,
        label: label,
        onChanged: (value) => controller.text = value,
        onSubmitted: (value) => controller.text = value,
      );
    },
    optionsViewBuilder: (context, onSelected, options) => Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: SizedBox(
          height: 500.0,
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final item = options.elementAt(index);

              return ListTile(title: Text("${item.postcode} (${item.city})"), subtitle: Text(item.stateName), onTap: () => onSelected(item));
            },
          ),
        ),
      ),
    ),
  );

  Widget _buildUnderlineDropdown(TextEditingController controller, String initialSelection) => DropdownMenu<String>(
    controller: controller,
    width: double.infinity,
    dropdownMenuEntries: _schemeType.map<DropdownMenuEntry<String>>((String value) => DropdownMenuEntry<String>(value: value, label: value)).toList(),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87.withValues(alpha: 0.05))),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
      ),
    ),
    onSelected: (String? value) => setState(() {
      if (value != null) initialSelection = value;
    }),
    label: CustomText(
      Globalization.registrationSchemeID.tr,
      color: Theme.of(context).colorScheme.primary,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    selectedTrailingIcon: Icon(Icons.keyboard_arrow_up_rounded, color: Theme.of(context).colorScheme.primary),
    trailingIcon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.primary),
    initialSelection: initialSelection,
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
              CustomUnderlineTextField(controller: _workingControllers[fieldName], inputFormatters: kFormatterName, label: Globalization.name.tr),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldEmail],
                inputFormatters: kFormatterEmail,
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
              CustomUnderlineTextField(
                controller: _workingControllers[fieldAddress1],
                inputFormatters: kFormatterAddress,
                label: "${Globalization.addressLine.tr} 1",
              ),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldAddress2],
                inputFormatters: kFormatterAddress,
                label: "${Globalization.addressLine.tr} 2",
              ),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldAddress3],
                inputFormatters: kFormatterAddress,
                label: "${Globalization.addressLine.tr} 3",
              ),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldAddress4],
                inputFormatters: kFormatterAddress,
                label: "${Globalization.addressLine.tr} 4",
              ),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(child: _buildPostcodeAutocomplete(_workingControllers[fieldPostcode], _workingControllers, Globalization.postcode.tr)),
                  Expanded(child: _buildPostcodeAutocomplete(_workingControllers[fieldCity], _workingControllers, Globalization.city.tr)),
                ],
              ),
              Row(
                spacing: 32.dp,
                children: <Widget>[
                  Expanded(child: _buildPostcodeAutocomplete(_workingControllers[fieldState], _workingControllers, Globalization.state.tr)),
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
          CustomSectionCard(
            title: Globalization.eInvoice.tr,
            children: <Widget>[
              _buildUnderlineDropdown(_workingControllers[fieldRegistrationSchemeID], _selectedSchemeWorking),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldRegistrationSchemeNo],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[A-Z0-9]")), LengthLimitingTextInputFormatter(20)],
                label: Globalization.registrationSchemeNo.tr,
              ),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldTIN],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[A-Z0-9]")), LengthLimitingTextInputFormatter(20)],
                label: Globalization.tin.tr,
              ),
              CustomUnderlineTextField(
                controller: _workingControllers[fieldSSTRegistrationNo],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[A-Z0-9]")), LengthLimitingTextInputFormatter(20)],
                label: Globalization.sstRegistration.tr,
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
