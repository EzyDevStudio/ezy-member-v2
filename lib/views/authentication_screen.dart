import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/authentication_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/phone_detail.dart';
import 'package:ezy_member_v2/models/profile_model.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AuthType { email, phone }

enum TabType { signIn, signUp }

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> with SingleTickerProviderStateMixin {
  final AuthenticationController _authController = Get.put(AuthenticationController(), tag: "authentication");
  final Map<AuthType, String> _authTypes = {AuthType.email: AppStrings.email, AuthType.phone: AppStrings.phone};
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  late AuthType _selectedType = _authTypes.keys.first;
  late TabController _tabController;

  PhoneDetail _phone = PhoneDetail();

  @override
  void initState() {
    super.initState();

    ever(_authController.isSuccess, (success) {
      if (success == true && _tabController.index == 1) _tabController.index = 0;
    });

    _tabController = TabController(length: TabType.values.length, vsync: this);
    _tabController.addListener(() => _onTabChanged());
  }

  void _onTabChanged() {
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _usernameController.clear();
  }

  void _signIn() {
    FocusScope.of(context).unfocus();

    if (!_isFieldValid(true)) return;

    final Map<String, dynamic> data = MemberProfileModel.toJsonSignIn(
      _selectedType == AuthType.email ? _emailController.text.trim() : "",
      _phone.dialCode,
      _selectedType == AuthType.phone ? _phoneController.text.trim() : "",
      _passwordController.text.trim(),
    );

    _authController.signIn(data);
  }

  void _signUp() {
    FocusScope.of(context).unfocus();

    if (!_isFieldValid(false)) return;

    final Map<String, dynamic> data = MemberProfileModel.toJsonSignUp(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _phone.dialCode,
      _phoneController.text.trim(),
    );

    _authController.signUp(data);
  }

  // Field validation, if "true" then continue sign in or up
  bool _isFieldValid(bool isSignIn) {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String phone = _phoneController.text.trim();
    final String username = _usernameController.text.trim();

    String? message;

    if (!isSignIn) {
      // Sign up validation
      if (username.isEmpty) {
        message = AppStrings.msgEmptyUsername;
      } else if (email.isEmpty) {
        message = AppStrings.msgEmptyEmail;
      } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
        message = AppStrings.msgEmailFormatInvalid;
      } else if (phone.isEmpty) {
        message = AppStrings.msgEmptyPhone;
      } else if (!RegExp(r"^\d{6,12}$").hasMatch(phone)) {
        message = AppStrings.msgPhoneFormatInvalid;
      }
    } else {
      // Sign in validation
      if ((_selectedType == AuthType.email) && email.isEmpty) {
        message = AppStrings.msgEmptyEmail;
      } else if ((_selectedType == AuthType.phone) && phone.isEmpty) {
        message = AppStrings.msgEmptyPhone;
      } else if (password.isEmpty) {
        message = AppStrings.msgEmptyPassword;
      }
    }

    if (message != null) MessageHelper.show(message, icon: Icons.warning_rounded);
    // If there is any error message then "false"
    return message == null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: TabType.values.length,
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
        Tab(text: AppStrings.signIn),
        Tab(text: AppStrings.signUp),
      ],
    ),
    title: Text(AppStrings.welcome),
  );

  Widget _buildContent() => SliverFillRemaining(
    child: TabBarView(controller: _tabController, children: <Widget>[_buildSignInForm(), _buildSignUpForm()]),
  );

  Widget _buildSignInForm() {
    bool isEmail = _selectedType == AuthType.email;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
              children: <Widget>[
                Image.asset(AppStrings.tmpImgSignIn, scale: kSquareRatio, height: ResponsiveHelper.getAuthImgHeight(context)),
                CustomText(AppStrings.msgSignIn, fontSize: 12.0, maxLines: 2, textAlign: TextAlign.center),
                CustomChoiceChip(values: _authTypes, selectedValue: _selectedType, onSelected: (type) => setState(() => _selectedType = type)),
                if (isEmail) CustomOutlinedTextField(controller: _emailController, icon: Icons.email_rounded, label: AppStrings.email),
                if (!isEmail) CustomPhoneTextField(controller: _phoneController, phone: _phone, onChanged: (value) => setState(() => _phone = value)),
                CustomOutlinedTextField(controller: _passwordController, isPassword: true, icon: Icons.lock_rounded, label: AppStrings.password),
                _buildForgotPassword(),
                CustomFilledButton(label: AppStrings.signIn, onTap: _signIn),
                _buildAuthMessage(true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() => CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
            children: <Widget>[
              Image.asset(AppStrings.tmpImgSignUp, scale: kSquareRatio, height: ResponsiveHelper.getAuthImgHeight(context)),
              CustomText(AppStrings.msgSignUp, fontSize: 12.0, maxLines: 2, textAlign: TextAlign.center),
              CustomOutlinedTextField(controller: _usernameController, icon: Icons.account_circle_rounded, label: AppStrings.username),
              CustomOutlinedTextField(controller: _emailController, icon: Icons.email_rounded, label: AppStrings.email),
              CustomPhoneTextField(controller: _phoneController, phone: _phone, onChanged: (value) => setState(() => _phone = value)),
              const SizedBox(),
              CustomFilledButton(label: AppStrings.signUp, onTap: _signUp),
              _buildAuthMessage(false),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildForgotPassword() => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, minimumSize: Size.zero),
      onPressed: () {},
      child: CustomText(AppStrings.forgotPassword, color: Theme.of(context).colorScheme.primary, fontSize: 14.0, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildAuthMessage(bool isSignIn) => RichText(
    text: TextSpan(
      text: isSignIn ? AppStrings.msgAccountNotExist : AppStrings.msgAccountExists,
      style: TextStyle(color: Colors.black87, fontSize: 14.0),
      children: <TextSpan>[
        TextSpan(
          recognizer: TapGestureRecognizer()..onTap = () => _tabController.index = isSignIn ? 1 : 0,
          text: isSignIn ? AppStrings.signUp : AppStrings.signIn,
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
      ],
    ),
    textAlign: TextAlign.center,
    textScaler: TextScaler.linear(ResponsiveHelper.getTextScaler(context)),
  );
}
