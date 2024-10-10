import 'dart:convert';

import 'package:time_machine/time_machine.dart';
import 'package:upper/helpers/aes_helper.dart';
import 'package:upper/helpers/date_time_helper.dart';

class User {
  final String? uid;
  final String name;
  final String surname;
  final String email;
  final String address;
  final String birthdate;
  final String birthplace;
  final String cap;
  final String city;
  final String telephone;
  final int cardNumber;
  String? id;
  String? state;

  User({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.address,
    required this.birthdate,
    required this.birthplace,
    required this.cap,
    required this.city,
    required this.telephone,
    required this.cardNumber,
    this.state
  });

  String getQrData() => AesHelper.encrypt(jsonEncode(this));

  User.fromJson(Map<String, dynamic> json)
      : this(
          uid: json['uid']! as String,
          name: json['name']! as String,
          surname: json['surname']! as String,
          email: json['email'] as String,
          address: json['address'] as String,
          birthdate: json['birthdate'] as String,
          birthplace: json['birthplace'] as String,
          cap: json['cap'] as String,
          city: json['city'] as String,
          telephone: json['telephone'] as String,
          cardNumber: json['cardNumber'] as int,
        );

  int getAge() {
    LocalDate a = LocalDate.today();
    LocalDate b = LocalDate.dateTime(DateTimeHelper.getDateTime(birthdate));
    Period diff = a.periodSince(b);
    return diff.years;
  }

  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'email': email,
      'address': address,
      'birthdate': birthdate,
      'birthplace': birthplace,
      'cap': cap,
      'city': city,
      'telephone': telephone,
      'cardNumber': cardNumber,
    };
  }
}
