import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezymember/helpers/connection_helper.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectionService {
  ConnectionService._internal();
  static final ConnectionService instance = ConnectionService._internal();

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool? _lastStatus;
  Stream<bool> get stream => _controller.stream;

  void start() => Connectivity().onConnectivityChanged.listen((_) async {
    bool status = await ConnectionHelper.isConnected();

    if (status != _lastStatus) {
      _lastStatus = status;
      _controller.add(status);
    }
  });

  void dispose() => _controller.close();

  static Future<bool> checkConnection() async {
    final List<ConnectivityResult> result = await Connectivity().checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      MessageHelper.show(
        Globalization.msgConnectionOff.tr,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 10),
        icon: Icons.wifi_off_rounded,
      );
    }

    return !result.contains(ConnectivityResult.none);
  }
}
