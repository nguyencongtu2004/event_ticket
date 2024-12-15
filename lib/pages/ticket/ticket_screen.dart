import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/pages/ticket/widget/ticket_list.dart';
import 'package:event_ticket/providers/ticket_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, this.detailId});

  final String? detailId;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {

  @override
  void initState() {
    super.initState();
    if (widget.detailId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Vì trong initState thì qidget chưa được build nên trong context chưa có widget này
        // => chưa chuyển hướng được => thêm call back khi widget được build xong
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
      body: asyncValue.when(
        data: (tickets) {
          final bookedTickets =
              tickets.filter((e) => e.status == TicketStatus.booked).toList();
          final checkedInTickets = tickets
              .filter((e) => e.status == TicketStatus.checkedIn)
              .toList();
          final cancelledTickets = tickets
              .filter((e) => e.status == TicketStatus.cancelled)
              .toList();

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'All'),
                    Tab(text: 'Booked'),
                    Tab(text: 'Checked In'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
                TabBarView(
                  children: [
                    TicketList(tickets: tickets, onTap: onTicket),
                    TicketList(tickets: bookedTickets, onTap: onTicket),
                    TicketList(tickets: checkedInTickets, onTap: onTicket),
                    TicketList(tickets: cancelledTickets, onTap: onTicket),
                  ],
                ).expand(),
              ],
            ),
          );
        },
        loading: () => const CircularProgressIndicator().centered(),
        error: (error, stackTrace) => Text('Error occurred: $error').centered(),
      ),
    );
  }
}
