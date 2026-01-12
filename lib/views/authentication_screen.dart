import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/controllers/authentication_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
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
  final Map<AuthType, String> _authTypes = {AuthType.email: Globalization.email.tr, AuthType.phone: Globalization.phone.tr};
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
        message = Globalization.msgRequired.trParams({"label": Globalization.username.tr});
      } else if (email.isEmpty) {
        message = Globalization.msgRequired.trParams({"label": Globalization.email.tr});
      } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
        message = Globalization.msgEmailInvalidFormat.tr;
      } else if (phone.isEmpty) {
        message = Globalization.msgRequired.trParams({"label": Globalization.phone.tr});
      } else if (!RegExp(r"^\d{6,12}$").hasMatch(phone)) {
        message = Globalization.msgPhoneInvalidFormat.tr;
      }
    } else {
      // Sign in validation
      if ((_selectedType == AuthType.email) && email.isEmpty) {
        message = Globalization.msgRequired.trParams({"label": Globalization.email.tr});
      } else if ((_selectedType == AuthType.phone) && phone.isEmpty) {
        message = Globalization.msgRequired.trParams({"label": Globalization.phone.tr});
      } else if (password.isEmpty) {
        message = Globalization.msgRequired.trParams({"label": Globalization.password.tr});
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
    child: Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildContent()]),
    ),
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
        Tab(text: Globalization.signIn.tr),
        Tab(text: Globalization.signUp.tr),
      ],
    ),
    title: Text(Globalization.welcome.tr),
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
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: ResponsiveHelper.getSpacing(context, 16.0),
              children: <Widget>[
                Image.asset("assets/images/sign_in.png", scale: kSquareRatio, height: ResponsiveHelper.getAuthImgSize(context)),
                CustomText(Globalization.msgSignIn.tr, fontSize: 12.0, maxLines: 2, textAlign: TextAlign.center),
                CustomChoiceChip(values: _authTypes, selectedValue: _selectedType, onSelected: (type) => setState(() => _selectedType = type)),
                if (isEmail)
                  CustomOutlinedTextField(
                    controller: _emailController,
                    icon: Icons.email_rounded,
                    type: OutlinedType.text,
                    label: Globalization.email.tr,
                    keyboardType: TextInputType.emailAddress,
                  ),
                if (!isEmail)
                  CustomOutlinedTextField(
                    controller: _phoneController,
                    type: OutlinedType.phone,
                    phone: _phone,
                    label: Globalization.phone.tr,
                    keyboardType: TextInputType.phone,
                    onPhoneChanged: (value) => setState(() => _phone = value),
                  ),
                CustomOutlinedTextField(
                  controller: _passwordController,
                  icon: Icons.lock_rounded,
                  type: OutlinedType.password,
                  label: Globalization.password.tr,
                ),
                _buildForgotPassword(),
                CustomFilledButton(label: Globalization.signIn.tr, onTap: _signIn),
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
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: ResponsiveHelper.getSpacing(context, 16.0),
            children: <Widget>[
              Image.asset("assets/images/sign_up.png", scale: kSquareRatio, height: ResponsiveHelper.getAuthImgSize(context)),
              CustomText(Globalization.msgSignUp.tr, fontSize: 12.0, maxLines: 2, textAlign: TextAlign.center),
              CustomOutlinedTextField(
                controller: _usernameController,
                icon: Icons.account_circle_rounded,
                type: OutlinedType.text,
                label: Globalization.username.tr,
              ),
              CustomOutlinedTextField(
                controller: _emailController,
                icon: Icons.email_rounded,
                type: OutlinedType.text,
                label: Globalization.email.tr,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomOutlinedTextField(
                controller: _phoneController,
                type: OutlinedType.phone,
                phone: _phone,
                label: Globalization.phone.tr,
                keyboardType: TextInputType.phone,
                onPhoneChanged: (value) => setState(() => _phone = value),
              ),
              const SizedBox(),
              CustomFilledButton(label: Globalization.signUp.tr, onTap: _signUp),
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
      child: CustomText(Globalization.forgotPassword.tr, color: Theme.of(context).colorScheme.primary, fontSize: 14.0, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildAuthMessage(bool isSignIn) => RichText(
    text: TextSpan(
      text: isSignIn ? Globalization.msgAccountNotExists.tr : Globalization.msgAccountExists.tr,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black87, fontSize: 14.0),
      children: <TextSpan>[
        TextSpan(
          recognizer: TapGestureRecognizer()..onTap = () => _tabController.index = isSignIn ? 1 : 0,
          text: isSignIn ? Globalization.signUp.tr : Globalization.signIn.tr,
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
      ],
    ),
    textAlign: TextAlign.center,
    textScaler: TextScaler.linear(ResponsiveHelper.getTextScaler(context)),
  );
}
