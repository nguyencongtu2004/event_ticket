import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';

class TransferTicketScreen extends StatefulWidget {
  const TransferTicketScreen({super.key});

  @override
  State<TransferTicketScreen> createState() => _TransferTicketScreenState();
}

class _TransferTicketScreenState extends State<TransferTicketScreen> {
  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Transfer Ticket',
      body: const Center(
        child: Text('Transfer Ticket Screen'),
      ),
    );
  }
}
