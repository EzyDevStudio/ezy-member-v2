import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MediaViewerScreen extends StatefulWidget {
  const MediaViewerScreen({super.key});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late String _mediaUrl;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _mediaUrl = args["media_url"];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: Center(
      child: InteractiveViewer(maxScale: 5.0, child: Image.network(_mediaUrl, fit: BoxFit.contain)),
    ),
  );
}
