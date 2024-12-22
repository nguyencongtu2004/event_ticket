import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/trasfer_ticket.dart';
import 'package:event_ticket/providers/transfer_ticket_provider.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransferTicketScreen extends ConsumerWidget {
  const TransferTicketScreen({super.key});

  void onTicketTap(BuildContext context, TransferTicket transferTicket) {
    final eventId = transferTicket.ticket?.event?.id;
    if (eventId == null) return;
    context.push(Routes.getEventDetailPath(eventId));
  }

  void onAcceptTicket(
    BuildContext context,
    WidgetRef ref,
    TransferTicket transferTicket,
  ) async {
    if (transferTicket.ticket?.id == null) return;
    final response =
        await TicketRequest().confirmTransferTicket(transferTicket.ticket!.id);
    if (response.statusCode == 200) {
      ref.invalidate(transferTicketProvider);
      context.showAnimatedToast(response.data['message'] ?? 'Success');
    } else {
      context.showAnimatedToast(response.data['message'] ?? 'Failed');
    }
  }

  void onRejectTicket(
    BuildContext context,
    WidgetRef ref,
    TransferTicket transferTicket,
  ) async {
    if (transferTicket.ticket?.id == null) return;
    final response =
        await TicketRequest().rejectTransferTicket(transferTicket.ticket!.id);
    if (response.statusCode == 200) {
      ref.invalidate(transferTicketProvider);
      context.showAnimatedToast(response.data['message'] ?? 'Success');
    } else {
      context.showAnimatedToast(response.data['message'] ?? 'Failed');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(transferTicketProvider);
    return TicketScaffold(
      title: 'Transfer Ticket',
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(transferTicketProvider.future),
        child: switch (asyncValue) {
          // Nếu có dữ liệu, hiển thị dữ liệu, kể cả trong lúc làm mới.
          AsyncValue<List<TransferTicket>>(:final valueOrNull?) =>
            _buildTransferTicketList(context, ref, valueOrNull),
          // Nếu có lỗi, hiển thị lỗi.
          AsyncValue(:final error?) => Center(child: Text('Error: $error')),
          // Nếu không có dữ liệu, hiển thị trạng thái tải.
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _buildTransferTicketList(
      BuildContext context, WidgetRef ref, List<TransferTicket> tickets) {
    if (tickets.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final transferTicket = tickets[index];
        return GestureDetector(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                ListTile(
                  onTap: () => onTicketTap(context, transferTicket),
                  leading: Avatar(transferTicket.fromUser),
                  title: Text(
                      'Event: ${transferTicket.ticket?.event?.name ?? 'N/A'}'),
                  subtitle: Text(
                      'From: ${transferTicket.fromUser?.name ?? 'Unknown'}'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Decline'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () =>
                          onRejectTicket(context, ref, transferTicket),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: Colors.green),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () =>
                          onAcceptTicket(context, ref, transferTicket),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: const Center(
            child: Text('No transfer tickets.'),
          ),
        ),
      ],
    );
  }
}
