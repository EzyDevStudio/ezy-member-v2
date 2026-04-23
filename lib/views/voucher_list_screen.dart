import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/constants/enum.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/controllers/voucher_controller.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_text_field.dart';
import 'package:ezymember/widgets/custom_voucher.dart';
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
  final _searchController = TextEditingController();

  late int? _checkStart;
  late String? _companyID;

  List<dynamic> _filteredVouchers = [];

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _checkStart = args["check_start"];
    _companyID = args["company_id"];

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    if (_checkStart != null && _companyID == null) {
      _voucherController.loadVouchers(_hive.memberProfile.value!.memberCode, checkStart: _checkStart!);
    } else if (_checkStart != null && _companyID != null) {
      _voucherController.loadVouchers(_hive.memberProfile.value!.memberCode, checkStart: _checkStart!, companyID: _companyID);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(
      () => _filteredVouchers = _voucherController.vouchers
          .where((voucher) => voucher.batchDescription.toLowerCase().contains(query) || voucher.companyName.toLowerCase().contains(query))
          .toList(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
          child: RefreshIndicator(onRefresh: _onRefresh, child: _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() => Obx(() {
    if (_voucherController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(16.dp),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_voucherController.vouchers.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.dp),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomText(Globalization.msgNoAvailable.trParams({"label": Globalization.vouchers.tr.toLowerCase()}), fontSize: 16.0, maxLines: 2),
              InkWell(
                onTap: _onRefresh,
                child: CustomText(Globalization.refresh.tr, color: Colors.blue, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    }

    final vouchers = List.from(_voucherController.vouchers)..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));
    final displayVouchers = _searchController.text.isEmpty ? vouchers : _filteredVouchers;
    final Map<String, List<dynamic>> groupedVouchers = {};

    for (var voucher in displayVouchers) {
      if (!groupedVouchers.containsKey(voucher.companyName)) {
        groupedVouchers[voucher.companyName] = [];
      }

      groupedVouchers[voucher.companyName]!.add(voucher);
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.dp),
          child: CustomSearchTextField(controller: _searchController, onChanged: (String value) => _onSearchChanged()),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.dp),
            children: groupedVouchers.entries.map((entry) {
              final companyName = entry.key;
              final vouchers = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.dp),
                    child: CustomText("$companyName (${vouchers.length})", fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  ...vouchers.map(
                    (voucher) => Padding(
                      padding: EdgeInsets.only(bottom: 16.dp),
                      child: CustomVoucher(
                        voucher: voucher,
                        type: VoucherType.normal,
                        onTap: () => Get.toNamed(
                          AppRoutes.scan,
                          arguments: {"scan_type": ScanType.redeemVoucher, "company_id": voucher.companyID, "value": voucher.voucherCode},
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  });
}
