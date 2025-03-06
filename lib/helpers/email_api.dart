import 'dart:convert';

import 'package:dio/dio.dart';

class EmailAPI {
  String url = "";
  String secret = "";

  EmailAPI({
    required this.url,
    required this.secret,
  });

  EmailAPI.fromJson(Map<String, dynamic> json)
      : this(
          url: json['url'] == null ? "" : json['url'] as String,
          secret: json['secret'] == null ? "" : json['secret'] as String,
        );

  bool isValid() {
    return (url.length != 0 && secret.length != 0);
  }

  Future<bool> sendConfirmationEmail(String address, String eventName, String personName, String bookName, String eventDate, String bookInfo) async {
    var headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'text/plain',
      'Authorization': 'Basic $secret',
    };



    var body =
        "<html>\r\n"
        "<head>\r\n"
        "<title>Conferma Prenotazione</title>\r\n"
        "</head>\r\n"
        "<body>\r\n"
        "<h2>Ciao $personName,</h2>\r\n"
        "<p>La tua prenotazione a nome di <b>$bookName</b> è stata confermata con successo.</p>\r\n"
        "<h3>Dettagli Prenotazione:</h3>\r\n"
        "<ul>\r\n"
        "<li><b>Evento:</b> $eventName</li>\r\n"
        "<li><b>Data:</b> $eventDate</li>\r\n"
        "<li><b>Numero di persone:</b> $bookInfo</li>\r\n"
        "</ul>\r\n"
        "<p>Ti aspettiamo!</p>\r\n"
        "<br>\r\n"
        "A presto,<br>\r\n"
        "<strong>Rione Cassero</strong>\r\n"
        "</body>\r\n"
        "</html>\r\n";

    var data = json.encode({
      "emailTo": ["${address}"],
      "emailBcc": [],
      "emailCc": [],
      "subject": "Prenotazione confermata",
      "body": body
    });
    var dio = Dio();
    var response;
    try {
      response = await dio.request(
        'https://$url',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );
    } catch (e) {
      return false;
    }

    if (response.statusCode == 200) {
      print(json.encode(response.data));

      return true;
    } else {
      print(response.statusMessage);
      return false;
    }
  }
}
