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
  String? uid;

  ParticipantDataCassero({this.uid, required this.bookUserName, required this.name, required this.number});

  static ParticipantDataCassero? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return ParticipantDataCassero(
      uid: json['uid'] == null ? "" : json['uid']!,
      bookUserName: json['bookUserName'] == null ? "" : json['bookUserName']!,
      name: json['name'] == null ? "" : json['name']!,
      number: json['number'] == null ? 0 : json['number']! as int,
    );
  }

  Map<String, Object?> toJson() {
    return {'uid': uid, 'bookUserName':bookUserName, 'name': name, 'number': number};
  }
}
