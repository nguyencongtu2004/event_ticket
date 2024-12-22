import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({required this.ticket, super.key});

  final Ticket ticket;

  void onCalendar() {
    print('onCalendar');
  }

  @override
  Widget build(BuildContext context) {
    final isTicketFree =
        ticket.event?.price == null || ticket.event?.price == 0.0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Text(
                'Booking Code: ${ticket.bookingCode}',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ticket.event?.name ?? "N/A",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ).expand(),
                    IconButton(
                      icon: const Icon(Icons.event),
                      color: Colors.blue.shade400,
                      onPressed: onCalendar,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(ticket.event!.date!.toDDMMYYYY()),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(ticket.event?.location ?? "N/A"),
                  ],
                ),
                const SizedBox(height: 8),
                if (!isTicketFree)
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(ticket.event?.price?.toCurrency() ?? "N/A"),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        ticket.status?.name ?? "N/A",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: ticket.status == TicketStatus.booked
                          ? Colors.green
                          : Colors.red,
                    ),
                    if (!isTicketFree)
                      Chip(
                        label: Text(
                          ticket.paymentStatus?.name ?? "N/A",
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            ticket.paymentStatus == PaymentStatus.paid
                                ? Colors.green
                                : Colors.orange,
                      ),
                  ],
                ),
              ],
            ).p(16),
          ],
        ),
      ),
    );
  }
}
