import 'package:event_ticket/enum.dart';

class Notification {
  String id;
  NotificationType? type;
  String? title;
  String? body;
  Map<String, dynamic>? data;
  bool? isRead;
  DateTime? createdAt;

  Notification({
    required this.id,
    this.type,
    this.title,
    this.body,
    this.data,
    this.isRead,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json['_id'],
        type: json['type'] != null
            ? NotificationType.values.firstWhere((e) => e.value == json['type'],
                orElse: () => NotificationType.unknown)
            : null,
        title: json['title'],
        body: json['body'],
        data: json['data'],
        isRead: json['isRead'],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type?.value,
        'title': title,
        'body': body,
        'data': data,
        'isRead': isRead,
        'createdAt': createdAt?.toIso8601String(),
      };

  @override
  String toString() => 'Notification: ${toJson().toString()}';
}
