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

class EventManagementScreen extends ConsumerStatefulWidget {
  const EventManagementScreen({super.key});

  @override
  ConsumerState<EventManagementScreen> createState() =>
      _EventManagementScreenState();
}

class _EventManagementScreenState extends ConsumerState<EventManagementScreen> {
  List<Event> displayedEvents = []; // Danh sách hiển thị

  @override
  void initState() {
    super.initState();
    _initializeEvents();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _initializeEvents();
  // }

  @override
  void dispose() {
    print('Disposing EventManagementScreen');
    super.dispose();
  }

  Future<void> _initializeEvents() async {
    final events = await ref.refresh(eventManagementProvider.future);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          displayedEvents = List.from(events);
        });
      });
    }
  }

  Future<void> onEventTap(BuildContext context, Event event) async {
    // Mở trang chi tiết sự kiện
    final bool? updated =
        await context.push(Routes.getEventDetailPath(event.id), extra: true);
    if (updated != null && updated) {
      context.showAnimatedToast('Event updated successfully!');

      // Refresh danh sách sự kiện
      await _initializeEvents();
    }
  }

  Future<void> onCreateEvent(BuildContext context, WidgetRef ref) async {
    final bool? created = await context.push<bool>(Routes.createEvent);
    if (created != null && created) {
      context.showAnimatedToast('Event created successfully!');

      // Refresh danh sách sự kiện
      await _initializeEvents();
    }
  }

  void onDeleteEvent(Event event) {
    // Xóa thật sự trong provider
    ref.read(eventManagementProvider.notifier).deleteEvent(event.id);
    print('Event permanently deleted: ${event.name}');
    // Không cần làm gì thêm vì `displayedEvents` đã được cập nhật
  }

  void onUndoDelete(Event event, int index) {
    setState(() {
      displayedEvents.insert(index, event);
    });
  }

  void showUndoSnackBar(BuildContext context, Event event, VoidCallback onUndo,
      VoidCallback onConfirmDelete) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger
        .showSnackBar(
          SnackBar(
            content: Text('Deleted "${event.name}". Undo?'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                onUndo(); // Call onUndo to cancel deletion
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
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Event Management',
      body: RefreshIndicator(
        onRefresh: () => _initializeEvents(),
        child: displayedEvents.isEmpty
            ? SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 100,
                child: const Text('No events available').centered(),
              ).scrollVertical().centered()
            : _buildEventList(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addEvent',
        onPressed: () => onCreateEvent(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayedEvents.length,
      itemBuilder: (context, index) {
        final event = displayedEvents[index];
        return Dismissible(
          key: ValueKey(event.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            final removedEvent = displayedEvents[index]; // Lưu item bị vuốt

            setState(() {
              displayedEvents.removeAt(index); // Xóa khỏi danh sách hiển thị
            });

            // Hiển thị snackbar để hoàn tác
            showUndoSnackBar(
              context,
              removedEvent,
              () => onUndoDelete(
                  removedEvent, index), // Thêm lại item nếu hoàn tác
              () => onDeleteEvent(removedEvent), // Xóa thật nếu không hoàn tác
            );
          },
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
