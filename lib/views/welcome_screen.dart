import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(body: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildContent(size)]));
  }

  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    pinned: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    title: SizedBox(
      height: kToolbarHeight * kAppBarLogoRatio,
      child: Image.asset(AppStrings.tmpImgAppLogo, fit: BoxFit.fitHeight, color: Colors.white),
    ),
  );

  Widget _buildContent(Size size) => SliverFillRemaining(
    hasScrollBody: false,
    child: Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.l)),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.getWelcomeMaxWidth(context) - 100.0),
            child: Image.asset(AppStrings.tmpImgWelcome, fit: BoxFit.scaleDown, scale: kSquareRatio, width: size.width * 0.5),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.getWelcomeMaxWidth(context) + 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
              children: <Widget>[
                CustomText(AppStrings.welcome, color: Theme.of(context).colorScheme.primary, fontSize: 18.0, fontWeight: FontWeight.w700),
                CustomText(AppStrings.msgWelcome, fontSize: 14.0, maxLines: null),
                _buildOptionTile(() => Get.toNamed(AppRoutes.authentication), AppStrings.msgContinueSignIn, AppStrings.signInAccount),
                _buildOptionTile(() => Get.offAllNamed(AppRoutes.home), AppStrings.msgContinueGuest, AppStrings.continueGuest),
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
