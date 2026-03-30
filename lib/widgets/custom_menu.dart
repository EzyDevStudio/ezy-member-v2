import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/controllers/settings_controller.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/widgets/custom_image.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomMenu extends StatefulWidget {
  final String title;
  final Widget? child;

  const CustomMenu({super.key, required this.title, this.child});

  @override
  State<CustomMenu> createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  final _hive = Get.find<MemberHiveController>();
  final _settingsController = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();
  }

  void _signOut() async {
    final bool? result = await MessageHelper.confirmation(message: Globalization.msgSignOutConfirmation.tr, title: Globalization.signOut.tr);

    if (result == true) {
      await _hive.signOut();
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SizedBox(
        width: kMenuWidth,
        child: CustomBackgroundImage(
          cacheImage: _hive.backgroundImage,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(24.dp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 36.dp,
                  children: <Widget>[
                    Image.asset("assets/images/app_logo.png", alignment: Alignment.centerLeft, height: 30.0),
                    Row(
                      spacing: 16.dp,
                      children: <Widget>[
                        CustomAvatarImage(
                          showEdit: true,
                          size: kProfileImgSizeS,
                          cacheImage: _hive.image,
                          onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.signIn),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CustomText(
                                _hive.isSignIn ? _hive.memberProfile.value!.name : Globalization.guest.tr,
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              if (_hive.isSignIn)
                                CustomText(
                                  _hive.memberProfile.value!.memberCode.displayMemberCode,
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(color: Theme.of(context).colorScheme.surfaceContainerLowest, height: 0.0),
              _buildMenuListTile(Globalization.home.tr, () => Get.offAllNamed(AppRoutes.home), icon: Icons.home_rounded),
              if (_hive.isSignIn)
                _buildMenuListTile(
                  Globalization.notifications.tr,
                  () => Get.offAllNamed(AppRoutes.notification),
                  showBadge: true,
                  icon: Icons.notifications_rounded,
                ),
              if (_hive.isSignIn)
                _buildMenuListTile(
                  Globalization.myVouchers.tr,
                  () => Get.offAllNamed(AppRoutes.voucherList, arguments: {"check_start": 0}),
                  image: "assets/icons/my_vouchers.png",
                ),
              if (_hive.isSignIn)
                _buildMenuListTile(Globalization.myCards.tr, () => Get.offAllNamed(AppRoutes.memberList), image: "assets/icons/my_members.png"),
              _buildMenuListTile(Globalization.findShop.tr, () => Get.offAllNamed(AppRoutes.companyList), image: "assets/icons/find_shops.png"),
            ],
          ),
        ),
      ),
      Expanded(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: false,
            backgroundColor: Colors.white,
            actions: _buildAppBarAction(),
            title: Text(widget.title, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          body: widget.child,
        ),
      ),
    ],
  );

  List<Widget> _buildAppBarAction() => [
    PopupMenuButton<Locale>(
      onSelected: (locale) => _settingsController.changeLanguage(locale),
      itemBuilder: (context) => Globalization.languages.entries
          .map((entry) => PopupMenuItem<Locale>(value: entry.value, child: CustomText(entry.key, fontSize: 14.0)))
          .toList(),
      icon: Icon(Icons.language_rounded, color: isDesktop ? Theme.of(context).colorScheme.primary : Colors.white),
    ),
    if (_hive.isSignIn)
      IconButton(
        onPressed: _signOut,
        icon: Icon(Icons.logout_rounded, color: isDesktop ? Theme.of(context).colorScheme.primary : Colors.white),
      ),
  ];

  Widget _buildMenuListTile(String label, VoidCallback onTap, {bool showBadge = false, IconData? icon, String? image}) => ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 24.dp, vertical: 8.dp),
    onTap: onTap,
    leading: icon != null ? Icon(icon, color: Colors.white, size: kMenuIconSize) : Image.asset(image!, height: kMenuIconSize, scale: kSquareRatio),
    title: CustomText(label, color: Colors.white, fontSize: 14.0),
    trailing: showBadge ? Badge(smallSize: 10.dp) : null,
  );
}
