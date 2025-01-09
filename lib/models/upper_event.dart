import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:rione_cassero/helpers/date_time_helper.dart';
import 'package:http/http.dart' as http;

class UpperEvent {
  final String title;
  final String description;
  final String date;
  final String time;
  final String place;
  final String imagePath;
  int? price;
  int? childrenPrice;
  int? bookingLimit;
  String? id;
  bool? isToday;

  DateTime? date_time;

  UpperEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.place,
    required this.imagePath,
    this.id,
    this.isToday,
    this.date_time,
    this.price,
    this.childrenPrice,
    this.bookingLimit,
  });

  DateTime getDate() => DateTimeHelper.getDateTime(date);

  void checkTodayDate() {
    DateTime oggi = DateTime(DateTime.now().year,DateTime.now().month, DateTime.now().day) ;
    DateTime ieri = DateTime(DateTime.now().subtract(Duration(days: 1)).year,DateTime.now().subtract(Duration(days: 1)).month, DateTime.now().subtract(Duration(days: 1)).day) ;

    if (this.getDate().isAtSameMomentAs(oggi) || this.getDate().isAtSameMomentAs(ieri)) {
      this.isToday = true;
    } else this.isToday = false;
  }

Future<Uint8List?> getEventImage() async {
  final storageRef = FirebaseStorage.instance.ref();
  final imageRef = storageRef.child(imagePath);
  print(imagePath);
  return await imageRef.getData();
}

// Future<Uint8List?> getEventImage() async {
//   try {
//     final ref = FirebaseStorage.instance.ref(imagePath);
//     final url = await ref.getDownloadURL();

//     // Ottieni i dati dell'immagine tramite un HTTP GET
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       return response.bodyBytes;
//     } else {
//       throw Exception('Errore nel caricamento immagine: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Errore: $e');
//     return null;
//   }
// }


  UpperEvent.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title']! as String,
          description: json['description']! as String,
          date: json['date']! as String,
          time: json['time']! as String,
          place: json['place']! as String,
          imagePath: json['imagePath']! as String,
          date_time: DateTimeHelper.getDateTime(json['date']! as String),
          price: json['price'] == null ? null : json['price']  as int,
          childrenPrice: json['childrenPrice'] == null ? null : json['childrenPrice']  as int,
          bookingLimit: json['bookingLimit'] == null ? null : json['bookingLimit']  as int,
        );

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'place': place,
      'imagePath': imagePath,
      'price': price,
      'childrenPrice': childrenPrice,
      'bookingLimit': bookingLimit,
    };
  }

  Map<String, Object?> participantToJson(String userUID) {
    return {
      'id': userUID,
      'presence': true,
    };
  }
}

const months = ["GENNAIO", "FEBBRAIO", "MARZO", "APRILE", "MAGGIO", "GIUGNO", "LUGLIO", "AGOSTO", "SETTEMBRE", "OTTOBRE", "NOVEMBRE", "DICEMBRE"];
