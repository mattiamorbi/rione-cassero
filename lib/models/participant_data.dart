import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantData {
  late bool booked;
  bool presence;

  ParticipantData({required this.booked, required this.presence});

  static ParticipantData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return ParticipantData(
      booked: json['booked'] == null ? false : json['booked']! as bool,
      presence: json['presence'] == null ? false : json['presence']! as bool,
    );
  }

  Map<String, Object?> toJson() {
    return {'booked': booked, 'presence': presence};
  }
}

class ParticipantDataCassero {
  late String name;
  String bookUserName;
  int number;
  int childrenNumber;
  String? uid;
  String eventUid;
  DateTime? date;
  bool? allergy;
  String? allergyNote;

  ParticipantDataCassero({this.uid, required this.bookUserName, required this.name, required this.number, required this.childrenNumber, required this.eventUid, this.date, this.allergy, this.allergyNote });

  static ParticipantDataCassero? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return ParticipantDataCassero(
      uid: json['uid'] == null ? "" : json['uid']!,
      eventUid: json['eventUid'] == null ? "" : json['eventUid']!,
      bookUserName: json['bookUserName'] == null ? "" : json['bookUserName']!,
      name: json['name'] == null ? "" : json['name']!,
      allergyNote: json['allergyNote'] == null ? "" : json['allergyNote']!,
      number: json['number'] == null ? 0 : json['number']! as int,
      childrenNumber: json['childrenNumber'] == null ? 0 : json['childrenNumber']! as int,
      allergy: json['allergy'] == null ? false : json['allergy']! == true ? true : false,
      date: json['date'] == null ? null : (json['date'] as Timestamp).toDate(),
    );
  }

  Map<String, Object?> toJson() {
    return {'uid': uid, 'eventUid': eventUid, 'bookUserName':bookUserName, 'name': name, 'number': number, 'childrenNumber':childrenNumber, 'date':date, 'allergy':allergy, 'allergyNote':allergyNote};
  }
}
