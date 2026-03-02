import 'dart:typed_data';

import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum InvoiceType { personal, working }

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> with SingleTickerProviderStateMixin {
  final _hive = Get.find<MemberHiveController>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: InvoiceType.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper().init(context);

    return DefaultTabController(
      length: InvoiceType.values.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Colors.grey,
            tabs: <Tab>[
              Tab(text: Globalization.personal.tr),
              Tab(text: Globalization.working.tr),
            ],
          ),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[_buildInvoiceTab(_hive.personalInvoice), _buildInvoiceTab(_hive.workingInvoice)],
        ),
      ),
    );
  }

  Widget _buildInvoiceTab(Uint8List? bytes) => Column(
    spacing: 64.dp,
    children: <Widget>[
      Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black26, blurRadius: 15.0, spreadRadius: 20.0),
            BoxShadow(color: Colors.black26, blurRadius: 10.0, spreadRadius: 10.0),
          ],
        ),
      ),
      Expanded(
        child: bytes != null
            ? InteractiveViewer(maxScale: 5.0, child: Image.memory(bytes, fit: BoxFit.contain))
            : Center(
                child: Padding(
                  padding: EdgeInsets.all(16.dp),
                  child: CustomText(Globalization.msgNoEInvoice.tr, fontSize: 16.0, maxLines: 2, textAlign: TextAlign.center),
                ),
              ),
      ),
      Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black26, blurRadius: 15.0, spreadRadius: 20.0),
            BoxShadow(color: Colors.black26, blurRadius: 10.0, spreadRadius: 10.0),
          ],
        ),
      ),
    ],
  );
}
