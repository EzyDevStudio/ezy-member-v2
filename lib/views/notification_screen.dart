import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/constants/enum.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/controllers/voucher_controller.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/voucher_model.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_voucher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _voucherController = Get.put(VoucherController(), tag: "notification");

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    await _voucherController.loadVouchers(_hive.memberProfile.value!.memberCode, checkToday: 1);
  }

  @override
  Widget build(BuildContext context) {
    rsp.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
      ),
      body: RefreshIndicator(onRefresh: _onRefresh, child: _buildVoucherList()),
    );
  }

  Widget _buildVoucherList() => Obx(() {
    if (_voucherController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(16.dp),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    List<VoucherModel> todayVouchers = List.from(_voucherController.vouchers)..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));
    List<VoucherModel> redeemableVouchers = List.from(_voucherController.redeemableVouchers)..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));

    return ListView(
      padding: EdgeInsets.all(16.dp),
      children: <Widget>[
        Wrap(
          runSpacing: 16.dp,
          spacing: 16.dp,
          alignment: WrapAlignment.center,
          children: <Widget>[_buildSection(true, todayVouchers), _buildSection(false, redeemableVouchers)],
        ),
      ],
    );
  });

  Widget _buildSection(bool isTodaySection, List<VoucherModel> vouchers) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 16.dp),
          child: CustomText(
            isTodaySection ? Globalization.voucherExpiresToday.tr : Globalization.redeemableVouchers.tr,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: vouchers.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final voucher = vouchers[index];

            return isTodaySection
                ? CustomVoucher(
                    voucher: voucher,
                    type: VoucherType.normal,
                    onTap: () => Get.toNamed(
                      AppRoutes.scan,
                      arguments: {"scan_type": ScanType.redeemVoucher, "company_id": voucher.companyID, "value": voucher.voucherCode},
                    ),
                  )
                : CustomVoucher(
                    voucher: voucher,
                    type: VoucherType.redeemable,
                    onTapRedeem: () => _voucherController.redeemVoucher(
                      voucher.batchCode,
                      voucher.companyID,
                      _hive.memberProfile.value!.memberCode,
                      _hive.memberProfile.value!.token,
                    ),
                  );
          },
        ),
      ],
    ),
  );
}
