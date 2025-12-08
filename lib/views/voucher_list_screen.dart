import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/voucher_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_voucher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoucherListScreen extends StatefulWidget {
  const VoucherListScreen({super.key});

  @override
  State<VoucherListScreen> createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  final _voucherController = Get.find<VoucherController>();

  late bool? _checkStart;
  late String? _memberCode;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _checkStart = args["checkStart"];
    _memberCode = args["memberCode"];

    if (_checkStart != null && _memberCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_checkStart!) {
          _voucherController.loadVouchers(_memberCode!, 1);
        } else {
          _voucherController.loadVouchers(_memberCode!, 0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildContent()]));

  Widget _buildAppBar() => SliverAppBar(floating: true, pinned: true, title: Text(AppStrings.myVouchers));

  Widget _buildContent() => SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
      child: Obx(() {
        if (_voucherController.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
        }

        if (_voucherController.vouchers.isEmpty) {
          return Center(child: CustomText(AppStrings.msgNoAvailableVoucher, fontSize: 16.0, maxLines: 2));
        }

        return Wrap(
          runSpacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          alignment: WrapAlignment.center,
          children: _voucherController.vouchers.map((voucher) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
              child: CustomCompaniesVoucher(voucher: voucher),
            );
          }).toList(),
        );
      }),
    ),
  );
}
