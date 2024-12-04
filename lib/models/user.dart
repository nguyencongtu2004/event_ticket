import 'package:event_ticket/enum.dart';

class User {
  final String id;
  final String email;
  final Roles role;
  final String name;
  final String? avatar;
  final DateTime? birthday;
  final Genders? gender;
  final String? phone;
  final String? university;
  final String? faculty;
  final String? major;
  final String? studentId;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.avatar,
    this.birthday,
    this.gender,
    this.phone,
    this.university,
    this.faculty,
    this.major,
    this.studentId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      role: Roles.values.firstWhere((e) => e.value == json['role']),
      name: json['name'],
      avatar: json['avatar'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      gender: Genders.values.firstWhere((e) => e.name == json['gender']),
      phone: json['phone'],
      university: json['university'],
      faculty: json['faculty'],
      major: json['major'],
      studentId: json['studentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'role': role.value,
      'name': name,
      'avatar': avatar,
      'birthday': birthday?.toIso8601String(),
      'gender': gender?.name,
      'phone': phone,
      'university': university,
      'faculty': faculty,
      'major': major,
      'studentId': studentId,
    };
  }

  // copyWith method
  User copyWith({
    String? id,
    String? email,
    Roles? role,
    String? name,
    String? avatar,
    DateTime? birthday,
    Genders? gender,
    String? phone,
    String? university,
    String? faculty,
    String? major,
    String? studentId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      studentId: studentId ?? this.studentId,
    );
  }
}
