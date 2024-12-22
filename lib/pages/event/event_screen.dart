import 'package:event_ticket/pages/event/widget/event_list.dart';
import 'package:event_ticket/providers/category_provider.dart';
import 'package:event_ticket/providers/event_provider.dart';
import 'package:event_ticket/providers/notification_provider.dart';
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
  int unreadNotificationCount = 0;

  void onSeeAllUpcomingEvents() {
    print('See all upcoming events');
  }

  void onSeeAllPopularEvents() {
    print('See all popular events');
  }

  void onEventTap(event) => context.push(Routes.getEventDetailPath(event.id));

  void onNotificationScreen() => context.push(Routes.notification);

  @override
  Widget build(BuildContext context) {
    final categoryAsyncValue = ref.watch(categoryProvider);
    final eventAsyncValue = ref.watch(eventProvider);
    ref.watch(notificationProvider).whenData((notifications) {
      unreadNotificationCount = notifications
          .where((notification) => notification.isRead != true)
          .length;
    });

    return TicketScaffold(
      title: 'Events',
      appBarActions: [
        Badge(
          label: Text(unreadNotificationCount.toString()),
          isLabelVisible: unreadNotificationCount > 0,
          offset: const Offset(-5, 4),
          child: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: onNotificationScreen,
          ),
        )
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(eventProvider.future),
        child: ListView(
          children: [
            // Thanh tìm kiếm
            SearchAnchor.bar(
              searchController: SearchController(),
              barHintText: 'Search for events...',
              onSubmitted: (_) => print('Search for events...'),
              suggestionsBuilder: (context, searchController) {
                return [
                  const Text('Search for events...').px(16).py(8),
                  const Text('Search for events...').px(16).py(8),
                  const Text('Search for events...').px(16).py(8),
                ];
              },
            ).px(16),
            const SizedBox(height: 16),

            // Danh mục (Categories)
            SizedBox(
              height: 50,
              child: categoryAsyncValue.when(
                data: (categories) => CarouselView.weighted(
                  flexWeights: const [1, 2, 2, 1],
                  onTap: (index) {
                    final category = categories[index];
                    setState(() {
                      if (selectedCategoryIds.contains(category.id)) {
                        selectedCategoryIds.remove(category.id);
                      } else {
                        selectedCategoryIds.add(category.id);
                      }
                    });
                  },
                  children: [
                    ...categories.map(
                      (category) {
                        final isSelected =
                            selectedCategoryIds.contains(category.id);
                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[300],
                            // color: selectedCategoryIds.contains(category.id)
                            //     ? Theme.of(context).colorScheme.primary
                            //     : _getCategoryColor(category.id),
                            // borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: selectedCategoryIds.contains(category.id)
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                loading: () => null,
                error: (_, __) => null,
              ),
            ),

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
