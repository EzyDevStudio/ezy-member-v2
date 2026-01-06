import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/history_controller.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_image.dart';
import 'package:ezy_member_v2/widgets/custom_list_tile.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_bar_code/code/code.dart';

class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({super.key});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _historyController = Get.put(HistoryController(), tag: "memberDetail");
  final _memberController = Get.put(MemberController(), tag: "memberDetail");
  final _scrollController = ScrollController();

  late MemberModel _member;
  late String _companyID;

  bool _showFab = false;
  DateTime? _endDate, _startDate;
  HistoryType _selectedType = HistoryType.all;

  @override
  void initState() {
    super.initState();

    _companyID = Get.arguments["company_id"];

    _scrollController.addListener(() {
      if (_scrollController.offset > kBackToTop && !_showFab) {
        setState(() => _showFab = true);
      } else if (_scrollController.offset <= kBackToTop && _showFab) {
        setState(() => _showFab = false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _historyController.loadHistories(_hive.memberProfile.value!.memberCode, companyID: _companyID);
    _memberController.loadMembers(_hive.memberProfile.value!.memberCode, companyID: _companyID);
  }

  void _showFilterModal() {
    DateTime endDate = _endDate ?? DateTime.now();
    DateTime startDate = _startDate ?? DateTime.now();
    HistoryType selectedType = _selectedType;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusM))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: ResponsiveHelper.getSpacing(context, 16.0),
            children: <Widget>[
              CustomText("history_type".tr, fontSize: 18.0),
              CustomChoiceChip(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                values: AppStrings().historyTypes,
                selectedValue: selectedType,
                onSelected: (type) => setModalState(() => selectedType = type),
                alignment: WrapAlignment.start,
              ),
              CustomText("custom_date_range".tr, fontSize: 18.0),
              Row(
                spacing: ResponsiveHelper.getSpacing(context, 16.0),
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusS)),
                      ),
                      onPressed: () async {
                        final pickedDate = await _selectDate(context, startDate);
                        setModalState(() => startDate = pickedDate);
                      },
                      child: CustomText(
                        FormatterHelper.dateTimeToString(startDate),
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  CustomText("-", fontSize: 16.0),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusS)),
                      ),
                      onPressed: () async {
                        final pickedDate = await _selectDate(context, endDate);
                        setModalState(() => endDate = pickedDate);
                      },
                      child: CustomText(
                        FormatterHelper.dateTimeToString(endDate),
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: ResponsiveHelper.getSpacing(context, 16.0),
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusS)),
                      ),
                      onPressed: () {
                        setState(() {
                          _endDate = null;
                          _startDate = null;
                          _selectedType = HistoryType.all;
                        });

                        Get.back();
                      },
                      child: CustomText("clear".tr.toLowerCase(), color: Theme.of(context).colorScheme.onSecondaryContainer, fontSize: 16.0),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: CustomFilledButton(
                      label: "apply".tr,
                      onTap: () {
                        setState(() {
                          _endDate = endDate;
                          _startDate = startDate;
                          _selectedType = selectedType;
                        });

                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime> _selectDate(BuildContext context, DateTime date) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: date,
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            surface: Theme.of(context).colorScheme.surface,
            onSurface: Theme.of(context).colorScheme.onSurface,
          ),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary)),
        ),
        child: child!,
      ),
    );

    return pickedDate ?? date;
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(),
    body: RefreshIndicator(
      onRefresh: _onRefresh,
      child: Obx(() {
        _member = _memberController.members.isNotEmpty ? _memberController.members.first : MemberModel.empty();

        return ListView(
          controller: _scrollController,
          children: <Widget>[
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint * 0.9),
                padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
                child: Column(
                  spacing: ResponsiveHelper.getSpacing(context, 16.0),
                  children: <Widget>[_buildMemberCard(), _buildQuickAccess(), _buildBarcode()],
                ),
              ),
            ),
            _buildHistory(),
          ],
        );
      }),
    ),
    floatingActionButton: _showFab ? _buildFAB() : null,
  );

  Widget _buildMemberCard() => AspectRatio(
    aspectRatio: kCardRatio,
    child: CustomBackgroundImage(
      isBorderRadius: true,
      isShadow: true,
      backgroundImage: _member.memberCard.cardImage,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomAvatarImage(size: ResponsiveHelper.getBranchImgSize(context) * 1.2, networkImage: _hive.image),
                const Spacer(),
                CustomLabelChip(
                  backgroundColor: _member.isExpired ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  label: _member.isExpired ? "expired".tr : "active".tr,
                ),
              ],
            ),
            CustomText(
              _member.memberCard.memberCardNumber.replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)} "),
              color: Colors.white,
              fontSize: 22.0,
            ),
            const Spacer(),
            Row(
              spacing: ResponsiveHelper.getSpacing(context, 16.0),
              children: <Widget>[
                Expanded(child: CustomText(_hive.memberProfile.value!.name, color: Colors.white, fontSize: 18.0)),
                CustomText(_member.memberCard.cardDesc, color: Colors.white, fontSize: 18.0),
              ],
            ),
            const Spacer(),
            Row(
              spacing: ResponsiveHelper.getSpacing(context, 16.0),
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomText("joined".tr, color: Colors.white, fontSize: 14.0),
                    CustomText(FormatterHelper.timestampToString(_member.memberCard.createdAt), color: Colors.white, fontSize: 14.0),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomText("expires".tr, color: Colors.white, fontSize: 14.0),
                    CustomText(FormatterHelper.timestampToString(_member.memberCard.expiredDate), color: Colors.white, fontSize: 14.0),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildQuickAccess() => Container(
    margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
    child: Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(AppRoutes.scan, arguments: {"scan_type": ScanType.redeem, "company_id": _member.companyID}),
            child: _buildQuickAccessItem("my_points".tr, _member.point.toString()),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 1, "company_id": _member.companyID}),
            child: _buildQuickAccessItem("my_vouchers".tr, (_member.normalVoucherCount + _member.specialVoucherCount).toString()),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(AppRoutes.scan, arguments: {"scan_type": ScanType.redeem, "company_id": _member.companyID}),
            child: _buildQuickAccessItem("my_credits".tr, _member.credit.toStringAsFixed(1)),
          ),
        ),
      ],
    ),
  );

  Widget _buildQuickAccessItem(String label, String value) => Column(
    spacing: ResponsiveHelper.getSpacing(context, 8.0),
    children: <Widget>[
      CustomText(value, color: Theme.of(context).colorScheme.primary, fontSize: 20.0, fontWeight: FontWeight.bold),
      CustomText(label, fontSize: 16.0),
    ],
  );

  Widget _buildBarcode() => InkWell(
    onTap: () => Get.toNamed(AppRoutes.scan),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0)),
      child: AspectRatio(
        aspectRatio: 4 / 1,
        child: Code(drawText: false, codeType: CodeType.code128(), backgroundColor: Colors.white, data: _hive.memberProfile.value!.memberCode),
      ),
    ),
  );

  Widget _buildHistory() => Obx(() {
    if (_historyController.histories.isEmpty) return SizedBox.shrink();

    _endDate ??= DateTime.fromMillisecondsSinceEpoch(_historyController.histories.first.transactionDate);
    _startDate ??= DateTime.fromMillisecondsSinceEpoch(_historyController.histories.last.transactionDate);

    final filteredHistories = _historyController.histories.where((h) {
      final historyDate = DateTime.fromMillisecondsSinceEpoch(h.transactionDate);
      final matchesType = _selectedType == HistoryType.all || h.type == _selectedType;
      final matchesDate =
          (_startDate == null || historyDate.isAfter(_startDate!.subtract(Duration(days: 1)))) &&
          (_endDate == null || historyDate.isBefore(_endDate!.add(Duration(days: 1))));

      return matchesType && matchesDate;
    }).toList();

    return Column(
      children: <Widget>[
        _buildHistoryHeader(),
        ...List.generate(
          filteredHistories.length,
          (index) => Column(
            children: <Widget>[
              CustomHistoryListTile(history: filteredHistories[index]),
              if (index + 1 != filteredHistories.length)
                Divider(
                  color: Colors.grey.shade200,
                  endIndent: ResponsiveHelper.getSpacing(context, 16.0),
                  indent: ResponsiveHelper.getSpacing(context, 16.0),
                  height: 1.0,
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
          child: CustomText("msg_history_end".tr, color: Colors.grey, fontSize: 16.0),
        ),
      ],
    );
  });

  Widget _buildHistoryHeader() => Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.grey.withValues(alpha: 0.7), width: ResponsiveHelper.getSpacing(context, 5.0)),
      ),
    ),
    padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0), vertical: ResponsiveHelper.getSpacing(context, 16.0)),
    child: Row(
      spacing: ResponsiveHelper.getSpacing(context, 16.0),
      children: <Widget>[
        Expanded(child: CustomText("history".tr, fontSize: 18.0, fontWeight: FontWeight.bold)),
        InkWell(
          onTap: () => _showFilterModal(),
          child: Row(
            spacing: ResponsiveHelper.getSpacing(context, 4.0),
            children: <Widget>[
              CustomText(AppStrings().historyTypes[_selectedType]!, color: Colors.grey, fontSize: 16.0),
              Icon(Icons.filter_alt_rounded, color: Colors.grey),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildFAB() => FloatingActionButton(
    onPressed: () => _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
    child: Icon(Icons.keyboard_arrow_up_rounded),
  );
}
