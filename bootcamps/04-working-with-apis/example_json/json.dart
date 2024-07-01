import 'dart:convert';

class User {
  final String name;
  final int age;
  final String email;

  User({required this.name, required this.age, required this.email});

  // Factory constructor for creating a new User instance from a map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      age: json['age'] as int,
      email: json['email'] as String,
    );
  }

  // Method for converting a User instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'email': email,
    };
  }
}

void main() {
  // Example JSON string
  String jsonString = '{"name": "John Doe", "age": 30, "email": "john.doe@example.com"}';

  // Deserialize JSON string to User object
  Map<String, dynamic> userMap = jsonDecode(jsonString);
  User user = User.fromJson(userMap);

  print('Name: ${user.name}');
  print('Age: ${user.age}');
  print('Email: ${user.email}');

  // Serialize User object to JSON string
  String serialized = jsonEncode(user.toJson());
  print('Serialized: $serialized');
}
