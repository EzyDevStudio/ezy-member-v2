import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/controllers/company_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PaymentMethod { onlineBanking, savedCard, touchNGo, card }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _companyController = Get.put(CompanyController(), tag: "payment");

  late String _companyID;

  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();

    _companyID = Get.arguments["company_id"];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(title: Text(Globalization.payment.tr)),
    body: _buildContent(),
  );

  Widget _buildContent() => ListView(
    padding: EdgeInsets.all(16.dp),
    children: <Widget>[
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusM)),
          border: Border.all(color: Theme.of(context).colorScheme.surfaceDim),
          color: Colors.white,
        ),
        margin: EdgeInsets.only(bottom: 16.dp),
        padding: EdgeInsets.symmetric(vertical: 8.dp),
        child: Column(
          children: <Widget>[
            _buildPaymentOption(Icons.account_balance_rounded, "Online Banking", PaymentMethod.onlineBanking),
            _buildPaymentOption(Icons.account_balance_wallet_rounded, "Touch ’n Go", PaymentMethod.touchNGo),
            _buildPaymentOption(Icons.credit_card_rounded, "**** **** **** 1234", PaymentMethod.savedCard),
          ],
        ),
      ),
      CustomFilledButton(
        label: Globalization.payment.tr,
        onTap: () async {
          final result = await _companyController.registerMember(_companyID, _hive.memberProfile.value!.memberCode);

          if (result) Get.offNamedUntil(AppRoutes.companyDetail, (route) => route.isFirst, arguments: {"company_id": _companyID});
        },
      ),
    ],
  );

  Widget _buildPaymentOption(IconData icon, String title, PaymentMethod value) => CheckboxListTile(
    value: _selectedMethod == value,
    activeColor: Theme.of(context).colorScheme.primary,
    controlAffinity: ListTileControlAffinity.trailing,
    onChanged: (checked) => setState(() => _selectedMethod = checked == true ? value : null),
    secondary: Icon(icon),
    title: Text(title),
  );
}
