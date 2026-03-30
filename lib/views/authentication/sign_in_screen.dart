import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/controllers/authentication_controller.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/phone_detail.dart';
import 'package:ezymember/models/profile_model.dart';
import 'package:ezymember/services/local/connection_service.dart';
import 'package:ezymember/services/remote/google_sign_in_service.dart';
import 'package:ezymember/widgets/custom_button.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthenticationController _authController = Get.put(AuthenticationController(), tag: "authentication");
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isEmail = true;
  PhoneDetail _phone = PhoneDetail();

  void _signIn() {
    FocusScope.of(context).unfocus();

    if (!_isFieldValid(true)) return;

    String contactNumber = "";

    if (_phoneController.text.trim().isNotEmpty) contactNumber = int.parse(_phoneController.text.trim()).toString();

    final Map<String, dynamic> data = MemberProfileModel.toJsonSignIn(
      _isEmail ? _emailController.text.trim() : "",
      _phone.dialCode,
      !_isEmail ? contactNumber : "",
      _passwordController.text.trim(),
    );

    _authController.signIn(data);
  }

  void _signInWithGoogle() async {
    if (!await ConnectionService.checkConnection()) return;

    final userCredential = await GoogleSignInService.signInWithGoogle();

    if (userCredential == null) return;
    if (userCredential.user == null) return;

    _authController.signInWithGoogle(userCredential.user!.email!);
  }

  // Field validation, if "true" then continue sign in or up
  bool _isFieldValid(bool isSignIn) {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String phone = _phoneController.text.trim();

    String? message;

    if ((_isEmail) && email.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.email.tr});
    } else if ((!_isEmail) && phone.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.phone.tr});
    } else if (password.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.password.tr});
    }

    if (message != null) MessageHelper.warning(message: message);
    // If there is any error message then "false"
    return message == null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    rsp.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: CustomScrollView(slivers: <Widget>[_buildContent()]),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    leading: IconButton(
      onPressed: () => AppRoutes.backAuth(),
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    ),
    title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
  );

  Widget _buildContent() => SliverFillRemaining(
    hasScrollBody: false,
    child: Padding(
      padding: EdgeInsets.all(24.dp),
      child: Wrap(
        runSpacing: 24.dp,
        spacing: 24.dp,
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/sign_in.png", scale: kSquareRatio, width: rsp.welcomeSize() - 100.0),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rsp.welcomeSize() + 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16.dp,
              children: <Widget>[
                CustomText(Globalization.signIn.tr, color: Theme.of(context).colorScheme.primary, fontSize: 18.0, fontWeight: FontWeight.w700),
                CustomText(Globalization.msgSignIn.tr, fontSize: 14.0, maxLines: null),
                if (_isEmail)
                  CustomOutlinedTextField(
                    controller: _emailController,
                    icon: Icons.email_rounded,
                    type: OutlinedType.text,
                    label: Globalization.email.tr,
                    keyboardType: TextInputType.emailAddress,
                  ),
                if (!_isEmail)
                  CustomOutlinedTextField(
                    controller: _phoneController,
                    type: OutlinedType.phone,
                    phone: _phone,
                    label: Globalization.phone.tr,
                    keyboardType: TextInputType.phone,
                    onPhoneChanged: (value) => setState(() => _phone = value),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, minimumSize: Size.zero),
                    onPressed: () => setState(() => _isEmail = !_isEmail),
                    child: CustomText(
                      _isEmail ? Globalization.signInWithMobile.tr : Globalization.signInWithEmail.tr,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CustomOutlinedTextField(
                  controller: _passwordController,
                  icon: Icons.lock_rounded,
                  type: OutlinedType.password,
                  label: Globalization.password.tr,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, minimumSize: Size.zero),
                    onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                    child: CustomText(
                      Globalization.forgotPassword.tr,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(),
                CustomFilledButton(label: Globalization.signIn.tr, onTap: _signIn),
                CustomText("- ${Globalization.or.tr} -", fontSize: 14.0, maxLines: 1, textAlign: TextAlign.center),
                Align(
                  alignment: Alignment.center,
                  child: CustomIconButton(assetName: "assets/icons/google.png", onPressed: () => _signInWithGoogle()),
                ),
                RichText(
                  text: TextSpan(
                    text: Globalization.msgAccountNotExists.tr,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14.sp),
                    children: <TextSpan>[
                      TextSpan(
                        mouseCursor: SystemMouseCursors.click,
                        recognizer: TapGestureRecognizer()..onTap = () => Get.offNamed(AppRoutes.signUp),
                        text: Globalization.signUp.tr,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
