import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/pages/event/widget/event_management_card.dart';
import 'package:event_ticket/providers/event_management_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class EventManagementScreen extends ConsumerWidget {
  const EventManagementScreen({super.key});

  Future<void> onEventTap(BuildContext context, Event event) async {
    final bool? updated =
        await context.push(Routes.getEventDetailPath(event.id), extra: true);
    if (updated != null && updated) {
      context.showAnimatedToast('Event updated successfully!');
    }
  }

  Future<void> onCreateEvent(BuildContext context, WidgetRef ref) async {
    final bool? created = await context.push<bool>(Routes.createEvent);
    if (created != null && created) {
      context.showAnimatedToast('Event created successfully!');
      return ref.refresh(eventManagementProvider.future);
    }
  }

  void onDissmissed({
    required Event removedEvent,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    //final removedEvent = events[index];

    // Xóa lạc quan
    final previousState = ref
        .read(eventManagementProvider.notifier)
        .optimisticUpdateOnDelete(removedEvent.id);

    // Hiển thị SnackBar
    showUndoSnackBar(
      context,
      removedEvent,
      () {
        // Hoàn tác xóa
        ref.read(eventManagementProvider.notifier).restoreEvent(previousState);
      },
      () async {
        // Xác nhận xóa từ server
        final success = await ref
            .read(eventManagementProvider.notifier)
            .deleteEvent(removedEvent.id);

        if (!success) {
          context.showAnimatedToast('Failed to delete event!');
          // Khôi phục nếu xóa thất bại
          ref
              .read(eventManagementProvider.notifier)
              .restoreEvent(previousState);
        } else {
          context.showAnimatedToast('Event deleted successfully!');
        }
      },
    );
  }

  void showUndoSnackBar(
    BuildContext context,
    Event event,
    VoidCallback onUndo,
    VoidCallback onConfirmDelete,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger
        .showSnackBar(
          SnackBar(
            content: Text('Deleted "${event.name}". Undo?'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                onUndo();
                scaffoldMessenger.hideCurrentSnackBar();
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        onConfirmDelete();
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventManagementProvider);

    return TicketScaffold(
      title: 'Event Management',
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(eventManagementProvider.future),
        child: eventState.when(
          data: (events) {
            if (events.isEmpty) {
              return SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 100,
                child: const Text('No events available').centered(),
              ).scrollVertical().centered();
            }
            return _buildEventList(context, ref, events);
          },
          loading: () => const CircularProgressIndicator().centered(),
          error: (e, st) => Text('Error: $e').centered(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addEvent',
        onPressed: () => onCreateEvent(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList(
      BuildContext context, WidgetRef ref, List<Event> events) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Dismissible(
          key: ValueKey(event.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDissmissed(
            removedEvent: event,
            context: context,
            ref: ref,
          ),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: EventManagementCard(
            event: event,
            onTap: () => onEventTap(context, event),
          ),
        );
      },
    );
  }
}
