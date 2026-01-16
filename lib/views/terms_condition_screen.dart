import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
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
    ResponsiveHelper().init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildContent()]),
    );
  }

  Widget _buildAppBar() => SliverAppBar(floating: true, pinned: true, title: Text(Globalization.tncLong.tr));

  Widget _buildContent() => SliverPadding(
    padding: EdgeInsets.only(bottom: 16.dp, left: 16.dp, right: 16.dp, top: 24.dp),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomText(_voucher.batchDescription, fontSize: 24.0, fontWeight: FontWeight.bold),
          SizedBox(height: 16.dp),
          _buildListTile(
            subtitle: "${FormatterHelper.timestampToString(_voucher.startDate)} - ${FormatterHelper.timestampToString(_voucher.expiredDate)}",
            title: Globalization.validPeriod.tr,
          ),
          _buildListTile(subtitle: "${_voucher.discountValue.toStringAsFixed(1)} ${Globalization.off.tr}", title: Globalization.discountAmount.tr),
          _buildListTile(subtitle: _voucher.minimumSpend.toStringAsFixed(1), title: Globalization.minSpend.tr),
          _buildListTile(subtitle: _voucher.termsCondition, title: Globalization.more.tr),
        ],
      ),
    ),
  );

  Widget _buildListTile({String? subtitle, required String title}) => ListTile(
    contentPadding: EdgeInsets.zero,
    subtitle: subtitle != null ? CustomText(subtitle, fontSize: 16.0, maxLines: null) : null,
    title: CustomText(title, color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w600),
  );
}
