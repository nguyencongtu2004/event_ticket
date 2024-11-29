import 'package:event_ticket/enum.dart';

class User {
  final String id;
  final String email;
  final Roles role;
  final String name;
  final String avatar;
  final DateTime birthday;
  final Genders gender;
  final String phone;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.avatar,
    required this.birthday,
    required this.gender,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      email: json['email'],
      role: Roles.values.firstWhere((e) => e.toString() == json['role']),
      name: json['name'],
      avatar: json['avatar'],
      birthday: DateTime.parse(json['birthday']),
      gender: Genders.values.firstWhere((e) => e.toString == json['gender']),
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'email': email,
      'role': role.toString(),
      'name': name,
      'avatar': avatar,
      'birthday': birthday.toIso8601String(),
      'gender': gender.toString(),
      'phone': phone,
    };
  }
}
