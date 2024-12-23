import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/models/category.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/pages/event/widget/event_card.dart';
import 'package:event_ticket/providers/category_provider.dart';
import 'package:event_ticket/requests/event_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:event_ticket/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchEventScreen extends ConsumerStatefulWidget {
  const SearchEventScreen({super.key});

  @override
  ConsumerState<SearchEventScreen> createState() => _SearchEventScreenState();
}

class _SearchEventScreenState extends ConsumerState<SearchEventScreen> {
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  DateTime? selectedDate;
  String? selectedLocation;
  Category? selectedCategory;
  EventStatus? selectedStatus;
  List<Event> searchResults = [];
  bool isSearching = false;
  bool isFilterVisible = true;
  bool hasSearched = false;
  final _eventRequest = EventRequest();
  final _searchFocusNode = FocusNode();

  // TODO: Replace with actual locations
  final List<String> locations = [];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);

    // Focus on the search field when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void onScroll() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (isFilterVisible) {
        setState(() {
          isFilterVisible = false;
        });
      }
    } else if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!isFilterVisible) {
        setState(() {
          isFilterVisible = true;
        });
      }
    }
  }

  Future<void> performSearch() async {
    setState(() {
      isSearching = true;
      hasSearched = true;
    });

    try {
      final response = await _eventRequest.searchEvents(
        name: searchController.text.isNotEmpty ? searchController.text : null,
        date: selectedDate,
        location: selectedLocation,
        category: selectedCategory,
        status: selectedStatus,
      );

      final results = List<Event>.from((response.data as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>)));

      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      setState(() => isSearching = false);
      // Handle error if needed
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      performSearch();
    }
  }

  void clearFilters() {
    setState(() {
      selectedDate = null;
      selectedLocation = null;
      selectedCategory = null;
      selectedStatus = null;
      searchController.clear();
    });
    performSearch();
  }

  bool get isFilterActive =>
      selectedDate != null ||
      selectedLocation != null ||
      selectedCategory != null ||
      selectedStatus != null;

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(categoryProvider);

    return TicketScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            TextField(
              controller: searchController,
              focusNode: _searchFocusNode,
              onSubmitted: (_) => performSearch(),
              decoration: const InputDecoration(
                hintText: 'Search events...',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
            ).expand(),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: performSearch,
                ),
              ],
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Spacer for the filter section
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: isFilterVisible
                    ? isFilterActive
                        ? 110
                        : 50
                    : 0,
                child: const SizedBox(),
              ),
              // Results section
              Expanded(
                child: isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : !hasSearched
                        ? Text(
                            'Type something to search',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                          ).centered()
                        : searchResults.isEmpty
                            ? const Text('No events found').centered()
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  return EventCard(
                                    event: searchResults[index],
                                    onTap: (event) => context.push(
                                        Routes.getEventDetailPath(event.id)),
                                  );
                                },
                              ),
              ),
            ],
          ),
          // Filter section overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: isFilterVisible
                ? 0
                : isFilterActive
                    ? -50
                    : -110,
            left: 0,
            right: 0,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      // Date
                      FilterChip(
                        label: Text(selectedDate == null
                            ? 'Select Date'
                            : DateFormat('MMM d, y').format(selectedDate!)),
                        onSelected: (_) => selectDate(),
                        selected: selectedDate != null,
                      ),

                      // Category
                      categoryAsync.when(
                        data: (categories) => DropdownButton<Category>(
                          hint: const Text('Category'),
                          value: selectedCategory,
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (Category? value) {
                            setState(() => selectedCategory = value);
                            performSearch();
                          },
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),

                      // Status
                      DropdownButton<EventStatus>(
                        hint: const Text('Status'),
                        value: selectedStatus,
                        items: EventStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.name.capitalize()),
                          );
                        }).toList(),
                        onChanged: (EventStatus? value) {
                          setState(() => selectedStatus = value);
                          performSearch();
                        },
                      ),

                      // Location
                      if (locations.isNotEmpty)
                        DropdownButton<String>(
                          hint: const Text('Location'),
                          value: selectedLocation,
                          items: locations.map((location) {
                            return DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() => selectedLocation = value);
                            performSearch();
                          },
                        ),
                    ],
                  ).scrollHorizontal(),

                  // Clear Filters
                  if (isFilterActive)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: clearFilters,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear Filters'),
                      ).px(12),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
