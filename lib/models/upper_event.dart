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
