class User {
  final String name;
  final String surname;

  User({required this.name, required this.surname});

  User.fromJson(Map<String, Object?> json)
      : this(
            name: json['name']! as String, surname: json['surname']! as String);

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'surname': surname,
    };
  }
}
