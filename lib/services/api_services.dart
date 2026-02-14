import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:stereo98/helper/api_helper.dart';
import 'package:stereo98/model/radio_model.dart';

class ApiServices {
  static var client = http.Client();

  //for radio api
  //get method
  static Future<RadioModel?> radioApi() async {
    final response = await client.get(ApiHelper.url(
        'https://radio.usacampus.us/listen/radio_apyt/sonando.mp3'));

    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      debugPrint('--------from radio api data: $jsonString');
      return RadioModel.fromJson(jsonString);
    }
    return null;
  }
}
