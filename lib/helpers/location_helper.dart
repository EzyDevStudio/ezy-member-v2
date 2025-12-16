import 'dart:developer';
import 'dart:math' hide log;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationHelper {
  static List<Coordinate> filterByCoordinate({
    required double originLat,
    required double originLong,
    required List<Coordinate> coordinates,
    required double radiusKm,
  }) {
    return coordinates.where((coordinate) {
      double distance = calculateDistance(originLat, originLong, coordinate.latitude, coordinate.longitude);
      return distance <= radiusKm;
    }).toList();
  }

  static double calculateDistance(double originLat, double originLong, double targetLat, targetLong) {
    const double earthRadius = 6371.00; // in terms of km
    double diffLat = _degreesToRadians(targetLat - originLat);
    double diffLong = _degreesToRadians(targetLong - originLong);

    double a =
        sin(diffLat / 2) * sin(diffLat / 2) +
        cos(_degreesToRadians(originLat)) * cos(_degreesToRadians(targetLat)) * sin(diffLong / 2) * sin(diffLong / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180;

  static Future<Coordinate?> getCoordinate(String address) async {
    try {
      final List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) return null;

      final List<Placemark> placemarks = await placemarkFromCoordinates(locations.first.latitude, locations.first.longitude);

      if (placemarks.isEmpty && placemarks.first.locality != null) return null;

      return Coordinate(address: address, city: placemarks.first.locality!, latitude: locations.first.latitude, longitude: locations.first.longitude);
    } catch (e) {
      log("LocationHelper - getCoordinate", time: DateTime.now(), error: e, name: "Unknown Error");
      return null;
    }
  }

  static Future<Coordinate?> getCurrentCoordinate() async {
    try {
      final LocationSettings locationSettings = const LocationSettings(distanceFilter: 0, accuracy: LocationAccuracy.high);
      final Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      final List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isEmpty && placemarks.first.locality != null) return null;

      return Coordinate(address: "Current Location", city: placemarks.first.locality!, latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      log("LocationHelper - getCurrentCoordinate", time: DateTime.now(), error: e, name: "Unknown Error");
      return null;
    }
  }

  static Future<bool> navigateToGoogleMap({required double targetLat, required double targetLong, double? originLat, double? originLong}) async {
    String? url;

    if (originLat != null && originLong != null) {
      url = "https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLong&destination=$targetLat,$targetLong&travelmode=driving";
    } else {
      url = "https://www.google.com/maps/dir/?api=1&destination=$targetLat,$targetLong&travelmode=driving";
    }

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) return false;

    return true;
  }
}

class Coordinate {
  final String address;
  final String city;
  final double latitude;
  final double longitude;

  Coordinate({required this.address, required this.city, required this.latitude, required this.longitude});
}
