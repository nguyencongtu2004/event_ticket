import 'package:event_ticket/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class EventManagementCard extends StatelessWidget {
  const EventManagementCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          // Event image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              event.images.isNotEmpty
                  ? event.images.first
                  : 'https://placehold.co/100.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Event details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                event.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Location: ${event.location}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${DateFormat.yMMMMd().format(event.date)}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Tickets Sold: ${event.ticketsSold}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],
          ).expand(),
        ],
      ),
    ).onTap(onTap ?? () {});
  }
}
