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

  Future<void> _onRefresh() async {}

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.primary,
    appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.primary, title: Text("pay".tr)),
    body: _buildContent(),
  );

  Widget _buildContent() => Center(
    child: AspectRatio(
      aspectRatio: kSquareRatio,
      child: Container(
        constraints: BoxConstraints(maxHeight: ResponsiveHelper.mobileBreakpoint, maxWidth: ResponsiveHelper.mobileBreakpoint),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusM), color: Colors.white),
        margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.xl)),
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
        child: Column(
          spacing: ResponsiveHelper.getSpacing(context, SizeType.s),
          children: <Widget>[
            SizedBox(height: 50.0, child: Image.asset(AppStrings.tmpImgAppLogo, fit: BoxFit.scaleDown)),
            const Spacer(),
            if (_value != null && _scanType == ScanType.point) _buildBarcode(_value!),
            if (_value != null && _scanType != ScanType.point) _buildQRCode(_value!),
            const Spacer(),
            CustomText(
              _hive.memberProfile.value!.memberCode,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            if (_scanType != ScanType.point) CustomText(_formatTime(_remainingSeconds), color: Theme.of(context).colorScheme.error, fontSize: 22.0),
          ],
        ),
      ),
    ),
  );

  Widget _buildBarcode(String value) => AspectRatio(
    aspectRatio: 4 / 1,
    child: Code(
      drawText: false,
      codeType: CodeType.code39(),
      backgroundColor: Colors.white,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS)),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.xl)),
      data: value,
    ),
  );

  Widget _buildQRCode(String value) => Code(
    drawText: false,
    codeType: CodeType.qrCode(),
    backgroundColor: Colors.white,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS)),
    data: value,
  );
}
