class UpperEvent {
  final String title;
  final String date;
  final String time;
  final String place;

  UpperEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.place,
  });

  UpperEvent.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title']! as String,
          date: json['date']! as String,
          time: json['time']! as String,
          place: json['place']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'date': date,
      'time': time,
      'place': place,
    };
  }
}

const months = [
  "GENNAIO",
  "FEBBRAIO",
  "MARZO",
  "APRILE",
  "MAGGIO",
  "GIUGNO",
  "LUGLIO",
  "AGOSTO",
  "SETTEMBRE",
  "OTTOBRE",
  "NOVEMBRE",
  "DICEMBRE"
];
