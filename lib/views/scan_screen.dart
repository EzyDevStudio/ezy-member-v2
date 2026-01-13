import 'dart:async';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/pin_controller.dart';
import 'package:ezy_member_v2/helpers/cipher_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_bar_code/code/code.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _pinController = Get.put(PinController(), tag: "scan");

  late ScanType _type;
  late String? _companyID, _value;

  int _remainingSeconds = 120;
  String _title = Globalization.earnPoints.tr;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    final args = Get.arguments ?? {};

    _type = args["scan_type"] ?? ScanType.earnPoints;
    _companyID = args["company_id"];
    _value = args["value"];

    if (_type != ScanType.earnPoints) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());

      _title = _type == ScanType.redeemPoints
          ? Globalization.redeemPoint.tr
          : (_type == ScanType.redeemVoucher ? Globalization.redeemVoucher.tr : Globalization.redeemCredit.tr);
    }
  }

  Future<void> _onRefresh() async {
    if (_companyID != null) _pinController.generatePin(_companyID!, _hive.memberProfile.value!.memberCode, _hive.memberProfile.value!.token, _value);
  }

  void _startTimer(DateTime expiredDate) {
    final now = DateTime.now().toUtc();

    _timer?.cancel();
    _remainingSeconds = expiredDate.difference(now).inSeconds;

    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) _timer?.cancel();
    });
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds <= 0) return Globalization.codeExpired.tr;

    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    return Globalization.msgExpiredTimer.trParams({"minutes": minutes.toString(), "seconds": seconds.toString().padLeft(2, "0")});
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.primary, title: Text(_title)),
    body: _buildContent(),
  );

  Widget _buildContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      SizedBox(height: 50.0, child: Image.asset("assets/images/splash_logo.png", fit: BoxFit.scaleDown)),
      LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxHeight: ResponsiveHelper.mobileBreakpoint, maxWidth: ResponsiveHelper.mobileBreakpoint),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kBorderRadiusS),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 10)],
              ),
              height: size,
              width: size,
              margin: EdgeInsets.all(32.dp),
              padding: EdgeInsets.all(32.dp),
              child: Center(child: _type == ScanType.earnPoints ? _buildEarnSection() : _buildRedeemSection()),
            ),
          );
        },
      ),
      CustomText(
        _hive.memberProfile.value!.memberCode,
        color: Theme.of(context).colorScheme.primary,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.center,
      ),
      if (_type != ScanType.earnPoints)
        CustomText(_formatTime(_remainingSeconds), color: Theme.of(context).colorScheme.error, fontSize: 22.0, textAlign: TextAlign.center),
    ],
  );

  Widget _buildRedeemSection() => Obx(() {
    if (_pinController.isLoading.value) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    if (_pinController.pin.value != null) {
      _startTimer(_pinController.pin.value!.expiredDate.toLocal());
    }

    return FutureBuilder<String>(
      future: CipherHelper().encryption(_pinController.pin.value.toString()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
        }

        final encryptedValue = snapshot.data!;

        return _buildQRCode(encryptedValue);
      },
    );
  });

  Widget _buildEarnSection() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: 32.dp,
    children: <Widget>[
      AspectRatio(
        aspectRatio: 3 / 1,
        child: Code(drawText: false, codeType: CodeType.code128(), backgroundColor: Colors.white, data: _hive.memberProfile.value!.memberCode),
      ),
      _buildQRCode(_hive.memberProfile.value!.memberCode),
    ],
  );

  Widget _buildQRCode(String value) => Code(drawText: false, codeType: CodeType.qrCode(), backgroundColor: Colors.white, data: value);
}
