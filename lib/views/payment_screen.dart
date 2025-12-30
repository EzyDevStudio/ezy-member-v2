import 'dart:async';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/pin_controller.dart';
import 'package:ezy_member_v2/helpers/cipher_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_bar_code/code/code.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _pinController = Get.put(PinController(), tag: "payment");

  late BenefitType _benefit;
  late ScanType _scan;
  late String _companyID;
  late String? _value;

  int _remainingSeconds = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    final args = Get.arguments ?? {};

    _benefit = args["benefit_type"] ?? BenefitType.point;
    _scan = args["scan_type"] ?? ScanType.barcode;
    _companyID = args["company_id"];
    _value = args["value"];

    if (_scan == ScanType.qrCode) WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _pinController.generatePin(_companyID, _hive.memberProfile.value!.memberCode, _hive.memberProfile.value!.token, _value);
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
    if (totalSeconds <= 0) return "code_expired".tr;

    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    return "msg_expired_timer".trParams({"minutes": minutes.toString(), "seconds": seconds.toString().padLeft(2, "0")});
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
    body: _buildContent(),
  );

  Widget _buildContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;

            return Center(
              child: Container(
                constraints: BoxConstraints(maxHeight: ResponsiveHelper.mobileBreakpoint, maxWidth: ResponsiveHelper.mobileBreakpoint),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusM), color: Colors.white),
                height: size,
                width: size,
                margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 32.0)),
                padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
                child: Column(
                  spacing: ResponsiveHelper.getSpacing(context, 8.0),
                  children: <Widget>[
                    SizedBox(height: 50.0, child: Image.asset("assets/images/splash_logo.png", fit: BoxFit.scaleDown)),
                    const Spacer(),
                    if (_scan == ScanType.barcode) ..._buildBarcodeSection(),
                    if (_scan != ScanType.barcode) ..._buildQRCodeSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      if (_benefit != BenefitType.voucher)
        CustomSegmentedButton(
          firstLabel: _benefit == BenefitType.point ? "earn".tr : "top_up".tr,
          secondLabel: "redeem".tr,
          onSelectionChanged: (ScanType selectedScanType) {
            setState(() => _scan = selectedScanType);
            if (_scan == ScanType.qrCode) _onRefresh();
          },
        ),
    ],
  );

  List<Widget> _buildBarcodeSection() => [
    _buildBarcode(),
    const Spacer(),
    CustomText(_hive.memberProfile.value!.memberCode, color: Theme.of(context).colorScheme.primary, fontSize: 24.0, fontWeight: FontWeight.bold),
  ];

  List<Widget> _buildQRCodeSection() => [
    Obx(() {
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
    }),
    const Spacer(),
    CustomText(_formatTime(_remainingSeconds), color: Theme.of(context).colorScheme.error, fontSize: 22.0),
  ];

  Widget _buildBarcode() => AspectRatio(
    aspectRatio: 4 / 1,
    child: Code(
      drawText: false,
      codeType: CodeType.code39(),
      backgroundColor: Colors.white,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS)),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 32.0)),
      data: _hive.memberProfile.value!.memberCode,
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
