import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/voucher_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_voucher.dart';
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("notifications".tr)),
    body: RefreshIndicator(onRefresh: _onRefresh, child: _buildVoucherList()),
  );

  Widget _buildVoucherList() => Obx(() {
    if (_voucherController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    final todayVouchers = List.from(_voucherController.vouchers)..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));
    final redeemableVouchers = List.from(_voucherController.redeemableVouchers)..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));
    final totalCount = todayVouchers.length + redeemableVouchers.length;

    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        final bool isTodaySection = index < todayVouchers.length;
        final voucher = isTodaySection ? todayVouchers[index] : redeemableVouchers[index - todayVouchers.length];

        return Padding(
          padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 16.0)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (index == 0 && todayVouchers.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 16.0)),
                      child: CustomText("voucher_expires_today".tr, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  if (index == todayVouchers.length && redeemableVouchers.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 16.0)),
                      child: CustomText("redeemable_vouchers".tr, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  isTodaySection
                      ? CustomVoucher(
                          voucher: voucher,
                          type: VoucherType.normal,
                          onTap: () => Get.toNamed(
                            AppRoutes.payment,
                            arguments: {
                              "benefit_type": BenefitType.voucher,
                              "scan_type": ScanType.qrCode,
                              "company_id": voucher.companyID,
                              "value": voucher.voucherCode,
                            },
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
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  });
}
