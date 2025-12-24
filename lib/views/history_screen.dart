import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/history_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/history_model.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_list_tile.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _historyController = Get.put(HistoryController(), tag: "history");
  final _historyTypes = AppStrings().historyTypes;

  HistoryType _selectedType = HistoryType.all;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    await _historyController.loadHistories(_hive.memberProfile.value!.memberCode);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("history".tr)),
    body: RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildChoiceChip(),
          Expanded(child: _buildContent()),
        ],
      ),
    ),
  );

  Widget _buildChoiceChip() => Container(
    padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
    child: CustomChoiceChip<HistoryType>(
      values: _historyTypes,
      selectedValue: _selectedType,
      onSelected: (type) => setState(() => _selectedType = type),
      alignment: WrapAlignment.start,
    ),
  );

  Widget _buildContent() => Obx(() {
    if (_historyController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    final filteredHistories = _selectedType == HistoryType.all
        ? _historyController.histories
        : _historyController.histories.where((h) => h.type == _selectedType).toList();

    if (filteredHistories.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(child: CustomText("msg_no_available".trParams({"label": "history".tr.toLowerCase()}), fontSize: 16.0, maxLines: 2)),
      );
    }

    final Map<String, List<HistoryModel>> grouped = {};
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    for (var h in filteredHistories) {
      final date = DateTime.fromMillisecondsSinceEpoch(h.transactionDate);

      String header;

      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        header = "today".tr;
      } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
        header = "yesterday".tr;
      } else {
        header = FormatterHelper.dateTimeToString(date);
      }

      grouped.putIfAbsent(header, () => []);
      grouped[header]!.add(h);
    }

    final List<Map<String, dynamic>> items = [];

    grouped.forEach((header, histories) {
      histories.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      items.add({"isHeader": true, "header": header});

      for (var h in histories) {
        items.add({"isHeader": false, "data": h});
      }
    });

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return item["isHeader"] == true ? _buildHistoryHeader(context, item) : _buildHistoryItem(context, index, items, item);
      },
    );
  });

  Widget _buildHistoryHeader(BuildContext context, Map<String, dynamic> item) => Container(
    color: Theme.of(context).colorScheme.primaryContainer,
    padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
    child: CustomText(item["header"], fontSize: 16.0, fontWeight: FontWeight.bold),
  );

  Widget _buildHistoryItem(BuildContext context, int index, List<Map<String, dynamic>> items, Map<String, dynamic> item) {
    final HistoryModel history = item["data"];

    return Column(
      children: <Widget>[
        CustomHistoryListTile(history: history),
        if (index + 1 < items.length && items[index + 1]["isHeader"] == false)
          Divider(
            color: Colors.grey.shade200,
            endIndent: ResponsiveHelper.getSpacing(context, 16.0),
            indent: ResponsiveHelper.getSpacing(context, 16.0),
            height: 1.0,
          ),
      ],
    );
  }
}
