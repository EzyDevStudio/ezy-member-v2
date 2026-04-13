import 'dart:convert';
import 'dart:developer';

import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class LocationHelper {
  static Future<Coordinate?> getCurrentCoordinate() async {
    try {
      final LocationSettings locationSettings = const LocationSettings(distanceFilter: 0, accuracy: LocationAccuracy.high);
      final Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

      final url = Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json");
      final response = await http.get(url, headers: {"User-Agent": "EzyMemberApp"});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data["address"];

        String city = address["district"];

        return Coordinate(address: "Current Location", city: city, latitude: position.latitude, longitude: position.longitude);
      } else {
        return null;
      }
    } catch (e) {
      log("LocationHelper - getCurrentCoordinate", time: DateTime.now(), error: e, name: "Unknown Error");
      return null;
    }
  }

  static Future<void> redirectGoogleMap(String fullAddress) async {
    bool? result = await MessageHelper.confirmation(
      message: Globalization.msgGoogleMapsConfirmation.tr,
      title: Globalization.confirmation.tr,
      confirmText: Globalization.goNow.tr,
    );

    if (result == null || !result) return;

    MessageHelper.loading(message: Globalization.redirecting.tr);

    final encodedAddress = Uri.encodeComponent(fullAddress);
    final url = "https://www.google.com/maps/search/?api=1&query=$encodedAddress";
    final Uri uri = Uri.parse(url);

    if (kIsWeb) {
      if (await canLaunchUrl(uri)) await launchUrl(uri, webOnlyWindowName: "_blank");
    } else {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        log("LocationHelper - redirectGoogleMap", time: DateTime.now(), error: e, name: "Unknown Error");
      }
    }

    if (Get.isDialogOpen ?? false) Get.back();
  }
}

class Coordinate {
  final String address;
  final String city;
  final double latitude;
  final double longitude;

  Coordinate({required this.address, required this.city, required this.latitude, required this.longitude});
}
