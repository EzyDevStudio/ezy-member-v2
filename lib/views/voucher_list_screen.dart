import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/enum.dart';
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
  final _voucherController = Get.put(VoucherController(), tag: "voucherList");

  late int? _checkStart;
  late String? _companyID;
  late String? _memberCode;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _checkStart = args["check_start"];
    _companyID = args["company_id"];
    _memberCode = args["member_code"];

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    if (_checkStart != null && _companyID == null && _memberCode != null) {
      _voucherController.loadVouchers(_memberCode!, checkStart: _checkStart!);
    } else if (_checkStart != null && _companyID != null && _memberCode != null) {
      _voucherController.loadVouchers(_memberCode!, checkStart: _checkStart!, companyID: _companyID);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildContent()]),
    ),
  );

  Widget _buildAppBar() => SliverAppBar(floating: true, pinned: true, title: Text("my_vouchers".tr));

  Widget _buildContent() => SliverPadding(
    padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
    sliver: Obx(() {
      if (_voucherController.isLoading.value) {
        return SliverFillRemaining(
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        );
      }

      if (_voucherController.vouchers.isEmpty) {
        return SliverFillRemaining(
          child: Center(child: CustomText("msg_no_available".trParams({"label": "vouchers".tr.toLowerCase()}), fontSize: 16.0, maxLines: 2)),
        );
      }

      final vouchers = List.from(_voucherController.vouchers)..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));

      return SliverToBoxAdapter(
        child: Wrap(
          runSpacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          alignment: WrapAlignment.center,
          children: vouchers.map((voucher) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
              child: CustomVoucher(
                voucher: voucher,
                type: VoucherType.normal,
                onTap: () async {
                  await Get.toNamed(AppRoutes.payment, arguments: {"scan_type": ScanType.voucher, "value": voucher.voucherCode});

                  _onRefresh();
                },
              ),
            );
          }).toList(),
        ),
      );
    }),
  );
}
