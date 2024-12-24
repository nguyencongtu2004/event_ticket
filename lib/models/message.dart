import 'package:event_ticket/models/user.dart';

class Message {
  final String id;
  final String? content;
  final DateTime? time;
  final User? sender;
  final String? conversasionId;
  final String? parentMessageId;
  final bool? isEdited;
  final bool? isDeleted;

  Message({
    required this.id,
    this.content,
    this.time,
    this.sender,
    this.conversasionId,
    this.parentMessageId,
    this.isEdited = false,
    this.isDeleted = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['_id'],
        content: json['content'],
        time: json['time'] != null ? DateTime.parse(json['time']) : null,
        sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
        conversasionId: json['conversasionId'],
        parentMessageId: json['parentMessageId'],
        isEdited: json['isEdited'],
        isDeleted: json['isDeleted'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'content': content,
        'time': time?.toIso8601String(),
        'sender': sender?.toJson(),
        'conversasionId': conversasionId,
        'parentMessageId': parentMessageId,
        'isEdited': isEdited,
        'isDeleted': isDeleted,
      };

  Message copyWith({
    String? id,
    String? content,
    DateTime? time,
    User? sender,
    String? conversasionId,
    String? parentMessageId,
    bool? isEdited,
    bool? isDeleted,
  }) =>
      Message(
        id: id ?? this.id,
        content: content ?? this.content,
        time: time ?? this.time,
        sender: sender ?? this.sender,
        conversasionId: conversasionId ?? this.conversasionId,
        parentMessageId: parentMessageId ?? this.parentMessageId,
        isEdited: isEdited ?? this.isEdited,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  @override
  String toString() {
    return 'Message(${toJson().toString()})';
  }
}
