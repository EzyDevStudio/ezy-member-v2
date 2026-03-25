import 'package:ezymember/constants/app_constants.dart';
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() => ListView(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.all(16.dp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.dp,
          children: <Widget>[
            Image.asset("assets/images/forgot_password.png", scale: kSquareRatio, height: rsp.authSize()),
            CustomText(Globalization.msgResetPassword.tr, fontSize: 16.0, maxLines: null, textAlign: TextAlign.center),
            CustomOutlinedTextField(
              controller: _emailController,
              icon: Icons.lock_rounded,
              type: OutlinedType.text,
              label: Globalization.email.tr,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(),
            CustomFilledButton(label: Globalization.confirm.tr, onTap: () => _forgotPassword()),
          ],
        ),
      ),
    ],
  );
}
