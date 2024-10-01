import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:upper/helpers/date_time_helper.dart';

class UpperEvent {
  final String title;
  final String date;
  final String time;
  final String place;
  final String imagePath;

  UpperEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.place,
    required this.imagePath,
  });

  DateTime getDate() => DateTimeHelper.getDateTime(date);

  Future<String> getEventImage() async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(imagePath);
    return await imageRef.getDownloadURL();
  }

  static Future<List<UpperEvent>> getUpperEvents() async {
    List<UpperEvent> events = [];

    var eventsCollection = FirebaseFirestore.instance.collection("events");
    await eventsCollection.get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          events.add(UpperEvent.fromJson(doc.data()));
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    return events;
  }

  UpperEvent.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title']! as String,
          date: json['date']! as String,
          time: json['time']! as String,
          place: json['place']! as String,
          imagePath: json['imagePath']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'date': date,
      'time': time,
      'place': place,
      'imagePath': imagePath,
    };
  }
}

const months = ["GENNAIO", "FEBBRAIO", "MARZO", "APRILE", "MAGGIO", "GIUGNO", "LUGLIO", "AGOSTO", "SETTEMBRE", "OTTOBRE", "NOVEMBRE", "DICEMBRE"];
