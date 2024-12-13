import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/requests/event_request.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/ulties/format.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.canEdit = false,
  });

  final String eventId;
  final bool? canEdit;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? event;
  final _eventRequest = EventRequest();
  final _ticketRequest = TicketRequest();

  Future<void> onJoinEvent() async {
    final response = await _ticketRequest.bookTicket(event!.id);

    if (response.statusCode != 201) {
      print('Error buying ticket: ${response.data}');
      return;
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
      context.go('${Routes.buyerHome}?page=1');
    }
  }

  void onEditEvent() {
    print('Edit event');
    context.push(Routes.editEvent, extra: event);
  }

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
      print(response.data);

      setState(() {
        event = Event.fromJson(response.data as Map<String, dynamic>);
      });
    } catch (e, st) {
      print('Error in EventDetailScreen.getEventDetail: $e');
      print(st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: event?.name ?? 'Event Detail',
      body: event == null
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
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
                    : Image.network(
                        'https://placehold.co/150.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),

              // Thông tin chi tiết sự kiện
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sự kiện
                  Text(
                    event!.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Ngày và giờ
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '${Format.formatDDMMYYYY(event!.date)} - ${Format.formatHHMM(event!.date)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Địa điểm
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        event!.location,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Thông tin người tổ chức
                  Row(
                    children: [
                      // Avatar hình tròn
                      CircleAvatar(
                        radius: 20, // Bán kính của avatar
                        backgroundImage: NetworkImage(event!.createdBy.avatar ??
                            'https://placehold.co/150.png'),
                        onBackgroundImageError: (error, stackTrace) {
                          // Trường hợp ảnh không tải được
                          print('Error loading avatar: $error');
                        },
                      ),
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
                            event!.createdBy.name ?? 'Unknown',
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

                  // Danh mục
                  Wrap(
                    spacing: 8,
                    children: event!.category.map((category) {
                      return Chip(
                        label: Text(category.name),
                        backgroundColor: Colors.blue.shade50,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Vé đã bán, người tham gia tối đa, trạng thái sự kiện
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tickets Sold: ${event!.ticketsSold}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (event?.maxAttendees != null)
                        Text(
                          'Max Attendees: ${event!.maxAttendees}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      else
                        Container(),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Số người đã tham gia
                  Text(
                    'Participants: ${event!.attendees.length}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),

                  // Trạng thái sự kiện
                  Row(
                    children: [
                      Text(
                        'Status:',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(event!.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event!.status.name.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.labelLarge!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Thông tin mô tả sự kiện
                  Text(
                    'About Event',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                ],
              ).p(16).scrollVertical().expand(),

              // Nút mua vé luôn ở dưới cùng
              if (widget.canEdit == false || widget.canEdit == null)
                ElevatedButton(
                  onPressed: onJoinEvent,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                      'Buy Ticket ${(event?.price == null || event?.price == 0) ? 'For Free' : Format.formatPrice(event!.price!)}'),
                ).p(16)
              // Nếu có quyền chỉnh sửa sự kiện
              else
                ElevatedButton(
                  onPressed: onEditEvent,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Edit Event'),
                ).p(16),
            ]),
    );
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
      default:
        return Colors.blue;
    }
  }
}
