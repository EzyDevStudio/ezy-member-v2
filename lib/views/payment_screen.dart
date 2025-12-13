import 'dart:async';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_bar_code/code/code.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _hive = Get.find<MemberHiveController>();

  late int _remainingSeconds = const Duration(minutes: 5).inSeconds;
  late ScanType _scanType;
  late String? _value;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _scanType = args["scan_type"] ?? ScanType.point;
    _value = args["value"];

    if (_scanType != ScanType.point) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;

        setState(() => _remainingSeconds--);

        if (_remainingSeconds <= 0) _timer?.cancel();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds <= 0) return "code_expired".tr;

    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    return "msg_expired_timer".trParams({"minutes": minutes.toString(), "seconds": seconds.toString().padLeft(2, "0")});
  }

  Future<void> _onRefresh() async {
    _hive.loadMemberHive();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.primary,
    appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.primary, title: Text("pay".tr)),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Center(
            child: Image.asset(AppStrings.tmpImgAppLogo, fit: BoxFit.scaleDown, color: Colors.white),
          ),
        ),
        Expanded(flex: 5, child: _buildContent()),
      ],
    ),
  );

  Widget _buildContent() => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: ResponsiveHelper.mobileBreakpoint, maxWidth: ResponsiveHelper.mobileBreakpoint),
      child: AspectRatio(
        aspectRatio: kSquareRatio,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusM), color: Colors.white),
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.xl)),
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.l)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (_hive.isSignIn)
                CustomText(
                  _hive.memberProfile.value!.memberCode,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              if (_value != null && _scanType == ScanType.point) ..._buildBarcode(_value!),
              if (_value != null && _scanType != ScanType.point) ..._buildQRCode(_value!),
              if (_scanType != ScanType.point)
                CustomText(_formatTime(_remainingSeconds), color: Theme.of(context).colorScheme.error, fontSize: 24.0, fontWeight: FontWeight.w700),
            ],
          ),
        ),
      ),
    ),
  );

  List<Widget> _buildQRCode(String value) => [
    Expanded(child: SizedBox()),
    Expanded(
      flex: 5,
      child: Code(
        drawText: false,
        codeType: CodeType.qrCode(),
        backgroundColor: Colors.white,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS), color: Colors.white),
        data: value,
      ),
    ),
    Expanded(child: SizedBox()),
  ];

  List<Widget> _buildBarcode(String value) => [
    const Spacer(),
    AspectRatio(
      aspectRatio: 3 / 1,
      child: Code(
        drawText: false,
        codeType: CodeType.code39(),
        backgroundColor: Colors.white,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS), color: Colors.white),
        data: value,
      ),
    ),
    const Spacer(),
  ];
}
