import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/profile_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _profileController = Get.put(ProfileController(), tag: "changePassword");
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ever(_profileController.isUpdate, (updated) {
      if (updated == true) {
        _oldController.clear();
        _newController.clear();
        _confirmController.clear();
      }
    });
  }

  void _changePassword() {
    FocusScope.of(context).unfocus();

    if (!_isFieldValid()) return;

    final Map<String, dynamic> data = {
      "member_code": _hive.memberProfile.value!.memberCode,
      "old_password": _oldController.text.trim(),
      "new_password": _newController.text.trim(),
    };

    _profileController.changePassword(data, _hive.memberProfile.value!.token);
  }

  bool _isFieldValid() {
    final String oldPwd = _oldController.text.trim();
    final String newPwd = _newController.text.trim();
    final String confirmPwd = _confirmController.text.trim();

    String? message;

    if (oldPwd.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.oldPassword.tr});
    } else if (newPwd.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.newPassword.tr});
    } else if (confirmPwd.isEmpty) {
      message = Globalization.msgRequired.trParams({"label": Globalization.confirmPassword.tr});
    } else if (newPwd != confirmPwd) {
      message = Globalization.msgPasswordMismatch.tr;
    }

    if (message != null) MessageHelper.show(message, icon: Icons.warning_rounded);

    return message == null;
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(title: Text(Globalization.changePassword.tr)),
    body: _buildContent(),
  );

  Widget _buildContent() => CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: ResponsiveHelper.getSpacing(context, 16.0),
            children: <Widget>[
              Image.asset("assets/images/change_password.png", scale: kSquareRatio, height: ResponsiveHelper.getAuthImgSize(context)),
              CustomOutlinedTextField(
                controller: _oldController,
                icon: Icons.lock_rounded,
                type: OutlinedType.password,
                label: Globalization.oldPassword.tr,
              ),
              CustomOutlinedTextField(
                controller: _newController,
                icon: Icons.lock_rounded,
                type: OutlinedType.password,
                label: Globalization.newPassword.tr,
              ),
              CustomOutlinedTextField(
                controller: _confirmController,
                icon: Icons.lock_rounded,
                type: OutlinedType.password,
                label: Globalization.confirmPassword.tr,
              ),
              const SizedBox(),
              CustomFilledButton(label: Globalization.changePassword.tr, onTap: () => _changePassword()),
            ],
          ),
        ),
      ),
    ],
  );
}
