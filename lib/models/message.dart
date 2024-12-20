import 'package:event_ticket/models/user.dart';

class Message {
  final String id;
  final String? content;
  final DateTime? time;
  final User? sender;
  final String? conversasionId;
  final String? parentMessageId;
  final bool? isEditted;

  Message({
    required this.id,
    this.content,
    this.time,
    this.sender,
    this.conversasionId,
    this.parentMessageId,
    this.isEditted,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['_id'],
        content: json['content'],
        time: json['time'] != null ? DateTime.parse(json['time']) : null,
        sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
        conversasionId: json['conversasionId'],
        parentMessageId: json['parentMessageId'],
        isEditted: json['isEditted'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'content': content,
        'time': time?.toIso8601String(),
        'sender': sender?.toJson(),
        'conversasionId': conversasionId,
        'parentMessageId': parentMessageId,
        'isEditted': isEditted,
      };

  @override
  String toString() {
    return 'Message(${toJson().toString()})';
  }
}
