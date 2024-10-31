import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:upper/helpers/date_time_helper.dart';

class UpperEvent {
  final String title;
  final String description;
  final String date;
  final String time;
  final String place;
  final String imagePath;
  String? id;

  UpperEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.place,
    required this.imagePath,
    this.id,
  });

  DateTime getDate() => DateTimeHelper.getDateTime(date);

  Future<Uint8List?> getEventImage() async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(imagePath);
    return await imageRef.getData();
  }

  UpperEvent.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title']! as String,
          description: json['description']! as String,
          date: json['date']! as String,
          time: json['time']! as String,
          place: json['place']! as String,
          imagePath: json['imagePath']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'place': place,
      'imagePath': imagePath,
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
