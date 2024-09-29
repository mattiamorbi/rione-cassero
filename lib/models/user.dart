import 'dart:convert';

class User {
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

  User({
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
  });

  String getQrData() {
    // TODO: Aggiungere metodo di criptaggio dei dati scritti
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(jsonEncode(this));
  }

  User.fromJson(Map<String, dynamic> json)
      : this(
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

  Map<String, Object?> toJson() {
    return {
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
