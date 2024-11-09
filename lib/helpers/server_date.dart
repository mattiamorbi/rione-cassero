import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<DateTime?> fetchCurrentDateTime() async {
  DateTime? date;

  while (date == null) {
    final response = await http.get(Uri.parse(
        'https://api.timezonedb.com/v2.1/get-time-zone?key=4PWINFC67FAE&format=json&by=zone&zone=Europe/Rome'));


    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body);
      }
      Map<String, dynamic> data = jsonDecode(response.body);
      String dateTimeString = data['formatted']; // Ottieni la stringa della data
      date = DateTime.parse(dateTimeString);
      return date; // Convdaerte in DateTime
    } else {
      await Future.delayed(Duration(seconds: 1));
      throw Exception('Failed to load date time');
    }

  }
}