import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
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
  Widget build(BuildContext context) => Scaffold(body: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildContent()]));

  Widget _buildAppBar() => SliverAppBar(floating: true, pinned: true, title: Text(AppStrings.tncLong));

  Widget _buildContent() => SliverPadding(
    padding: EdgeInsets.only(
      bottom: ResponsiveHelper.getSpacing(context, SizeType.m),
      left: ResponsiveHelper.getSpacing(context, SizeType.m),
      right: ResponsiveHelper.getSpacing(context, SizeType.m),
      top: ResponsiveHelper.getSpacing(context, SizeType.l),
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomText(_voucher.batchDescription, fontSize: 24.0, fontWeight: FontWeight.bold),
          SizedBox(height: ResponsiveHelper.getSpacing(context, SizeType.m)),
          _buildListTile(
            subtitle: "${FormatterHelper.timestampToString(_voucher.startDate)} - ${FormatterHelper.timestampToString(_voucher.expiredDate)}",
            title: AppStrings.validPeriod,
          ),
          _buildListTile(subtitle: "${_voucher.discountValue} ${AppStrings.off}", title: AppStrings.discountAmount),
          _buildListTile(subtitle: _voucher.minimumSpend.toStringAsFixed(1), title: AppStrings.minSpend),
          _buildListTile(subtitle: _voucher.termsCondition, title: AppStrings.more),
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
