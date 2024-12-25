import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/models/university.dart';

class User {
  final String id;
  final String? email;
  final Roles? role;
  final String? name;
  final String? avatar;
  final DateTime? birthday;
  final Genders? gender;
  final String? phone;
  final University? university;
  final Faculty? faculty;
  final Major? major;
  final String? studentId;
  final String? token;
  final List<Event>? eventsCreated;
  final List<Ticket>? ticketsBought;

  User({
    required this.id,
    this.email,
    this.role,
    this.name,
    this.avatar,
    this.birthday,
    this.gender,
    this.phone,
    this.university,
    this.faculty,
    this.major,
    this.studentId,
    this.token,
    this.eventsCreated,
    this.ticketsBought,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      role: json['role'] != null
          ? Roles.values.firstWhere((e) => e.value == json['role'])
          : null,
      name: json['name'],
      avatar: json['avatar'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      gender: json['gender'] != null
          ? Genders.values.firstWhere((e) => e.name == json['gender'])
          : null,
      phone: json['phone'],
      university: json['university'] != null
          ? University.fromJson(json['university'])
          : null,
      faculty:
          json['faculty'] != null ? Faculty.fromJson(json['faculty']) : null,
      major: json['major'] != null ? Major.fromJson(json['major']) : null,
      studentId: json['studentId'],
      token: json['token'],
      eventsCreated: json['eventsCreated'] != null
          ? (json['eventsCreated'] as List)
              .map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      ticketsBought: json['ticketsBought'] != null
          ? (json['ticketsBought'] as List)
              .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'role': role?.value,
      'name': name,
      'avatar': avatar,
      'birthday': birthday?.toIso8601String(),
      'gender': gender?.name,
      'phone': phone,
      'university': university?.id,
      'faculty': faculty?.id,
      'major': major?.id,
      'studentId': studentId,
      'token': token,
      'eventsCreated': eventsCreated?.map((e) => e.toJson()).toList(),
      'ticketsBought': ticketsBought?.map((e) => e.toJson()).toList(),
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
    University? university,
    Faculty? faculty,
    Major? major,
    String? studentId,
    String? token,
    List<Event>? eventsCreated,
    List<Ticket>? ticketsBought,
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
      token: token ?? this.token,
      eventsCreated: eventsCreated ?? this.eventsCreated,
      ticketsBought: ticketsBought ?? this.ticketsBought,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.email == email &&
        other.role == role &&
        other.name == name &&
        other.avatar == avatar &&
        other.birthday == birthday &&
        other.gender == gender &&
        other.phone == phone &&
        other.university == university &&
        other.faculty == faculty &&
        other.major == major &&
        other.studentId == studentId &&
        other.token == token;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        role.hashCode ^
        name.hashCode ^
        avatar.hashCode ^
        birthday.hashCode ^
        gender.hashCode ^
        phone.hashCode ^
        university.hashCode ^
        faculty.hashCode ^
        major.hashCode ^
        studentId.hashCode ^
        token.hashCode;
  }
}
