import 'dart:convert';

import 'package:flutter/services.dart';

class PhoneDetail {
  String country;
  String countryCode;
  String dialCode;
  String hintLabel;
  String number;

  PhoneDetail({this.country = "Malaysia", this.countryCode = "MY", this.dialCode = "60", this.hintLabel = "123456789", this.number = ""});

  factory PhoneDetail.fromJson(Map<String, dynamic> json) => PhoneDetail(
    country: json["name"] as String? ?? "",
    countryCode: json["iso2_cc"] as String? ?? "",
    dialCode: json["e164_cc"] as String? ?? "",
    hintLabel: json["example"] as String? ?? "",
  );

  static String countryCodeToEmoji(String countryCode) => countryCode.toUpperCase().runes.map((char) => String.fromCharCode(char + 127397)).join();

  String get displayFlagCode => "${countryCodeToEmoji(countryCode)} (+$dialCode)";

  static Future<List<PhoneDetail>> loadAll() async {
    final String response = await rootBundle.loadString("assets/jsons/country_codes.json");
    final List<dynamic> data = json.decode(response);

    return data.map((detail) => PhoneDetail.fromJson(detail)).toList();
  }

  Future<void> update(String tmpDialCode) async {
    final List<PhoneDetail> allDetails = await loadAll();

    PhoneDetail newDetail = allDetails.firstWhere((detail) => detail.dialCode == tmpDialCode);

    country = newDetail.country;
    countryCode = newDetail.countryCode;
    dialCode = newDetail.dialCode;
    hintLabel = newDetail.hintLabel;
  }

  String toCompare() => "$country $countryCode $dialCode $hintLabel $number";
}
