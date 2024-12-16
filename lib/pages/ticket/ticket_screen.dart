import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/pages/ticket/widget/ticket_list.dart';
import 'package:event_ticket/providers/ticket_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, this.detailId});

  final String? detailId;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen>
    with TickerProviderStateMixin {
  late TabController tabBarController;

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
    context.push(Routes.getTicketDetailPath(ticket.id));
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(ticketProvider);

    return TicketScaffold(
      title: 'Tickets',
      body: Column(
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
              AsyncValue(:final error?) => Center(child: Text('Error: $error')),
              // Nếu không có dữ liệu, hiển thị trạng thái tải.
              _ => const Center(child: CircularProgressIndicator()),
            },
          )
        ],
      ),
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
