import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/user.dart';

class Conversasion {
  final String id;
  final String? title;
  final ConversasionType? type;
  final List<User>? members;
  final DateTime? createdAt;

  Conversasion({
    required this.id,
    this.title,
    this.type,
    this.members,
    this.createdAt,
  });

  factory Conversasion.fromJson(Map<String, dynamic> json) {
    return Conversasion(
      id: json['_id'],
      title: json['title'],
      type: json['type'] != null
          ? ConversasionType.values.firstWhere((e) => e.value == json['type'])
          : null,
      members: json['members'] != null
          ? List<User>.from(json['members']
              .map((e) => User.fromJson(e as Map<String, dynamic>)))
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'type': type?.value,
      'members': members?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Conversasion(${toJson().toString()})';
  }
}
