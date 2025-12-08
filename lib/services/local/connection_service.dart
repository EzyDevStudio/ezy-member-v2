import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezy_member_v2/helpers/connection_helper.dart';

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
}
