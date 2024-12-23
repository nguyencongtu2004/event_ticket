import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final void Function(Event) onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth > 250;
        final cardHeight = isWideLayout ? 170.0 : 250.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Hình ảnh nền
              if (isWideLayout)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: event.images.isNotEmpty
                      ? Image.network(
                          event.images.first,
                          width: double.infinity,
                          height: cardHeight,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image,
                          color: Colors.grey.shade400,
                          size: cardHeight,
                        ).centered(),
                ),

              // Overlay gradient cho layout rộng
              if (isWideLayout)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),

              // Nội dung
              if (isWideLayout)
                // Layout rộng: hiển thị nội dung bên cạnh hình ảnh
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              event.name ?? 'Event Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location ?? 'Location',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            event.price != null
                                ? event.price!.toCurrency()
                                : 'Free',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                // Layout hẹp: hiển thị nội dung theo cột
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: event.images.isNotEmpty
                          ? Image.network(
                              event.images.first,
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.image,
                              color: Colors.grey.shade400,
                              size: 120,
                            ).centered(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
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
                                Expanded(
                                  child: Text(
                                    event.location ?? 'Location',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              event.price != null
                                  ? event.price!.toCurrency()
                                  : 'Free',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // Thời gian diễn ra sự kiện
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: event.date!.isBefore(DateTime.now())
                        ? Colors.yellow.withValues(alpha: 0.8)
                        : Colors.blue.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.date!.toShortDay(),
                    style: TextStyle(
                      color: event.date!.isBefore(DateTime.now())
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).py(4).onTap(() => onTap(event));
      },
    );
  }
}
