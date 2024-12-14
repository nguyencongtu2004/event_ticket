import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/ulties/format.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart'; // Thư viện hỗ trợ việc viết code nhanh hơn

class EventCard extends StatelessWidget {
  final Event event;
  final void Function(Event) onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Chiều rộng của mỗi thẻ
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Nội dung chính
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh sự kiện
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.images.isNotEmpty
                      ? event.images[0]
                      : 'https://placehold.co/150.png',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Nội dung
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name ?? 'Event Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.location ?? 'Location',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).expand(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.price != null ? Format.formatPrice(event.price!) : 'Free',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ).p(8),
            ],
          ),
          // Thời gian diễn ra sự kiện
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                Format.formatShortDay(event.date!),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ).py(4).onTap(() => onTap(event));
  }
}
