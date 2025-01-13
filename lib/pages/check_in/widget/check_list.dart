import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/providers/checked_in_ticket_provider.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class CheckList extends StatelessWidget {
  const CheckList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final checkedInTicket = ref.watch(checkedInTicketProvider).value ?? [];
        return Column(
          children: [
            Text(
              'Checked-in tickets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider().py(4),
            checkedInTicket.isEmpty
                ? const Text('No checked-in tickets').py(16).centered()
                : ListView.builder(
                    itemCount: checkedInTicket.length,
                    itemBuilder: (context, index) {
                      final ticket = checkedInTicket[index];
                      return ListTile(
                        leading: Avatar(
                          ticket.buyer,
                          radius: 25,
                        ),
                        title: Text(
                          'Attendee: ${ticket.buyer?.name ?? 'N/A'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Event: ${ticket.event?.name ?? 'N/A'}'),
                            if (ticket.checkInTime != null)
                              Text(
                                  'Check-in Time: ${ticket.checkInTime!.toFullDate()}'),
                          ],
                        ),
                      );
                    },
                  ).expand(),
          ],
        );
      },
    );
  }
}
