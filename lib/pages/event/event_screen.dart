import 'package:event_ticket/pages/event/widget/event_card.dart';
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
  final _searchController = SearchController();

  void onSeeAllUpcomingEvents() {
    context.push(Routes.getEventListPath(
      title: 'Upcoming Events',
      sortBy: 'date',
    ));
  }

  void onSeeAllPopularEvents() {
    context.push(Routes.getEventListPath(
      title: 'Popular Events',
      sortBy: 'sold',
    ));
  }

  void onEventTap(event) => context.push(Routes.getEventDetailPath(event.id));

  void onNotificationScreen() => context.push(Routes.notification);

  void onSearchTap() => context.push(Routes.searchEvent);

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
            tooltip: 'Notifications',
          ),
        ).px(unreadNotificationCount > 0 ? 8 : 0),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;

          return RefreshIndicator(
            onRefresh: () => ref.refresh(eventProvider.future),
            child: eventAsyncValue.when(
              data: (valueOrNull) {
                final events = valueOrNull
                    .where((event) =>
                        selectedCategoryIds.isEmpty ||
                        selectedCategoryIds
                            .any((id) => event.category.any((c) => c.id == id)))
                    .toList();

                if (isLargeScreen) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left sidebar with categories
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Categories',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ).p(16),
                            categoryAsyncValue.when(
                              data: (categories) => ListView.builder(
                                shrinkWrap: true,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final isSelected =
                                      selectedCategoryIds.contains(category.id);
                                  return ListTile(
                                    selected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedCategoryIds
                                              .remove(category.id);
                                        } else {
                                          selectedCategoryIds.add(category.id);
                                        }
                                      });
                                    },
                                    title: Text(category.name),
                                    leading: Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                  );
                                },
                              ),
                              loading: () => const Center(
                                  child: CircularProgressIndicator()),
                              error: (error, stackTrace) =>
                                  Center(child: Text('Error: $error')),
                            ),
                          ],
                        ),
                      ),
                      // Main content
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            // Search Bar
                            SliverToBoxAdapter(
                              child: SearchBar(
                                controller: _searchController,
                                hintText: 'Search for events...',
                                leading: const Icon(Icons.search).px(8),
                                enabled: false,
                                backgroundColor: WidgetStateColor.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.disabled)
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest),
                                textStyle: WidgetStateTextStyle.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.disabled)
                                            ? Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: Colors.grey)
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(color: Colors.black)),
                                surfaceTintColor: WidgetStateColor.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.disabled)
                                            ? Colors.grey
                                            : Colors.transparent),
                              ).p(16).onTap(onSearchTap),
                            ),

                            // Events Grid
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Upcoming Events
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Upcoming Events',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        TextButton(
                                          onPressed: onSeeAllUpcomingEvents,
                                          child: const Text('See All'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 250,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        children: events
                                            .where((event) => event.date!
                                                .isAfter(DateTime.now()))
                                            .toList()
                                            .map((event) => ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 300,
                                                    maxWidth: 400,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16),
                                                    child: EventCard(
                                                      event: event,
                                                      onTap: onEventTap,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ),

                                  // Popular Events
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Popular Events',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        TextButton(
                                          onPressed: onSeeAllPopularEvents,
                                          child: const Text('See All'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 250,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        children: events
                                            .where((event) => event.date!
                                                .isAfter(DateTime.now()))
                                            .toList()
                                            .map((event) => ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 300,
                                                    maxWidth: 400,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16),
                                                    child: EventCard(
                                                      event: event,
                                                      onTap: onEventTap,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ),

                                  // All Events Title
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'All Events',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),

                                  // All Events Grid using Wrap
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: events
                                          .map((event) => ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 300,
                                                  maxWidth: 400,
                                                ),
                                                child: EventCard(
                                                  event: event,
                                                  onTap: onEventTap,
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Mobile layout
                return CustomScrollView(
                  slivers: [
                    // Search Bar
                    SliverToBoxAdapter(
                      child: SearchBar(
                        controller: _searchController,
                        hintText: 'Search for events...',
                        leading: const Icon(Icons.search).px(8),
                        enabled: false,
                        backgroundColor: WidgetStateColor.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? Colors.grey
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest),
                        textStyle: WidgetStateTextStyle.resolveWith((states) =>
                            states.contains(WidgetState.disabled)
                                ? Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.grey)
                                : Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.black)),
                        surfaceTintColor: WidgetStateColor.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? Colors.grey
                                : Colors.transparent),
                      ).px(16).py(16).onTap(onSearchTap),
                    ),

                    // Upcoming Events
                    SliverToBoxAdapter(
                      child: EventList(
                        title: 'Upcoming Events',
                        eventsAsyncValue: eventAsyncValue,
                        filter: (event) => event.date!.isAfter(DateTime.now()),
                        sort: (a, b) => a.date!.compareTo(b.date!),
                        seeAll: onSeeAllUpcomingEvents,
                        onEventTap: onEventTap,
                      ),
                    ),

                    // Popular Events
                    SliverToBoxAdapter(
                      child: EventList(
                        title: 'Popular Events',
                        eventsAsyncValue: eventAsyncValue,
                        filter: (event) => event.date!.isAfter(DateTime.now()),
                        sort: (a, b) =>
                            b.ticketsSold!.compareTo(a.ticketsSold!),
                        seeAll: onSeeAllPopularEvents,
                        onEventTap: onEventTap,
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Text(
                        'All Events',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).px(16).py(8),
                    ),

                    // Categories
                    SliverToBoxAdapter(
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
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ).h(50).py(8),
                        loading: () => const SizedBox.shrink(),
                        error: (error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),

                    // All Events (Vertical List)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= events.length) return null;
                          return EventCard(
                            event: events[index],
                            onTap: onEventTap,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
              loading: () => Column(
                children: [
                  SearchBar(
                    controller: _searchController,
                    hintText: 'Search for events...',
                    leading: const Icon(Icons.search).px(8),
                    enabled: false,
                    backgroundColor: WidgetStateColor.resolveWith((states) =>
                        states.contains(WidgetState.disabled)
                            ? Colors.grey
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest),
                    textStyle: WidgetStateTextStyle.resolveWith((states) =>
                        states.contains(WidgetState.disabled)
                            ? Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.grey)
                            : Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Colors.black)),
                    surfaceTintColor: WidgetStateColor.resolveWith((states) =>
                        states.contains(WidgetState.disabled)
                            ? Colors.grey
                            : Colors.transparent),
                  ).px(16).py(16).onTap(onSearchTap),
                  const Center(child: CircularProgressIndicator()).expand(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
