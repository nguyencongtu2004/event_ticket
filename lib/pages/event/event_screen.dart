import 'package:event_ticket/pages/event/widget/event_list.dart';
import 'package:event_ticket/providers/category_provider.dart';
import 'package:event_ticket/providers/event_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  // Lưu danh sách ID của danh mục đã chọn
  List<String> selectedCategoryIds = [];

  void onSeeAllUpcomingEvents() {
    print('See all upcoming events');
  }

  void onSeeAllPopularEvents() {
    print('See all popular events');
  }

  void onEventTap(event) => context.push(Routes.getEventDetailPath(event.id));

  @override
  Widget build(BuildContext context) {
    final categoryAsyncValue = ref.watch(categoryProvider);
    final eventAsyncValue = ref.watch(eventProvider);

    return TicketScaffold(
      title: 'Events',
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(eventProvider.future),
        child: ListView(
          children: [
            // Thanh tìm kiếm
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search for events...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ).px(16).py(8),

            // Danh mục (Categories)
            categoryAsyncValue
                .when(
                  data: (categories) => Row(
                    children: categories.map((category) {
                      final isSelected =
                          selectedCategoryIds.contains(category.id);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedCategoryIds.remove(category.id);
                            } else {
                              selectedCategoryIds.add(category.id);
                            }
                          });
                        },
                        child: Chip(
                          label: Text(category.name),
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ).px(4),
                      );
                    }).toList(),
                  ).px(16).scrollHorizontal(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text('Đã xảy ra lỗi: $error'),
                  ),
                )
                .py(8),
            const SizedBox(height: 16),
            // Upcoming Events
            EventList(
              title: 'Upcoming Events',
              eventsAsyncValue: eventAsyncValue,
              filter: (event) =>
                  event.date!.isAfter(DateTime.now()) &&
                  (selectedCategoryIds.isEmpty ||
                      event.category
                          .any((cat) => selectedCategoryIds.contains(cat.id))),
              seeAll: onSeeAllUpcomingEvents,
              onEventTap: onEventTap,
            ),
            const SizedBox(height: 16),
            // Popular Events
            EventList(
              title: 'Popular Events',
              eventsAsyncValue: eventAsyncValue,
              filter: (event) =>
                  selectedCategoryIds.isEmpty ||
                  event.category
                      .any((cat) => selectedCategoryIds.contains(cat.id)),
              sort: (a, b) => b.attendees.length.compareTo(a.attendees.length),
              seeAll: onSeeAllPopularEvents,
              onEventTap: onEventTap,
            ),
            const SizedBox(height: 16),
            // All Events
            EventList(
              title: 'All Events',
              eventsAsyncValue: eventAsyncValue,
              filter: (event) =>
                  selectedCategoryIds.isEmpty ||
                  event.category
                      .any((cat) => selectedCategoryIds.contains(cat.id)),
              onEventTap: onEventTap,
            ),
          ],
        ).pOnly(bottom: 16),
      ),
    );
  }
}
