import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/history_controller.dart';
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
  final _historyController = Get.put(HistoryController(), tag: "history");
  final _historyTypes = {
    HistoryType.all: "all".tr,
    HistoryType.point: "points".tr,
    HistoryType.voucher: "vouchers".tr,
    HistoryType.credit: "credits".tr,
  };

  late String? _memberCode;

  HistoryType _selectedType = HistoryType.all;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _memberCode = args["member_code"];

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    if (_memberCode != null) await _historyController.loadHistories(_memberCode!);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildChoiceChip(), _buildHistory()]),
    ),
  );

  Widget _buildAppBar() => SliverAppBar(floating: true, pinned: true, title: Text("history".tr));

  Widget _buildChoiceChip() => SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
      child: CustomChoiceChip<HistoryType>(
        values: _historyTypes,
        selectedValue: _selectedType,
        onSelected: (type) => setState(() => _selectedType = type),
        alignment: WrapAlignment.start,
      ),
    ),
  );

  Widget _buildHistory() => Obx(() {
    if (_historyController.isLoading.value) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    final filteredHistories = _selectedType == HistoryType.all
        ? _historyController.histories
        : _historyController.histories.where((h) => h.type == _selectedType).toList();

    if (filteredHistories.isEmpty) {
      return SliverFillRemaining(
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

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];

        if (item["isHeader"] == true) {
          return Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
            child: CustomText(item["header"], fontSize: 16.0, fontWeight: FontWeight.bold),
          );
        } else {
          final HistoryModel history = item["data"];

          return Column(
            children: <Widget>[
              CustomHistoryListTile(history: history),
              if (index + 1 < items.length && items[index + 1]["isHeader"] == false)
                Divider(
                  color: Colors.grey.shade200,
                  endIndent: ResponsiveHelper.getSpacing(context, SizeType.m),
                  indent: ResponsiveHelper.getSpacing(context, SizeType.m),
                  height: 1.0,
                ),
            ],
          );
        }
      }, childCount: items.length),
    );
  });
}
