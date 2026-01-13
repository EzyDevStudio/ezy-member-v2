import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/controllers/profile_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_text_field.dart';
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
      MessageHelper.show(Globalization.msgRequired.trParams({"label": Globalization.email.tr}), icon: Icons.warning_rounded);
      return;
    }

    _profileController.forgotPassword({"email": _emailController.text.trim()});
    _emailController.clear();

    MessageHelper.show(Globalization.msgPasswordEmailSent.tr, duration: Duration(seconds: 10), icon: Icons.check_circle_rounded);
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(title: Text(Globalization.resetPassword)),
    body: _buildContent(),
  );

  Widget _buildContent() => CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16.dp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.dp,
            children: <Widget>[
              Image.asset("assets/images/forgot_password.png", scale: kSquareRatio, height: ResponsiveHelper().authSize()),
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
      ),
    ],
  );
}
