import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';

class EventManagementScreen extends StatelessWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TicketScaffold(
      title: 'Event Management',
      body: Center(
        child: Text('Event Management Screen'),
      ),
    );
  }
}
