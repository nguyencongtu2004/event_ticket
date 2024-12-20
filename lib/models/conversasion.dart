import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/user.dart';

class Conversasion {
  final String id;
  final String? title;
  final ConversasionType? type;
  final List<User>? members;

  Conversasion({
    required this.id,
    this.title,
    this.type,
    this.members,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'type': type?.value,
      'members': members?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Conversasion(${toJson().toString()})';
  }
}
