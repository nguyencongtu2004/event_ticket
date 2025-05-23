import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/pages/ticket/ticket_detail_screen.dart';
import 'package:event_ticket/pages/ticket/widget/ticket_list.dart';
import 'package:event_ticket/providers/ticket_provider.dart';
import 'package:event_ticket/providers/transfer_ticket_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velocity_x/velocity_x.dart';

class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, this.detailId});

  final String? detailId;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen>
    with TickerProviderStateMixin {
  late TabController tabBarController;
  int unreadNotificationCount = 0;
  String? selectedTicketId;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 4, vsync: this);
    if (widget.detailId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push(Routes.getTicketDetailPath(widget.detailId!));
      });
    }
  }

  void onTicket(BuildContext context, Ticket ticket) {
    setState(() => selectedTicketId = ticket.id);
    if (MediaQuery.of(context).size.width < 800) {
      context
          .push(Routes.getTicketDetailPath(ticket.id))
          .then((_) => setState(() => selectedTicketId = null));
    }
  }

  void onTransferTicketScreen() {
    context.push(Routes.transferTicket);
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(ticketProvider);
    ref.watch(transferTicketProvider).whenData((transferTicket) {
      unreadNotificationCount = transferTicket.length;
    });

    return TicketScaffold(
      title: 'Tickets',
      appBarActions: [
        Badge(
          label: Text(unreadNotificationCount.toString()),
          isLabelVisible: unreadNotificationCount > 0,
          offset: const Offset(-5, 4),
          child: IconButton(
            icon: const Icon(Icons.airplane_ticket_outlined),
            onPressed: onTransferTicketScreen,
            tooltip: 'Transfer tickets',
          ),
        )
      ],
      body: LayoutBuilder(builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                TabBar(
                  controller: tabBarController,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Booked'),
                    Tab(text: 'Checked In'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
                Expanded(
                  child: switch (asyncValue) {
                    // Nếu có dữ liệu, hiển thị dữ liệu.
                    AsyncValue<List<Ticket>>(:final valueOrNull?) => TabBarView(
                        controller: tabBarController,
                        children: [
                          _buildTicketList(valueOrNull, null),
                          _buildTicketList(valueOrNull, TicketStatus.booked),
                          _buildTicketList(valueOrNull, TicketStatus.checkedIn),
                          _buildTicketList(valueOrNull, TicketStatus.cancelled),
                        ],
                      ),
                    // Nếu có lỗi, hiển thị lỗi.
                    AsyncValue(:final error?) =>
                      Center(child: Text('Error: $error')),
                    // Nếu không có dữ liệu, hiển thị trạng thái tải.
                    _ => const Center(child: CircularProgressIndicator()),
                  },
                )
              ],
            ).expand(),
            if (isLargeScreen && selectedTicketId != null) ...[
              const VerticalDivider(width: 1),
              Stack(
                children: [
                  TicketDetailScreen(
                    key: ValueKey(selectedTicketId),
                    ticketId: selectedTicketId!,
                  ),
                  Positioned(
                    top: 8,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => selectedTicketId = null),
                      tooltip: 'Close ticket details',
                    ),
                  ),
                ],
              ).expand(),
            ]
          ],
        ).w(isLargeScreen && selectedTicketId != null ? 1200 : 600).centered();
      }),
    );
  }

  Widget _buildTicketList(List<Ticket> tickets, TicketStatus? filterStatus) {
    final filteredTickets = filterStatus == null
        ? tickets
        : tickets.where((e) => e.status == filterStatus).toList();

    return RefreshIndicator(
      onRefresh: () => ref.refresh(ticketProvider.future),
      child: TicketList(
        tickets: filteredTickets,
        onTap: onTicket,
      ),
    );
  }
}
