import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/controllers/authentication_controller.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/phone_detail.dart';
import 'package:ezymember/models/profile_model.dart';
import 'package:ezymember/widgets/custom_button.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthenticationController _authController = Get.put(AuthenticationController(), tag: "sign_up");
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  PhoneDetail _phone = PhoneDetail();

  void _signUp() {
    FocusScope.of(context).unfocus();

    if (!_isFieldValid(false)) return;

    String contactNumber = "";

    if (_phoneController.text.trim().isNotEmpty) contactNumber = int.parse(_phoneController.text.trim()).toString();

    final Map<String, dynamic> data = MemberProfileModel.toJsonSignUp(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _phone.dialCode,
      contactNumber,
    );

    _authController.signUp(data);
  }

  bool _isFieldValid(bool isSignIn) {
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String username = _usernameController.text.trim();

    String? message;

    if (username.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.username.tr});
    } else if (email.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.email.tr});
    } else if (!RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(email)) {
      message = Globalization.msgEmailInvalidFormat.tr;
    } else if (phone.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.phone.tr});
    } else if (!RegExp(r"^\d{6,12}$").hasMatch(phone)) {
      message = Globalization.msgPhoneInvalidFormat.tr;
    }

    if (message != null) MessageHelper.warning(message: message);

    return message == null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();

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
      onPressed: () => Get.back(),
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    ),
    title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
  );

  Widget _buildContent() => SliverFillRemaining(
    hasScrollBody: false,
    child: Padding(
      padding: EdgeInsets.all(25.dp),
      child: Wrap(
        runSpacing: 25.dp,
        spacing: 25.dp,
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/sign_up.png", scale: kSquareRatio, width: rsp.welcomeSize() - 100.0),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rsp.welcomeSize() + 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 15.dp,
              children: <Widget>[
                CustomText(Globalization.signUp.tr, color: Theme.of(context).colorScheme.primary, fontSize: 18.0, fontWeight: FontWeight.w700),
                CustomText(Globalization.msgSignUp.tr, fontSize: 14.0, maxLines: null),
                CustomOutlinedTextField(
                  controller: _usernameController,
                  icon: Icons.account_circle_rounded,
                  inputFormatters: kFormatterName,
                  type: OutlinedType.text,
                  label: Globalization.username.tr,
                ),
                CustomOutlinedTextField(
                  controller: _emailController,
                  icon: Icons.email_rounded,
                  inputFormatters: kFormatterEmail,
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
                RichText(
                  text: TextSpan(
                    text: Globalization.msgAccountExists.tr,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14.sp),
                    children: <TextSpan>[
                      TextSpan(
                        mouseCursor: SystemMouseCursors.click,
                        recognizer: TapGestureRecognizer()..onTap = () => Get.offNamed(AppRoutes.signIn),
                        text: Globalization.signIn.tr,
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
