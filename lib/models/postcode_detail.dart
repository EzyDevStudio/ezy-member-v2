import 'dart:convert';

import 'package:flutter/services.dart';

class PostcodeDetail {
  String city;
  String postcode;
  String stateName;

  PostcodeDetail({required this.city, required this.postcode, required this.stateName});

  factory PostcodeDetail.fromJson(Map<String, dynamic> json) => PostcodeDetail(
    city: json["city"] as String? ?? "",
    postcode: json["postcode"] as String? ?? "",
    stateName: json["state_name"] as String? ?? "",
  );

  static Future<List<PostcodeDetail>> loadAll() async {
    final String response = await rootBundle.loadString("assets/jsons/postcodes.json");
    final List<dynamic> data = json.decode(response);

    return data.map((detail) => PostcodeDetail.fromJson(detail)).toList();
  }
}
