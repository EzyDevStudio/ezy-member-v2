import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(body: CustomScrollView(slivers: <Widget>[_buildContent()]));

  Widget _buildContent() => SliverFillRemaining(
    hasScrollBody: false,
    child: Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.l)),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/welcome.png", scale: kSquareRatio, width: ResponsiveHelper.getWelcomeImgSize(context) - 100.0),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.getWelcomeImgSize(context) + 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
              children: <Widget>[
                CustomText("welcome".tr, color: Theme.of(context).colorScheme.primary, fontSize: 18.0, fontWeight: FontWeight.w700),
                CustomText("msg_welcome".tr, fontSize: 14.0, maxLines: null),
                _buildOptionTile(() => Get.toNamed(AppRoutes.authentication), "msg_continue_sign_in".tr, "sign_in_account".tr),
                _buildOptionTile(() => Get.offAllNamed(AppRoutes.home), "msg_continue_guest".tr, "continue_guest".tr),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildOptionTile(VoidCallback onTap, String subtitle, String title) => Material(
    borderRadius: BorderRadius.circular(kBorderRadiusS),
    elevation: kElevation,
    child: InkWell(
      borderRadius: BorderRadius.circular(kBorderRadiusS),
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getSpacing(context, SizeType.l),
          vertical: ResponsiveHelper.getSpacing(context, SizeType.xs),
        ),
        subtitle: CustomText(subtitle, fontSize: 14.0, maxLines: null),
        title: CustomText(title, color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.w700),
        trailing: Icon(Icons.arrow_forward_ios_rounded),
      ),
    ),
  );
}
