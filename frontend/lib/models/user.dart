import 'dart:ffi';

class User {
  final int? id;
  final String username;
  final String password;
  final bool isAdmin;

  User(
      {this.id, // primary key
        required this.username,
        required this.password,
        required this.isAdmin});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['pk'],
      username: json["fields"]['username'],
      password: json["fields"]['password'],
      isAdmin: json["fields"]['is_system_admin']);

  // for print
  @override
  String toString() {
    return 'User{id: $id, name: $username, password: $password, isAdmin: $isAdmin}';
  }
}