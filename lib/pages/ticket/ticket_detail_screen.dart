import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:event_ticket/ulties/format.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  final String ticketId;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _ticketRequest = TicketRequest();
  Ticket? ticket;

  @override
  void initState() {
    super.initState();
    // Lấy thông tin sự kiện từ API mà không cần đợi có data
    getTicketDetail();
  }

  Future<void> getTicketDetail() async {
    try {
      // Lấy thông tin sự kiện từ API
      final response = await _ticketRequest.getTicketDetail(widget.ticketId);

      print(response.data);

      if (response.statusCode == 200) {
        setState(() {
          ticket = Ticket.fromJson(response.data as Map<String, dynamic>);
        });
      }
    } catch (e, st) {
      print('Error in TicketDetailScreen.getTicketDetail: $e');
      print(st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
        title: ticket?.event?.name ?? 'Ticket Detail',
        body: ticket == null
            ? const CircularProgressIndicator().centered()
            : const Text('data'));
  }
}
