import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/pages/ticket/widget/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class TicketList extends StatelessWidget {
  const TicketList({
    super.key,
    required this.tickets,
    required this.onTap,
  });

  final List<Ticket> tickets;
  final void Function(BuildContext, Ticket) onTap;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        width: double.infinity,
        child: const Text('No tickets available').centered(),
      ).scrollVertical();
    }

    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return TicketCard(ticket: ticket).onTap(() => onTap(context, ticket));
      },
    );
  }
}
