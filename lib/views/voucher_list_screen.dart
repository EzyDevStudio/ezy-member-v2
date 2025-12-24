import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
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
  final _hive = Get.find<MemberHiveController>();
  final _voucherController = Get.put(VoucherController(), tag: "voucherList");

  late int? _checkStart;
  late String? _companyID;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _checkStart = args["check_start"];
    _companyID = args["company_id"];

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    if (_checkStart != null && _companyID == null) {
      _voucherController.loadVouchers(_hive.memberProfile.value!.memberCode, checkStart: _checkStart!);
    } else if (_checkStart != null && _companyID != null) {
      _voucherController.loadVouchers(_hive.memberProfile.value!.memberCode, checkStart: _checkStart!, companyID: _companyID);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("my_vouchers".tr)),
    body: RefreshIndicator(onRefresh: _onRefresh, child: _buildContent()),
  );

  Widget _buildContent() => Obx(() {
    if (_voucherController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_voucherController.vouchers.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(child: CustomText("msg_no_available".trParams({"label": "vouchers".tr.toLowerCase()}), fontSize: 16.0, maxLines: 2)),
      );
    }

    final vouchers = List.from(_voucherController.vouchers)..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));

    return ListView.builder(
      itemCount: vouchers.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsetsGeometry.only(
          bottom: index == vouchers.length - 1 ? ResponsiveHelper.getSpacing(context, 16.0) : 0.0,
          left: ResponsiveHelper.getSpacing(context, 16.0),
          right: ResponsiveHelper.getSpacing(context, 16.0),
          top: ResponsiveHelper.getSpacing(context, 16.0),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
            child: CustomVoucher(
              voucher: vouchers[index],
              type: VoucherType.normal,
              onTap: () async =>
                  await Get.toNamed(AppRoutes.payment, arguments: {"scan_type": ScanType.voucher, "value": vouchers[index].voucherCode}),
            ),
          ),
        ),
      ),
    );
  });
}
