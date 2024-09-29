class Role {
  final String name;

  Role({
    required this.name,
  });

  Role.fromJson(Map<String, dynamic> json)
      : this(
          name: json['name']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'name': name,
    };
  }
}
