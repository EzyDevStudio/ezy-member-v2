import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
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
  Widget build(BuildContext context) => DefaultTabController(
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
        title: Text(Globalization.eInvoice.tr),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[_buildInvoiceTab(_hive.personalInvoice), _buildInvoiceTab(_hive.workingInvoice)],
      ),
    ),
  );

  Widget _buildInvoiceTab(String image) => Column(
    spacing: ResponsiveHelper.getSpacing(context, 64.0),
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
        child: image.isNotEmpty
            ? InteractiveViewer(maxScale: 5.0, child: Image.network(image, fit: BoxFit.contain))
            : Center(
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
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
