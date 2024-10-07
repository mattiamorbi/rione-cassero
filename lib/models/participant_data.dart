class ParticipantData {
  final bool booked;
  final bool presence;

  ParticipantData({required this.booked, required this.presence});

  static ParticipantData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return ParticipantData(
      booked: json['booked']! as bool,
      presence: json['presence']! as bool,
    );
  }

  Map<String, Object?> toJson() {
    return {'booked': booked, 'presence': presence};
  }
}
