import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/models/user.dart';

class TransferTicket {
  String? id;
  Ticket? ticket;
  User? fromUser;
  User? toUser;
  TransferStatus? status;

  TransferTicket({
    this.id,
    this.ticket,
    this.fromUser,
    this.toUser,
    this.status,
  });

  factory TransferTicket.fromJson(Map<String, dynamic> json) => TransferTicket(
        id: json['_id'],
        ticket: json['ticket'] != null ? Ticket.fromJson(json['ticket']) : null,
        fromUser:
            json['fromUser'] != null ? User.fromJson(json['fromUser']) : null,
        toUser: json['toUser'] != null ? User.fromJson(json['toUser']) : null,
        status: json['status'] != null
            ? TransferStatus.values.firstWhere((e) => e.value == json['status'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'ticket': ticket?.toJson(),
        'fromUser': fromUser?.toJson(),
        'toUser': toUser?.toJson(),
        'status': status?.value,
      };

  @override
  String toString() {
    return 'TransferTicket(id: $id, ticket: $ticket, fromUser: $fromUser, toUser: $toUser, status: $status)';
  }
}
