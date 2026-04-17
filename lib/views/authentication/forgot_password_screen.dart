import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/controllers/profile_controller.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/widgets/custom_button.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _profileController = Get.put(ProfileController(), tag: "forgotPassword");
  final TextEditingController _emailController = TextEditingController();

  void _forgotPassword() {
    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty) {
      MessageHelper.warning(message: Globalization.msgRequired.trParams({"label": Globalization.email.tr}));
      return;
    }

    _profileController.forgotPassword({"email": _emailController.text.trim()});
    _emailController.clear();

    MessageHelper.success(message: Globalization.msgPasswordEmailSent.tr);
  }

  @override
  void dispose() {
    _emailController.dispose();

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
      onPressed: () => AppRoutes.back(destination: AppRoutes.signIn),
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
          Image.asset("assets/images/forgot_password.png", scale: kSquareRatio, width: rsp.welcomeSize() - 100.0),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rsp.welcomeSize() + 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16.dp,
              children: <Widget>[
                CustomText(Globalization.resetPassword.tr, color: Theme.of(context).colorScheme.primary, fontSize: 18.0, fontWeight: FontWeight.w700),
                CustomText(Globalization.msgResetPassword.tr, fontSize: 14.0, maxLines: null),
                CustomOutlinedTextField(
                  controller: _emailController,
                  icon: Icons.lock_rounded,
                  inputFormatters: kFormatterEmail,
                  type: OutlinedType.text,
                  label: Globalization.email.tr,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(),
                CustomFilledButton(label: Globalization.confirm.tr, onTap: () => _forgotPassword()),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, minimumSize: Size.zero),
                    onPressed: () => AppRoutes.back(destination: AppRoutes.signIn),
                    child: CustomText(
                      Globalization.backToSignIn.tr,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
