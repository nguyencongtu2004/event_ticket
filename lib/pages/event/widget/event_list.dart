import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/pages/event/widget/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class EventList extends StatelessWidget {
  final String title;
  final AsyncValue<List<Event>> eventsAsyncValue;
  final bool Function(Event) filter;
  final int Function(Event, Event)? sort;
  final Function()? seeAll;
  final Function(Event event) onEventTap;
  final bool scrollVertical;

  const EventList({
    super.key,
    required this.title,
    required this.eventsAsyncValue,
    required this.filter,
    this.sort,
    this.seeAll,
    required this.onEventTap,
    this.scrollVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (seeAll != null)
              TextButton(
                onPressed: seeAll,
                child: const Text('See All'),
              ),
          ],
        ).px(16).py(8),

        // Event List
        eventsAsyncValue.when(
          data: (events) {
            var filteredEvents = events.where(filter).toList();
            if (sort != null) {
              filteredEvents.sort(sort);
            }

            if (filteredEvents.isEmpty) {
              return const Center(child: Text('No events available.')).py(16);
            }

            return scrollVertical
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return EventCard(
                        event: event,
                        onTap: onEventTap,
                      ).px(16).py(8);
                    },
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return EventCard(
                        event: event,
                        onTap: onEventTap,
                      ).w(220);
                    },
                  ).h(220);
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) =>
              Center(child: Text('Error: $error')).py(16),
        ),
      ],
    );
  }
}
