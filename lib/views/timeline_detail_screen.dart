import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/models/timeline_model.dart';
import 'package:ezy_member_v2/widgets/custom_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimelineDetailScreen extends StatefulWidget {
  const TimelineDetailScreen({super.key});

  @override
  State<TimelineDetailScreen> createState() => _TimelineDetailScreenState();
}

class _TimelineDetailScreenState extends State<TimelineDetailScreen> {
  late TimelineModel _timeline;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _timeline = args["timeline"];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(title: Text(Globalization.timeline.tr)),
    body: ListView(children: <Widget>[CustomTimeline(timeline: _timeline, isDetail: true)]),
  );
}
