import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Ticket',
      body: Text('abc').centered(),
    );
  }
}
