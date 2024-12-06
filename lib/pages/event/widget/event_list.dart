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

  const EventList({
    super.key,
    required this.title,
    required this.eventsAsyncValue,
    required this.filter,
    this.sort,
    this.seeAll,
    required this.onEventTap,
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (seeAll != null)
              TextButton(
                onPressed: seeAll,
                child: const Text('See All'),
              ),
          ],
        ).px(16).py(8),

        // Danh sách sự kiện
        eventsAsyncValue.when(
          data: (events) {
            var filteredEvents = events.where(filter).toList();
            if (sort != null) {
              filteredEvents.sort(sort);
            }

            return filteredEvents.isNotEmpty
                ? SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return EventCard(
                          event: event,
                          onTap: onEventTap,
                        );
                      },
                    ),
                  )
                : const Center(child: Text('Không có sự kiện nào.'));
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Đã xảy ra lỗi: $error')),
        ),
      ],
    );
  }
}
