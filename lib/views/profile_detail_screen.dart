import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/profile_controller.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
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

enum ProfileType { member, working }

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> with SingleTickerProviderStateMixin {
  final _memberHiveController = Get.find<MemberHiveController>();
  final _profileController = Get.find<ProfileController>();

  late ProfileDetailControllers _memberControllers;
  late ProfileDetailControllers _workingControllers;
  late TabController _tabController;

  bool _isRequired = false;
  PhoneDetail _phoneMember = PhoneDetail();
  PhoneDetail _phoneWorking = PhoneDetail();
  MemberProfileModel _memberProfile = MemberProfileModel.empty();
  WorkingProfileModel _workingProfile = WorkingProfileModel.empty();

  @override
  void initState() {
    super.initState();

    _memberHiveController.loadMemberHive();

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
    if (_memberHiveController.memberProfile.value == null) return;

    await _profileController.loadProfile(_memberHiveController.memberProfile.value!.memberCode, isMember ? ProfileType.member : ProfileType.working);

    if (isMember && _profileController.memberProfile.value != null) {
      _memberProfile = _profileController.memberProfile.value!;
      _memberControllers = ProfileDetailControllers(_memberProfile);
      await _phoneMember.update(_memberProfile.countryCode);
      setState(() {});
    } else if (!isMember && _profileController.workingProfile.value != null) {
      _workingProfile = _profileController.workingProfile.value!;
      _workingControllers = ProfileDetailControllers(_workingProfile);
      await _phoneWorking.update(_workingProfile.countryCode);
      setState(() {});
    }
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
      MessageHelper.show(AppStrings.msgEmptyPhone, backgroundColor: Colors.red, icon: Icons.error_rounded);
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
      gender: _memberControllers[fieldGender].text.trim(),
      dob: _memberControllers[fieldDOB].text.trim(),
      accountCode: _memberControllers[fieldAccountCode].text.trim(),
    );

    _profileController.updateProfile(data, ProfileType.member);
  }

  void _updateWorkingProfile() async {
    FocusScope.of(context).unfocus();

    if (_isRequired && !_workingControllers.validateRequiredFields()) {
      MessageHelper.show(AppStrings.msgRequiredEInvoice, backgroundColor: Colors.red, icon: Icons.error_rounded);
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
      registrationSchemeID: _workingControllers[fieldRegistrationSchemeID].text.trim(),
      registrationSchemeNo: _workingControllers[fieldRegistrationSchemeNo].text.trim(),
    );

    _profileController.updateProfile(data, ProfileType.working);
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
      tabs: const <Tab>[
        Tab(text: AppStrings.member),
        Tab(text: AppStrings.working),
      ],
    ),
    title: Text(AppStrings.profile),
  );

  Widget _buildContent() => SliverFillRemaining(
    child: TabBarView(controller: _tabController, children: <Widget>[_buildMemberProfile(), _buildWorkingProfile()]),
  );

  Widget _buildMemberProfile() => CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ResponsiveHelper.getSpacing(context, SizeType.s),
          children: <Widget>[
            CustomProfileCard(image: AppStrings.tmpImgSplashLogo, memberCode: _memberProfile.memberCode, name: _memberProfile.name, onTapEdit: () {}),
            CustomSectionCard(
              title: AppStrings.basicInformation,
              children: <Widget>[
                CustomProfileTextField(controller: _memberControllers[fieldName], label: AppStrings.name),
                CustomProfileTextField(enabled: false, controller: _memberControllers[fieldEmail], label: AppStrings.email),
                CustomProfilePhoneTextField(
                  controller: _memberControllers[fieldContactNumber],
                  phone: _phoneMember,
                  label: AppStrings.phone,
                  onChanged: (value) => setState(() => _phoneMember = value),
                ),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, SizeType.xl),
                  children: <Widget>[
                    Expanded(
                      child: CustomProfileTextField(
                        controller: _memberControllers[fieldGender],
                        label: AppStrings.gender,
                        onTap: () async {
                          final pickedGender = await CustomTypePickerDialog.show<String>(
                            context: context,
                            title: AppStrings.pickGender,
                            options: AppStrings().genders,
                            onDisplay: (option) => option,
                          );

                          if (pickedGender != null) _memberControllers[fieldGender].text = pickedGender;
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomProfileTextField(
                        controller: _memberControllers[fieldDOB],
                        label: AppStrings.dob,
                        onTap: () => _selectDate(context, _memberControllers[fieldDOB]),
                      ),
                    ),
                  ],
                ),
                CustomProfileTextField(controller: _memberControllers[fieldAccountCode], label: AppStrings.accountCode),
              ],
            ),
            CustomSectionCard(
              title: AppStrings.address,
              children: <Widget>[
                CustomProfileTextField(controller: _memberControllers[fieldAddress1], label: "${AppStrings.addressLine} 1"),
                CustomProfileTextField(controller: _memberControllers[fieldAddress2], label: "${AppStrings.addressLine} 2"),
                CustomProfileTextField(controller: _memberControllers[fieldAddress3], label: "${AppStrings.addressLine} 3"),
                CustomProfileTextField(controller: _memberControllers[fieldAddress4], label: "${AppStrings.addressLine} 4"),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, SizeType.xl),
                  children: <Widget>[
                    Expanded(
                      child: CustomProfileTextField(controller: _memberControllers[fieldPostcode], label: AppStrings.postcode),
                    ),
                    Expanded(
                      child: CustomProfileTextField(controller: _memberControllers[fieldCity], label: AppStrings.city),
                    ),
                  ],
                ),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, SizeType.xl),
                  children: <Widget>[
                    Expanded(
                      child: CustomProfileTextField(controller: _memberControllers[fieldState], label: AppStrings.state),
                    ),
                    Expanded(
                      child: CustomProfileTextField(
                        controller: _memberControllers[fieldCountry],
                        label: AppStrings.country,
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
              title: AppStrings.registrationInformation,
              children: <Widget>[
                CustomProfileTextField(controller: _memberControllers[fieldTIN], label: AppStrings.tin),
                CustomProfileTextField(controller: _memberControllers[fieldSSTRegistrationNo], label: AppStrings.sstRegistration),
                CustomProfileTextField(controller: _memberControllers[fieldTTXRegistrationNo], label: AppStrings.ttxRegistration),
              ],
            ),
            const SizedBox(),
            Padding(
              padding: EdgeInsetsGeometry.only(
                bottom: ResponsiveHelper.getSpacing(context, SizeType.m),
                left: ResponsiveHelper.getSpacing(context, SizeType.m),
                right: ResponsiveHelper.getSpacing(context, SizeType.m),
              ),
              child: CustomFilledButton(label: AppStrings.saveChanges, onTap: () => _updateMemberProfile()),
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
          spacing: ResponsiveHelper.getSpacing(context, SizeType.s),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadiusM),
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withAlpha((0.25 * 255).round()),
                    blurRadius: kBlurRadius,
                    offset: const Offset(kOffsetX, kOffsetY),
                  ),
                ],
              ),
              margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(context, SizeType.l),
                vertical: ResponsiveHelper.getSpacing(context, SizeType.m),
              ),
              child: CheckboxListTile(
                value: _isRequired,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) => setState(() => _isRequired = value!),
                subtitle: _isRequired ? CustomText(AppStrings.msgRequiredEInvoice, fontSize: 14.0) : null,
                title: CustomText(
                  AppStrings.requiredEInvoice,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomSectionCard(
              title: AppStrings.companyInformation,
              children: <Widget>[
                CustomProfileTextField(controller: _workingControllers[fieldName], isRequired: _isRequired, label: AppStrings.name),
                CustomProfileTextField(controller: _workingControllers[fieldEmail], isRequired: _isRequired, label: AppStrings.email),
                CustomProfilePhoneTextField(
                  isRequired: _isRequired,
                  controller: _workingControllers[fieldContactNumber],
                  phone: _phoneWorking,
                  label: AppStrings.phone,
                  onChanged: (value) => setState(() => _phoneWorking = value),
                ),
              ],
            ),
            CustomSectionCard(
              title: AppStrings.address,
              children: <Widget>[
                CustomProfileTextField(controller: _workingControllers[fieldAddress1], isRequired: _isRequired, label: "${AppStrings.addressLine} 1"),
                CustomProfileTextField(controller: _workingControllers[fieldAddress2], label: "${AppStrings.addressLine} 2"),
                CustomProfileTextField(controller: _workingControllers[fieldAddress3], label: "${AppStrings.addressLine} 3"),
                CustomProfileTextField(controller: _workingControllers[fieldAddress4], label: "${AppStrings.addressLine} 4"),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, SizeType.xl),
                  children: <Widget>[
                    Expanded(
                      child: CustomProfileTextField(
                        controller: _workingControllers[fieldPostcode],
                        isRequired: _isRequired,
                        label: AppStrings.postcode,
                      ),
                    ),
                    Expanded(
                      child: CustomProfileTextField(controller: _workingControllers[fieldCity], isRequired: _isRequired, label: AppStrings.city),
                    ),
                  ],
                ),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, SizeType.xl),
                  children: <Widget>[
                    Expanded(
                      child: CustomProfileTextField(controller: _workingControllers[fieldState], isRequired: _isRequired, label: AppStrings.state),
                    ),
                    Expanded(
                      child: CustomProfileTextField(
                        isRequired: _isRequired,
                        controller: _workingControllers[fieldCountry],
                        label: AppStrings.country,
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
              title: AppStrings.registrationInformation,
              children: <Widget>[
                CustomIDTypeTextField(
                  typeController: _workingControllers[fieldRegistrationSchemeID],
                  valueController: _workingControllers[fieldRegistrationSchemeNo],
                  isRequired: _isRequired,
                  label: AppStrings.registrationSchemeID,
                ),
                CustomProfileTextField(controller: _workingControllers[fieldTIN], isRequired: _isRequired, label: AppStrings.tin),
                CustomProfileTextField(controller: _workingControllers[fieldSSTRegistrationNo], label: AppStrings.sstRegistration),
                CustomProfileTextField(
                  controller: _workingControllers[fieldTTXRegistrationNo],
                  isRequired: _isRequired,
                  label: AppStrings.ttxRegistration,
                ),
                CustomProfileTextField(controller: _workingControllers[fieldROC], isRequired: _isRequired, label: AppStrings.roc),
                CustomProfileTextField(controller: _workingControllers[fieldMSICCode], isRequired: _isRequired, label: AppStrings.msicCode),
              ],
            ),
            const SizedBox(),
            Padding(
              padding: EdgeInsetsGeometry.only(
                bottom: ResponsiveHelper.getSpacing(context, SizeType.m),
                left: ResponsiveHelper.getSpacing(context, SizeType.m),
                right: ResponsiveHelper.getSpacing(context, SizeType.m),
              ),
              child: CustomFilledButton(label: AppStrings.saveChanges, onTap: () => _updateWorkingProfile()),
            ),
          ],
        ),
      ),
    ],
  );
}
