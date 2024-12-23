import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/pages/event/widget/event_card.dart';
import 'package:event_ticket/requests/event_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class EventListScreen extends ConsumerStatefulWidget {
  final String title;
  final String sortBy;

  const EventListScreen({
    super.key,
    required this.title,
    required this.sortBy,
  });

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final _eventRequest = EventRequest();
  List<Event> events = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => isLoading = true);
    try {
      final response = await _eventRequest.getEvents(
        queryParameters: {
          'isAfter': true,
          'sortBy': widget.sortBy,
        },
      );
      final results = List<Event>.from((response.data as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>)));
      setState(() {
        events = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      context.showAnimatedToast(e.toString(), isError: true);
    }
  }

  void onEventTap(Event event) =>
      context.push(Routes.getEventDetailPath(event.id));

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: widget.title,
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: isLoading
            ? const CircularProgressIndicator().centered()
            : events.isEmpty
                ? Text(
                    'No events found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ).centered()
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return EventCard(
                        event: events[index],
                        onTap: (event) => onEventTap(event),
                      );
                    },
                  ),
      ),
    );
  }
}
