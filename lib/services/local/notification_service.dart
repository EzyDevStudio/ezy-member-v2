import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService {
  static const String _channelId = "firebase_channel";
  static const String _channelName = "Firebase Channel";
  static const String _icon = "@mipmap/launcher_icon";
  static const String keyNotificationCode = "notification_code";

  static const _channel = AndroidNotificationChannel(_channelId, _channelName, importance: Importance.max);

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _messaging.requestPermission(provisional: true);
    await _setupLocalNotifications();
    await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    _listenToMessages();
  }

  static Future<void> _setupLocalNotifications() async {
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);
    await _plugin.initialize(const InitializationSettings(android: AndroidInitializationSettings(_icon), iOS: DarwinInitializationSettings()));
  }

  static void _listenToMessages() => FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    final hive = Get.find<MemberHiveController>();

    if (notification == null) return;

    _plugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(_channel.id, _channel.name, icon: _icon),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );

    if (message.data[keyNotificationCode] == "999") {
      hive.signOut();
      Get.offNamed(AppRoutes.home);
      MessageHelper.warning(message: Globalization.msgTokenExpired.tr);
    }
  });

  static Future<String?> getToken() async => await _messaging.getToken();

  static void onTokenRefresh(void Function(String) callback) => _messaging.onTokenRefresh.listen(callback);
}
