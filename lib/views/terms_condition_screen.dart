import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/voucher_model.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsConditionScreen extends StatefulWidget {
  const TermsConditionScreen({super.key});

  @override
  State<TermsConditionScreen> createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen> {
  late VoucherModel _voucher;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};
    final VoucherModel? voucher;

    voucher = args["voucher"];

    if (voucher != null) {
      _voucher = voucher;
    } else {
      _voucher = VoucherModel.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    rsp.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
          child: _buildContent(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    leading: IconButton(
      onPressed: () => Get.back(),
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    ),
    title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
  );

  Widget _buildContent() => ListView(
    padding: EdgeInsets.only(bottom: 16.dp, left: 16.dp, right: 16.dp, top: 24.dp),
    children: <Widget>[
      CustomText(_voucher.batchDescription, fontSize: 24.0, fontWeight: FontWeight.bold),
      SizedBox(height: 16.dp),
      _buildResponsive(
        _buildListTile(subtitle: "${_voucher.startCollectDate.tsToStr} - ${_voucher.endCollectDate.tsToStr}", title: Globalization.collectBetween.tr),
        _buildListTile(subtitle: "${_voucher.startDate.tsToStr} - ${_voucher.expiredDate.tsToStr}", title: Globalization.useBetween.tr),
      ),
      _buildResponsive(
        _buildListTile(subtitle: "${_voucher.discountValue.toStringAsFixed(2)} ${Globalization.off.tr}", title: Globalization.discountAmount.tr),
        _buildListTile(subtitle: _voucher.minimumSpend.toStringAsFixed(2), title: Globalization.minSpend.tr),
      ),
      _buildListTile(subtitle: _voucher.termsCondition, title: Globalization.tncApplied.tr),
    ],
  );

  Widget _buildListTile({String? subtitle, required String title}) => ListTile(
    contentPadding: EdgeInsets.zero,
    subtitle: subtitle != null ? CustomText(subtitle, fontSize: 16.0, maxLines: null) : null,
    title: CustomText(title, color: Theme.of(context).colorScheme.primary, fontSize: 14.0, fontWeight: FontWeight.w600),
  );

  Widget _buildResponsive(Widget child1, Widget child2) => isMobile
      ? Column(spacing: 16.0, children: <Widget>[child1, child2])
      : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: <Widget>[
            Expanded(child: child1),
            Expanded(child: child2),
          ],
        );
}
