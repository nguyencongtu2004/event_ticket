import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/providers/ticket_provider.dart';
import 'package:event_ticket/requests/event_request.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.canEdit = false,
  });

  final String eventId;
  final bool? canEdit;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  Event? event;
  final _eventRequest = EventRequest();
  final _ticketRequest = TicketRequest();
  var eventNotfound = false;
  var _isJoining = false;

  Future<void> onJoinEvent() async {
    setState(() => _isJoining = true);
    final response = await _ticketRequest.bookTicket(event!.id);
    setState(() => _isJoining = false);
    if (response.statusCode != 201) {
      return context.showAnimatedToast(response.data['message']);
    }

    final ticket = Ticket.fromJson(response.data as Map<String, dynamic>);

    if (ticket.paymentData?.deeplink != null) {
      final Uri url = Uri.parse(ticket.paymentData!.deeplink!);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('Could not launch $url: $e');
      }
    } else {
      ref.invalidate(ticketProvider);
      context.go(Routes.ticket);
    }
  }

  void onEditEvent() => context.push(Routes.editEvent, extra: event);

  void onStatisticsTap() => context.push(Routes.reportEvent, extra: event);

  @override
  void initState() {
    super.initState();
    // Lấy thông tin sự kiện từ API mà không cần đợi có data
    getEventDetail();
  }

  Future<void> getEventDetail() async {
    try {
      // Lấy thông tin sự kiện từ API
      final response = await _eventRequest.getEventDetail(widget.eventId);

      if (response.statusCode == 200) {
        setState(() =>
            event = Event.fromJson(response.data as Map<String, dynamic>));
        getAttendees(event!.id).then((value) {
          setState(() => event = event!.copyWith(attendees: value));
        });
      } else {
        setState(() => eventNotfound = true);
      }
    } catch (e, st) {
      print('Error in EventDetailScreen.getEventDetail: $e');
      print(st);
      setState(() {
        eventNotfound = true;
      });
    }
  }

  Future<List<User>> getAttendees(String eventId) async {
    final response = await EventRequest().getEventAttendees(eventId);
    if (response.statusCode == 200) {
      return (response.data as List).map((e) => User.fromJson(e)).toList();
    } else {
      context.showAnimatedToast(response.data['message']);
      return [];
    }
  }

  void onForumTap() {
    print('Forum tapped: ${Routes.forum} extra: ${event?.conversation}');
    context.push(Routes.getForumDetailPath(event!.conversation!.id),
        extra: event?.conversation);
  }

  void onStatusTap() => context.push(Routes.eventParticipants, extra: event);

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: event?.name ?? 'Event Detail',
      body: eventNotfound
          ? Text(
              'Event not found',
              style: Theme.of(context).textTheme.bodyLarge,
            ).centered()
          : event == null
              ? const Center(child: CircularProgressIndicator())
              : Column(children: [
                  RefreshIndicator(
                    onRefresh: () => getEventDetail(),
                    child: ListView(
                      // shrinkWrap: true, // chiếm ít không gian nhất có thể (tốn tài nguyên)
                      children: [
                        // Hình ảnh có thể cuộn ngang
                        SizedBox(
                          height: 200,
                          child: event!.images.isNotEmpty
                              ? PageView.builder(
                                  itemCount: event!.images.length,
                                  itemBuilder: (context, index) {
                                    return Image.network(
                                      event!.images[index],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.image,
                                  color: Colors.grey.shade400,
                                  size: 100,
                                ),
                        ),

                        // Thông tin chi tiết sự kiện
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên sự kiện
                            Text(
                              event!.name ?? 'Event Name',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),

                            // Ngày và giờ
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  event!.date!.toFullDate(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Địa điểm
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  event!.location ?? 'Location',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Danh mục
                            Wrap(
                              spacing: 8,
                              children: event!.category.map((category) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Thông tin người tổ chức
                            Row(
                              children: [
                                // Avatar hình tròn
                                Avatar(event!.createdBy, radius: 20),
                                const SizedBox(width: 8),

                                // Tên người tổ chức
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Organized by',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    Text(
                                      event!.createdBy?.name ?? 'Unknown',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Thông tin vé và người tham gia
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildInfoTile(
                                          context,
                                          Icons.confirmation_number,
                                          'Tickets Sold',
                                          '${event!.ticketsSold}',
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      if (event?.maxAttendees != null)
                                        Expanded(
                                          child: _buildInfoTile(
                                            context,
                                            Icons.groups,
                                            'Max Attendees',
                                            '${event!.maxAttendees}',
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoTile(
                                    context,
                                    Icons.people,
                                    'Participants',
                                    '${event!.attendees.length}',
                                  ),
                                  Text(
                                    'Details',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                    textAlign: TextAlign.end,
                                  ).w(double.infinity),
                                ],
                              ),
                            ).onTap(onStatusTap),
                            const SizedBox(height: 16),

                            // Trạng thái sự kiện
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _getStatusColor(event!.status!)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(event!.status!),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(event!.status!),
                                    color: _getStatusColor(event!.status!),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Status:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(event!.status!),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      event!.status!.name.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Đi đến forum
                            if (event?.conversation != null &&
                                event!.status != EventStatus.cancelled)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: onForumTap,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Go to Forum'),
                                      SizedBox(width: 8),
                                      Icon(Icons.forum),
                                    ],
                                  ),
                                ),
                              ),

                            // Thông tin mô tả sự kiện
                            Text(
                              'About Event',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event?.description ?? 'Description',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ).p(16),
                      ],
                    ),
                  ).expand(),
                  // Nút mua vé luôn ở dưới cùng
                  if (widget.canEdit == false || widget.canEdit == null)
                    _getBuyerBottomButton(event!).p(16)
                  // Nếu có quyền chỉnh sửa sự kiện
                  else
                    _getCreatorBottomButton().p(16),
                ]),
    );
  }

  Widget _getBuyerBottomButton(Event event) {
    final isEventCancelled = event.status == EventStatus.cancelled;
    final isEventInFuture = event.date!.isAfter(DateTime.now());
    final buttonText = isEventCancelled
        ? 'This event has been cancelled'
        : isEventInFuture
            ? 'Buy Ticket ${(event.price == null || event.price == 0) ? 'For Free' : event.price!.toCurrency()}'
            : 'This event has started, you can no longer buy tickets';
    final onPress = isEventInFuture && !isEventCancelled && !_isJoining
        ? onJoinEvent
        : null;

    return ElevatedButton.icon(
      onPressed: onPress,
      icon: _isJoining
          ? const CircularProgressIndicator().w(20).h(20)
          : const Icon(Icons.attach_money),
      label: Text(
        buttonText,
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
      ),
    );
  }

  Widget _getCreatorBottomButton() {
    return Row(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          onPressed: onStatisticsTap,
          icon: const Icon(Icons.bar_chart_rounded),
          label: const Text('Statistics'),
        ).expand(),
        ElevatedButton.icon(
          onPressed: onEditEvent,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Event'),
        ).expand(),
      ],
    ).expand();
  }

  // Hàm lấy màu sắc theo trạng thái sự kiện
  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.active:
        return Colors.green;
      case EventStatus.completed:
        return Colors.grey;
      case EventStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildInfoTile(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(EventStatus status) {
    switch (status) {
      case EventStatus.active:
        return Icons.event_available;
      case EventStatus.completed:
        return Icons.event_busy;
      case EventStatus.cancelled:
        return Icons.event_busy;
    }
  }
}
